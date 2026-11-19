import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { setTimeout as sleep } from 'node:timers/promises'
import { dsvFormat } from 'd3-dsv'
import { strFromU8, unzipSync } from 'fflate'
import type { Accident, Osm } from './types.ts'

const REPO_URL = 'https://github.com/datawrapper/snippets'
// donated public services: back off for up to ~33 min in total rather than
// add load
const RETRY_WAITS_S = [60, 120, 300, 600, 900]

type Retry = { reason: string, detail: string, retry_after_s: number }
type Attempt = { bytes: Uint8Array | null } | Retry

// one request: the bytes (null for a 404), or why it can be retried
async function try_download(url: string, init: RequestInit): Promise<Attempt> {
	let res: Response
	try {
		res = await fetch(url, {
			...init,
			headers: {
				// overpass-api.de answers 406 to library default user agents;
				// FOSSGIS's terms also require a Referer where technically
				// possible
				'User-Agent': `muenster-kreuzungen/0.1 (+${REPO_URL})`,
				referer: REPO_URL,
			},
		})
	} catch (error) {
		return { reason: 'network error', detail: String(error), retry_after_s: 0 }
	}
	if (res.ok) return { bytes: new Uint8Array(await res.arrayBuffer()) }
	if (res.status === 404) return { bytes: null }
	const detail = `${res.status} ${(await res.text()).slice(0, 200)}`
	if (![429, 502, 503, 504].includes(res.status))
		throw new Error(`${url} failed: ${detail}`)
	const retry_after = Number(res.headers.get('retry-after'))
	return {
		reason: String(res.status),
		detail,
		retry_after_s: Number.isFinite(retry_after) ? retry_after : 0,
	}
}

async function download(
	url: string,
	init: RequestInit = {},
): Promise<Uint8Array | null> {
	for (let attempt = 0; ; attempt++) {
		const result = await try_download(url, init)
		if ('bytes' in result) return result.bytes
		if (attempt >= RETRY_WAITS_S.length)
			throw new Error(`${url} failed: ${result.detail}`)
		const wait = Math.max(RETRY_WAITS_S[attempt], result.retry_after_s)
		console.error(
			`${new URL(url).host}: ${result.reason}, retrying in ${wait} s`,
		)
		await sleep(wait * 1000)
	}
}

async function cached<T extends string | null>(
	file: string,
	get: () => Promise<T>,
): Promise<string | T> {
	const path = join(import.meta.dirname, '..', 'data', file)
	if (process.env.REDOWNLOAD_DATA !== '1' && existsSync(path))
		return readFileSync(path, 'utf8')
	const text = await get()
	if (text === null) return text
	mkdirSync(dirname(path), { recursive: true })
	writeFileSync(path, text)
	return text
}

const unfallatlas_url = (year: number) =>
	`https://www.opengeodata.nrw.de/produkte/transport_verkehr/unfallatlas/Unfallorte${year}_EPSG25832_CSV.zip`
// Münster's Amtlicher Gemeindeschlüssel, split like the Unfallatlas columns
const AGS_COLUMNS: [column: string, part: string][] = [
	['ULAND', '05'],
	['UREGBEZ', '5'],
	['UKREIS', '15'],
	['UGEMEINDE', '000'],
]
const ACCIDENT_COLUMNS: [field: keyof Accident, column: string][] = [
	['year', 'UJAHR'],
	['category', 'UKATEGORIE'],
	['bike', 'IstRad'],
	['lon', 'XGCSWGS84'],
	['lat', 'YGCSWGS84'],
]
// the CSV's name, folder and extension inside the zip change every year
const CSV_IN_ZIP = /\.(csv|txt)$/i

async function download_muenster_year(year: number): Promise<string | null> {
	const zip = await download(unfallatlas_url(year))
	if (!zip) return null
	console.error(`Downloaded Unfallatlas ${year}`)
	const files = Object.values(
		unzipSync(zip, { filter: (file) => CSV_IN_ZIP.test(file.name) }),
	)
	if (files.length !== 1) {
		throw new Error(
			`Unfallatlas ${year}: expected one CSV in the zip, found ${files.length}`,
		)
	}
	const rows = dsvFormat(';').parse(strFromU8(files[0]))
	const needed = [
		...AGS_COLUMNS.map(([column]) => column),
		...ACCIDENT_COLUMNS.map(([, column]) => column),
	]
	const missing = needed.filter((column) => !rows.columns.includes(column))
	if (missing.length) {
		throw new Error(`Unfallatlas ${year} has no columns ${missing.join(', ')}`)
	}
	// compared as numbers because 2021 writes "5" and "0", not "05" and "000"
	const accidents = rows
		.filter((row) =>
			AGS_COLUMNS.every(
				([column, part]) => Number(row[column]) === Number(part),
			),
		)
		// the files use decimal commas
		.map(
			(row) =>
				Object.fromEntries(
					ACCIDENT_COLUMNS.map(([field, column]) => [
						field,
						Number(row[column]!.replace(',', '.')),
					]),
				) as Accident,
		)
	return JSON.stringify(accidents)
}

// NRW-specific: NRW joined the Unfallatlas in 2019 (other states 2016–2018);
// earlier files have no NRW rows
const FIRST_YEAR = 2019

// One cache file per year, Münster rows only. Each run also tries the year
// after the newest cached one, so new releases need no code change.
export async function load_accidents(): Promise<Accident[]> {
	const accidents: Accident[] = []
	for (let year = FIRST_YEAR; ; year++) {
		const json = await cached(`unfaelle-${year}.json`, () =>
			download_muenster_year(year),
		)
		if (json === null) break
		accidents.push(...(JSON.parse(json) as Accident[]))
	}
	if (!accidents.length)
		throw new Error(`No Unfallatlas file at ${unfallatlas_url(FIRST_YEAR)}`)
	return accidents
}

const AGS = AGS_COLUMNS.map(([, part]) => part).join('')

export async function load_osm(): Promise<Osm> {
	const text = await cached('osm_muenster.json', async () => {
		// FOSSGIS, who run overpass-api.de, recommend not hardcoding their URL
		const overpass_url = process.env.OVERPASS_URL
		if (!overpass_url) {
			throw new Error(
				'Downloading OSM data needs an Overpass server, e.g. OVERPASS_URL=https://overpass-api.de/api/interpreter',
			)
		}
		const body = new URLSearchParams({
			// footway and path nodes chain separate junctions together;
			// construction and proposed roads aren't open. The street nodes
			// come without tags, so traffic signals are a query of their own
			data: `
[out:json][timeout:180];
area["de:amtlicher_gemeindeschluessel"="${AGS}"]->.ms;
way(area.ms)["highway"]["name"]
  ["highway"!~"^(footway|path|construction|proposed)$"];
out body; >; out skel qt;
node(area.ms)["highway"="traffic_signals"];
out qt;
`,
		})
		const bytes = await download(overpass_url, { method: 'POST', body })
		if (!bytes) throw new Error(`${overpass_url} answered 404`)
		const text = strFromU8(bytes)
		const data = JSON.parse(text) as Osm
		// on timeout or out of memory, Overpass returns 200 and a remark
		if (data.remark)
			throw new Error(`Overpass returned partial data: ${data.remark}`)
		if (!data.elements.some((element) => element.type === 'way')) {
			throw new Error(
				`Overpass returned no ways. Check that an OSM boundary still has de:amtlicher_gemeindeschluessel=${AGS}, or select the area by name and admin_level`,
			)
		}
		return text
	})
	return JSON.parse(text)
}
