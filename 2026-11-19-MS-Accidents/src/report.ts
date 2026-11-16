import { mkdirSync, writeFileSync } from 'node:fs'
import { join, relative } from 'node:path'
import { csvFormat } from 'd3-dsv'
import { by_german } from './junctions.ts'
import type {
	Accident,
	JunctionWithAccidents,
	RankedJunction,
} from './types.ts'

const count = (
	junction: JunctionWithAccidents,
	test: (accident: Accident) => boolean,
) => junction.accidents.filter(test).length
const killed = (junction: JunctionWithAccidents) =>
	count(junction, (accident) => accident.category === 1)
const seriously_injured = (junction: JunctionWithAccidents) =>
	count(junction, (accident) => accident.category === 2)
const with_bike = (junction: JunctionWithAccidents) =>
	count(junction, (accident) => accident.bike === 1)
const in_year = (junction: JunctionWithAccidents, year: string) =>
	count(junction, (accident) => accident.year === Number(year))

export function rank_junctions(
	junctions: JunctionWithAccidents[],
): RankedJunction[] {
	const ranked = junctions
		.filter((junction) => junction.accidents.length > 0)
		.sort(
			(a, b) =>
				b.accidents.length - a.accidents.length
				|| killed(b) - killed(a)
				|| seriously_injured(b) - seriously_injured(a)
				|| by_german(a.label, b.label),
		)
	// ties in accidents share a rank; the other sort keys only order rows
	return ranked.map((junction) => ({
		...junction,
		rank:
			1
			+ ranked.findIndex(
				(other) => other.accidents.length === junction.accidents.length,
			),
	}))
}

const SERIOUS_HEADER = 'w/ serious injuries'

// the table's column name and junction_fixes.ts rely on these holding
export function check_table(junctions: RankedJunction[]) {
	const with_fatal = junctions
		.filter((junction) => killed(junction) > 0)
		.map((junction) => junction.label)
	if (with_fatal.length) {
		console.warn(
			`Fatal accidents at ${with_fatal.join('; ')}: the column `
			+ `"${SERIOUS_HEADER}" counts them, rename it\n`,
		)
	}
	const labels = junctions.map((junction) => junction.label)
	const dupes = [
		...new Set(labels.filter((label, i) => labels.indexOf(label) !== i)),
	]
	if (dupes.length) {
		console.warn(
			`\nDuplicate labels in the table, add them to junction_fixes.ts: ${dupes.join('; ')}`,
		)
	}
}

const OUT_DIR = join(import.meta.dirname, '..', 'output')

// without columns, they follow the first row's key order
function write_csv(
	file: string,
	rows: Record<string, unknown>[],
	columns?: string[],
) {
	mkdirSync(OUT_DIR, { recursive: true })
	const path = join(OUT_DIR, file)
	writeFileSync(
		path,
		csvFormat(rows as Record<string, string>[], columns) + '\n',
	)
	console.log(`Wrote ${relative(process.cwd(), path)}`)
}

// includes fatal ones; table junctions have none (check_table warns)
const with_serious_injuries = (junction: RankedJunction) =>
	killed(junction) + seriously_injured(junction)
const bike_pct = (junction: RankedJunction) =>
	Math.round((100 * with_bike(junction)) / junction.accidents.length)

const lat_lng = (junction: RankedJunction) =>
	[Number(junction.lat.toFixed(6)), Number(junction.lon.toFixed(6))] as const

// single quotes in HTML, so the CSV needs no escaped quotes
function links(junction: RankedJunction, map_text: string) {
	const [lat, lng] = lat_lng(junction)
	const osm = `https://www.openstreetmap.org/?mlat=${lat}&mlon=${lng}#map=18/${lat}/${lng}`
	const street_view = `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${lat},${lng}`
	return `<a href='${osm}' target='_blank'>${map_text}</a> · `
		+ `<a href='${street_view}' target='_blank'>Street View</a>`
}

type Column = [
	header: string,
	value: (junction: RankedJunction) => string | number,
]

export function write_table(
	file: string,
	junctions: RankedJunction[],
	years: string[],
) {
	const columns: Column[] = [
		[
			'Junction',
			(junction) =>
				`<b>#${junction.rank}</b> ${junction.label}<br>`
				+ `<span style="font-size: 0.8em">${links(junction, 'Map')}</span>`,
		],
		[
			`Accidents (${SERIOUS_HEADER})`,
			(junction) =>
				`${junction.accidents.length} (${with_serious_injuries(junction)})`,
		],
		['Bike involved', (junction) => `${bike_pct(junction)}%`],
		...years.map(
			(year): Column => [year, (junction) => in_year(junction, year)],
		),
	]
	const rows = junctions.map((junction) =>
		Object.fromEntries(
			columns.map(([header, value]) => [header, value(junction)]),
		),
	)
	// explicit columns: JS orders integer-like keys ("2019") first in objects
	write_csv(
		file,
		rows,
		columns.map(([header]) => header),
	)
}

const BIKE_SHARE_COLOURS: [min_pct: number, colour: string][] = [
	[80, '#08306b'],
	[50, '#4292c6'],
	[0, '#9ecae1'],
]

function locator_marker(junction: RankedJunction, years: string[]) {
	const [lat, lng] = lat_lng(junction)
	const cells = (tag: string, values: (string | number)[]) =>
		`<tr>${values.map((value) => `<${tag}>${value}</${tag}>`).join('')}</tr>`
	const per_year
		= '<table>'
			+ cells('th', years)
			+ cells(
				'td',
				years.map((year) => in_year(junction, year)),
			)
			+ '</table>'
	const bike = bike_pct(junction)
	return {
		lat,
		lng,
		// the rank sits inside the icon instead of next to it. A space, because
		// Datawrapper fills an empty title with "Marker Text"
		title: ' ',
		icon: 'circle',
		'marker-symbol': junction.rank,
		name: junction.label, // Datawrapper's marker list only
		color: BIKE_SHARE_COLOURS.find(([min_pct]) => bike >= min_pct)![1],
		// the table is a block, so it sits between the <br>-joined lines
		tooltip:
			[
				`<b>${junction.label}</b>`,
				`${junction.accidents.length} injury accidents ${years[0]}–${years.at(-1)}`,
				`${with_serious_injuries(junction)} of them with serious injuries`,
				`${bike}% with a bike involved`,
			].join('<br>')
			+ per_year
			+ [
				`<small>${junction.streets}</small>`,
				links(junction, 'OpenStreetMap'),
			].join('<br>'),
	}
}

export function write_locator_map(
	file: string,
	junctions: RankedJunction[],
	years: string[],
) {
	write_csv(
		file,
		junctions.map((junction) => locator_marker(junction, years)),
	)
}
