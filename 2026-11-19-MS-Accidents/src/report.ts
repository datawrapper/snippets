import { mkdirSync, writeFileSync } from 'node:fs'
import { join, relative } from 'node:path'
import { csvFormat } from 'd3-dsv'
import { by_german } from './junctions.ts'
import type {
	Accident,
	JunctionType,
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
function street_view_link(junction: RankedJunction) {
	const [lat, lng] = lat_lng(junction)
	const url = `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${lat},${lng}`
	return `<a href='${url}' target='_blank'>Street View</a>`
}

function links(junction: RankedJunction) {
	const [lat, lng] = lat_lng(junction)
	const osm = `https://www.openstreetmap.org/?mlat=${lat}&mlon=${lng}#map=18/${lat}/${lng}`
	return `<a href='${osm}' target='_blank'>Map</a> · `
		+ street_view_link(junction)
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
				+ `<span style="font-size: 0.8em">${links(junction)}</span>`,
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

// Datawrapper's own "signal" icon is a radio antenna
const JUNCTION_ICONS: Record<JunctionType, string> = {
	roundabout: 'roundabout',
	traffic_signals: 'material:traffic-lights',
	no_signals: 'material:signpost',
}

// One style property per element: semicolons make Datawrapper's import guess
// ";" as the CSV delimiter
function locator_tooltip(junction: RankedJunction, years: string[]) {
	const first = years[0]
	const last = years.at(-1)!
	return `<h2 style='margin-top:0'>#${junction.rank} ${junction.label}</h2>`
		// on the inline <small>, line-height can't go below the tooltip's
		+ `<div style='line-height:1.2'><small>${junction.streets}</small></div>`
		+ street_view_link(junction)
		+ '<hr>'
		+ [
			`<b>${junction.accidents.length}</b> accidents `
			+ `(<b>${with_serious_injuries(junction)}</b> ${SERIOUS_HEADER})`,
			`<b>${bike_pct(junction)}%</b> with a bike involved`,
			`<b>${in_year(junction, first)} → ${in_year(junction, last)}</b> `
			+ `from ${first} to ${last}`,
		].join('<br>')
}

function locator_marker(junction: RankedJunction, years: string[]) {
	const [lat, lng] = lat_lng(junction)
	return {
		lat,
		lng,
		// no label next to the icons. A space, because Datawrapper fills an
		// empty title with "Marker Text"
		title: ' ',
		icon: JUNCTION_ICONS[junction.type],
		name: junction.label, // Datawrapper's marker list only
		tooltip: locator_tooltip(junction, years),
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
