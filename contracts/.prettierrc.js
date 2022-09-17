module.exports = {
	useTabs: true,
	singleQuote: true,
	trailingComma: 'none',
	printWidth: 120,
	bracketSpacing: false,
	overrides: [
		{
			files: '*.sol',
			options: {
				printWidth: 120,
				tabWidth: 4,
				singleQuote: false,
				explicitTypes: 'always'
			}
		}
	],
	plugins: [require.resolve('prettier-plugin-solidity')]
};
