import kdbush from 'kdbush'
import { JUNCTION_FIXES } from './junction_fixes.ts'
import type {
	Accident,
	Junction,
	JunctionWithAccidents,
	Osm,
	OsmWay,
	Point,
} from './types.ts'

// Münster's latitude: centre of the local metric projection, fine at city scale
const LAT0 = 51.96

function to_m(lon: number, lat: number): Point {
	return [lon * 111_320 * Math.cos((LAT0 * Math.PI) / 180), lat * 110_540]
}

function from_m([x, y]: Point): Point {
	return [x / 111_320 / Math.cos((LAT0 * Math.PI) / 180), y / 110_540]
}

const distance = ([ax, ay]: Point, [bx, by]: Point) =>
	Math.hypot(ax - bx, ay - by)

const mean = (points: Point[]): Point => [
	points.reduce((sum, point) => sum + point[0], 0) / points.length,
	points.reduce((sum, point) => sum + point[1], 0) / points.length,
]

function spatial_index(points: Point[]) {
	const index = new kdbush(points.length)
	for (const [x, y] of points) index.add(x, y)
	index.finish()
	return ([x, y]: Point, radius_m: number) => index.within(x, y, radius_m)
}

// a junction_fixes.ts entry spanning more than this likely matches a namesake
// junction elsewhere in the city. Umgehungsstraße / Albersloher Weg, one
// junction with ramps, spans 106 m
const MAX_FIX_SPAN_M = 150
// lower index = more important; picks the two streets that name a junction
const HIGHWAY_RANK = [
	'trunk',
	'primary',
	'secondary',
	'tertiary',
	'unclassified',
	'residential',
	'living_street',
	'cycleway',
	'service',
]
const LINK_SUFFIX = /_link$/
const RING_SUFFIX = /ring$/i

function class_rank(highway: string): number {
	const position = HIGHWAY_RANK.indexOf(highway.replace(LINK_SUFFIX, ''))
	return (
		(position === -1 ? HIGHWAY_RANK.length : position)
		+ (highway.endsWith('_link') ? 0.5 : 0)
	)
}

const is_roundabout = (way: OsmWay) =>
	way.tags.junction === 'roundabout' || way.tags.junction === 'circular'
const is_ring = (name: string) => RING_SUFFIX.test(name)
export const by_german = (a: string, b: string) => a.localeCompare(b, 'de')

function junction_label(
	ways: OsmWay[],
	by_prominence: (a: string, b: string) => number,
): string {
	const best_rank = new Map<string, number>()
	for (const way of ways) {
		best_rank.set(
			way.tags.name,
			Math.min(
				best_rank.get(way.tags.name) ?? Infinity,
				class_rank(way.tags.highway),
			),
		)
	}
	return (
		[...best_rank]
			.sort(
				([a, rank_a], [b, rank_b]) => rank_a - rank_b
					|| by_prominence(a, b),
			)
			.map(([name]) => name)
			// Münster's ring roads change name at big junctions; two ring names
			// would hide the crossing street
			.filter(
				(name, i, names) => !is_ring(name)
					|| !names.slice(0, i).some(is_ring),
			)
			.slice(0, 2)
			.join(' / ')
	)
}

// OSM has no street prominence. On equal class at a junction, compare each
// street's best class city-wide, then its total length
function street_prominence(ways: OsmWay[], coords_m: Map<number, Point>) {
	const city_rank = new Map<string, number>()
	const length_m = new Map<string, number>()
	for (const way of ways) {
		const name = way.tags.name
		const rank = class_rank(way.tags.highway)
		city_rank.set(name, Math.min(city_rank.get(name) ?? Infinity, rank))
		const points = way.nodes
			.filter((node) => coords_m.has(node))
			.map((node) => coords_m.get(node)!)
		let length = 0
		for (let i = 1; i < points.length; i++)
			length += distance(points[i - 1], points[i])
		length_m.set(name, (length_m.get(name) ?? 0) + length)
	}
	return (a: string, b: string) =>
		city_rank.get(a)! - city_rank.get(b)!
		|| length_m.get(b)! - length_m.get(a)!
		|| by_german(a, b)
}

function union_find() {
	const parent = new Map<number, number>()
	const find = (node: number): number => {
		while (parent.has(node)) node = parent.get(node)!
		return node
	}
	const union = (node_a: number, node_b: number) => {
		const root_a = find(node_a)
		const root_b = find(node_b)
		if (root_a !== root_b) parent.set(root_a, root_b)
	}
	return { find, union }
}

