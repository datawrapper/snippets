import csv from 'csv-parser'
import fs from 'node:fs'

export function import_data(file) {
	return new Promise((resolve, reject) => {
		let results = []
		fs.createReadStream(file)
			.pipe(csv())
			.on('data', (data) => {
				results.push(data)
			})
			.on('end', () => {
				resolve(results)
			})
			.on('error', (e) => {
				reject(e)
			})
	})
}

const TAG_PER_ARTIST_FILE_PATH = './tag_per_artist.json'

export function import_tag_per_artist() {
	try {
		return new Map(JSON.parse(fs.readFileSync(TAG_PER_ARTIST_FILE_PATH)))
	} catch {
		return new Map()
	}
}

export function export_tag_per_artist(map) {
	fs.writeFileSync(TAG_PER_ARTIST_FILE_PATH, JSON.stringify([...map]))
}
