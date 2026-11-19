# What are the worst junctions in Münster?

Junctions with the most injury accidents in Münster, 2019–2025

- Input: accident locations from the national Unfallatlas (Statistische Ämter des Bundes und der
  Länder), one file per year from 2019 (the first year with NRW data), and OSM streets.
  - `src/fetch.ts` downloads both to `data/`, keeps only Münster's accidents, and reuses the files on later runs. A newly published year is picked up automatically.
  - Limits: the Unfallatlas only has police-recorded accidents with injuries, no damage-only crashes.
    Counts aren't adjusted for traffic volume, so busy junctions rank high partly because they are busy.
    Accidents more than 30 m from every junction aren't counted.
- Output (in `output/`, generated locally and not committed, since it is third-party data):
  `table_top20.csv` Datawrapper table; the year columns sit side by side for mini charts
  `map_junctions.csv` Datawrapper locator map markers for the table's junctions, with an icon for
  roundabouts, junctions with traffic lights and ones without

Usage:

- `pnpm install`
- `node src/main.ts`
- `REDOWNLOAD_DATA=1 node src/main.ts` downloads everything again instead of using `data/`.- Downloading the OSM streets (first run, or with `REDOWNLOAD_DATA=1`) needs an Overpass server:
  `OVERPASS_URL=https://overpass-api.de/api/interpreter node src/main.ts`

Test: a snapshot test of both outputs. The snapshot is local too, so create it once with
`pnpm test:update` before refactoring, then run `pnpm test`. Both need the cached `data/`.

A junction is where differently named streets meet; an accident counts for a junction if it happened
within 30 m of it. The thresholds are constants at the top of `src/main.ts`. `src/junction_fixes.ts`
merges junctions that OSM splits up and overrides the automatic junction labels, e.g. to give
roundabouts their own name (Ludgerikreisel). A junction counts as having traffic lights if a signal
is within 30 m of it, because OSM usually maps them on the stop lines before the junction.

overpass-api.de is run by FOSSGIS e.V. under their terms of use
(https://www.fossgis.de/arbeitsgruppen/osm-server/nutzungsbedingungen/), which recommend not
hardcoding its URL, so the script has no default server.

Data sources:
Accidents: © Statistische Ämter des Bundes und der Länder, Deutschland, 2026 (Unfallatlas),
Datenlizenz Deutschland – Namensnennung 2.0 (https://www.govdata.de/dl-de/by-2-0)
Streets and junction names (in `output/`): © OpenStreetMap contributors, ODbL
(https://www.openstreetmap.org/copyright). Report errors: https://openstreetmap.org/fixthemap
