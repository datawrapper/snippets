// Hand-made fixes for Münster, keyed by the Streets column of
// output/map_junctions.csv.
// All junctions an entry lists become one junction (OSM sometimes draws one
// crossing as several); `label` replaces the automatic label.
export type JunctionFix = { streets: string[], label?: string }

export const JUNCTION_FIXES: JunctionFix[] = [
	{
		streets: [
			'Am Kanonengraben / Hafenstraße / Hammer Straße / Ludgeriplatz / Ludgeristraße / Moltkestraße / Schorlemerstraße',
		],
		label: 'Ludgerikreisel',
	},
	{
		streets: [
			'Busso-Peus-Straße / Roxeler Straße / Von-Esmarch-Straße / Ziegen-Kreisel',
		],
		label: 'Ziegen-Kreisel',
	},
	{
		streets: [
			'Bahnhofstraße / Eisenbahnstraße / Servatiiplatz / Wolbecker Straße',
			'Bahnhofstraße / Friedrichstraße / Wolbecker Straße',
			'Eisenbahnstraße / Friedrichstraße',
		],
	},
	{
		streets: [
			'Albersloher Weg / Bremer Straße / Hafenstraße / Hansaring',
			'Albersloher Weg / Bernhard-Ernst-Straße / Hafenstraße',
		],
	},
	// two junctions with identical streets
	{ streets: ['Albersloher Weg / Umgehungsstraße'] },
	{
		streets: [
			'Gartenstraße / Lublinring / Niedersachsenring',
			'Gartenstraße / Lublinring',
		],
	},
	{
		streets: [
			'Lazarettstraße / Neutor / Steinfurter Straße / Wilhelmstraße',
			'Steinfurter Straße / Wilhelmstraße',
		],
	},
	// Bremer Platz wraps around its car park and meets Wolbecker Straße twice
	{
		streets: ['Bremer Platz / Schaumburgstraße / Wolbecker Straße'],
		label: 'Wolbecker Straße / Schaumburgstraße',
	},
	{
		streets: ['Bremer Platz / Sauerländer Weg / Wolbecker Straße'],
		label: 'Wolbecker Straße / Sauerländer Weg',
	},
]