// Returns the hand-set labels, each keyed by a node of its merged junction
function apply_junction_fixes(
	by_streets: Map<string, number[][]>,
	centre: (node_ids: number[]) => Point,
	union: (node_a: number, node_b: number) => void,
): [number, string][] {
	const fixed_labels: [number, string][] = []
	for (const { streets, label } of JUNCTION_FIXES) {
		const missing = streets.filter(
			(street_list) => !by_streets.has(street_list),
		)
		if (missing.length) {
			console.warn(
				`junction_fixes.ts: no junction "${missing.join('", "')}", skipped`,
			)
			continue
		}
		const parts = streets.flatMap(
			(street_list) => by_streets.get(street_list)!,
		)
		const centres = parts.map(centre)
		const span = Math.max(
			...centres.flatMap((centre_a) =>
				centres.map((centre_b) => distance(centre_a, centre_b)),
			),
		)
		if (span > MAX_FIX_SPAN_M) {
			console.warn(
				`junction_fixes.ts: "${streets.join('", "')}" spans ${Math.round(span)} m, skipped`,
			)
			continue
		}
		for (const part of parts) union(part[0], parts[0][0])
		if (label) fixed_labels.push([parts[0][0], label])
	}
	return fixed_labels
}

export function build_junctions(osm: Osm, merge_within_m: number): Junction[] {
	// index nodes and ways
	const coords_m = new Map<number, Point>()
	const ways: OsmWay[] = []
	for (const element of osm.elements) {
		if (element.type === 'node')
			coords_m.set(element.id, to_m(element.lon, element.lat))
		else ways.push(element)
	}
	const ways_at = new Map<number, OsmWay[]>()
	for (const way of ways) {
		for (const node of new Set(way.nodes)) {
			if (!ways_at.has(node)) ways_at.set(node, [])
			ways_at.get(node)!.push(way)
		}
	}
	const by_prominence = street_prominence(ways, coords_m)

	// find junction nodes
	const junction_nodes = [...ways_at]
		.filter(
			([, ways_here]) =>
				new Set(ways_here.map((way) => way.tags.name)).size >= 2,
		)
		.map(([node]) => node)

	// merge junction nodes into junctions
	const { find, union } = union_find()
	// a roundabout split into several ways (Ludgerikreisel: 6) is one junction
	const roundabouts = ways.filter(is_roundabout)
	for (const way of roundabouts)
		for (const node of way.nodes) union(node, way.nodes[0])
	// dual carriageways, big crossings
	const points = junction_nodes.map((node) => coords_m.get(node)!)
	const within = spatial_index(points)
	points.forEach((point, i) => {
		for (const neighbour of within(point, merge_within_m))
			union(junction_nodes[i], junction_nodes[neighbour])
	})
	const group = () => Map.groupBy(junction_nodes, (node) => find(node))
	const streets_of = (node_ids: number[]) => {
		const names = node_ids.flatMap((node) =>
			ways_at.get(node)!.map((way) => way.tags.name),
		)
		return [...new Set(names)].sort(by_german).join(' / ')
	}
	const centre = (node_ids: number[]) =>
		mean(node_ids.map((node) => coords_m.get(node)!))
	const by_streets = Map.groupBy(group().values(), (ids) => streets_of(ids))
	const fixed_labels = apply_junction_fixes(by_streets, centre, union)
	const labels = new Map(
		fixed_labels.map(([node, label]) => [find(node), label]),
	)
	// from the union-find, not the ring ways at the junction nodes: a ring
	// piece between two pieces of the same name has no junction node
	const ring_nodes = Map.groupBy(
		new Set(roundabouts.flatMap((way) => way.nodes)),
		(node) => find(node),
	)

	// describe each junction
	return Array.from(group(), ([root, node_ids]) => {
		const ways_here = [
			...new Set(node_ids.flatMap((node) => ways_at.get(node)!)),
		]
		// a ring arc between two entries can be beyond the snapping distance
		// from both, so every ring node is an anchor
		const anchors = [
			...new Set([...node_ids, ...(ring_nodes.get(root) ?? [])]),
		]
		const anchors_m = anchors.map((node) => coords_m.get(node)!)
		// averaging the evenly spread ring nodes centres roundabouts; their
		// entries alone cluster on the sides with more streets
		const [lon, lat] = from_m(mean(anchors_m))
		return {
			label: labels.get(root) ?? junction_label(ways_here, by_prominence),
			streets: streets_of(node_ids),
			lon,
			lat,
			anchors_m,
		}
	})
}

// Snap to the nearest anchor (junction node), not the centre: on a large
// roundabout the centre can be beyond max_distance_m from accidents on the
// ring. Returns each junction with its accidents; mid-block ones are dropped
export function snap_accidents(
	accidents: Accident[],
	junctions: Junction[],
	max_distance_m: number,
): JunctionWithAccidents[] {
	const members = junctions.flatMap((junction, junction_index) =>
		junction.anchors_m.map((point) => ({ point, junction_index })),
	)
	const within = spatial_index(members.map((member) => member.point))
	const by_junction = junctions.map((): Accident[] => [])
	for (const accident of accidents) {
		const point = to_m(accident.lon, accident.lat)
		let best_dist = Infinity
		let nearest = -1
		for (const member_index of within(point, max_distance_m)) {
			const dist = distance(members[member_index].point, point)
			if (dist < best_dist) {
				best_dist = dist
				nearest = members[member_index].junction_index
			}
		}
		if (nearest >= 0) by_junction[nearest].push(accident)
	}
	return junctions.map((junction, i) => ({
		...junction,
		accidents: by_junction[i],
	}))
}
