type OsmNode = { type: 'node', id: number, lon: number, lat: number }
export type OsmWay = {
	type: 'way'
	id: number
	nodes: number[]
	tags: Record<string, string>
}
export type Osm = { elements: (OsmNode | OsmWay)[], remark?: string }

export type Point = [number, number]

export type Accident = {
	year: number
	category: number // 1 killed, 2 seriously injured, 3 lightly injured
	bike: number
	lon: number
	lat: number
}

export type Junction = {
	label: string
	streets: string
	lon: number
	lat: number
	anchors_m: Point[]
}

export type JunctionWithAccidents = Junction & { accidents: Accident[] }

export type RankedJunction = JunctionWithAccidents & { rank: number }
