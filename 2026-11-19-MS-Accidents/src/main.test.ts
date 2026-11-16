import { execFileSync } from 'node:child_process'
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { before, test } from 'node:test'

const ROOT = join(import.meta.dirname, '..')
const OUTPUTS = ['table_top20.csv', 'map_junctions.csv']

// main.ts runs as a black box, so refactors can't break the test itself.
// It needs the cached files in data/
before(() => {
	execFileSync(process.execPath, ['src/main.ts'], {
		cwd: ROOT,
		stdio: ['ignore', 'ignore', 'inherit'],
	})
})

for (const file of OUTPUTS) {
	test(file, (context) => {
		context.assert.snapshot(readFileSync(join(ROOT, 'output', file), 'utf8'))
	})
}
