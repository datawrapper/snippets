import { load_accidents, load_osm } from './fetch.ts'
import { build_junctions, snap_accidents } from './junctions.ts'
import {
	check_table,
	rank_junctions,
	write_locator_map,
	write_table,
} from './report.ts'

// accidents farther than this from every junction node count as mid-block.
// Both distances are tuned on Münster's junctions
const MAX_ACCIDENT_DISTANCE_M = 30
// traffic signals within this of a junction node make it signalised
const MAX_SIGNAL_DISTANCE_M = MAX_ACCIDENT_DISTANCE_M
// larger values chain junctions (at 35 m, Bremer Platz swallows 5 streets)
const MERGE_JUNCTIONS_WITHIN_M = 25
// junctions tied at the cut-off are all included, so there can be more rows
const TABLE_ROWS = 20
// the table junctions the weekly chart's text is about, for map_focus.csv
const MAP_FOCUS = [
	'Ludgerikreisel',
	'Wolbecker Straße / Bahnhofstraße',
	'Albersloher Weg / Hafenstraße',
	'Ziegen-Kreisel',
]

async function main() {
	const accidents = await load_accidents()
	const osm = await load_osm()
	const junctions = build_junctions(
		osm,
		MERGE_JUNCTIONS_WITHIN_M,
		MAX_SIGNAL_DISTANCE_M,
	)
	const with_accidents = snap_accidents(
		accidents,
		junctions,
		MAX_ACCIDENT_DISTANCE_M,
	)

	const years = Array.from(
		new Set(accidents.map((accident) => accident.year)),
		String,
	)
	const in_table = rank_junctions(with_accidents).filter(
		(junction) => junction.rank <= TABLE_ROWS,
	)
	check_table(in_table)
	const missing = MAP_FOCUS.filter(
		(label) => !in_table.some((junction) => junction.label === label),
	)
	if (missing.length) {
		throw new Error(
			`MAP_FOCUS junctions not in the table, update src/main.ts: ${missing.join('; ')}`,
		)
	}

	write_table(`table_top${TABLE_ROWS}.csv`, in_table, years)
	write_locator_map('map_junctions.csv', in_table, years)
	write_locator_map(
		'map_focus.csv',
		in_table.filter((junction) => MAP_FOCUS.includes(junction.label)),
		years,
	)
}

main().catch((error: unknown) => {
	console.error(error instanceof Error ? error.message : error)
	process.exit(1)
})
