import e18e from '@e18e/eslint-plugin'
import js from '@eslint/js'
import stylistic from '@stylistic/eslint-plugin'
import { defineConfig } from 'eslint/config'
import tseslint from 'typescript-eslint'

export default defineConfig(
	{ ignores: ['data/', 'output/'] },
	js.configs.recommended,
	tseslint.configs.recommended,
	e18e.configs.recommended,
	stylistic.configs.customize({
		indent: 'tab',
		arrowParens: true,
		braceStyle: '1tbs',
		quoteProps: 'as-needed',
	}),
	{
		rules: {
			'@stylistic/max-len': [
				'warn',
				{ code: 80, ignoreStrings: true, ignoreTemplateLiterals: true },
			],
			'@typescript-eslint/naming-convention': [
				'error',
				{ selector: 'default', format: ['snake_case'] },
				{ selector: 'typeLike', format: ['PascalCase'] },
				{ selector: 'parameter', modifiers: ['unused'], format: null },
				{ selector: 'variable', modifiers: ['const'], format: ['snake_case', 'UPPER_CASE'] },
				// config objects
				{ selector: 'objectLiteralProperty', format: ['snake_case', 'camelCase'] },
				{ selector: 'objectLiteralProperty', modifiers: ['requiresQuotes'], format: null },
			],
		},
	},
)
