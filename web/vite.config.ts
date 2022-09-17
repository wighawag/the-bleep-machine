import { sveltekit } from '@sveltejs/kit/vite';
import type { UserConfig } from 'vite';
import { execSync } from 'child_process';
import fs from 'fs';

let VERSION = `timestamp_${Date.now()}`;
try {
	VERSION = execSync('git rev-parse --short HEAD', { stdio: ['ignore', 'pipe', 'ignore'] })
		.toString()
		.trim();
} catch (e) {
	console.error(e);
}
console.log(`VERSION: ${VERSION}`);

if (!process.env.VITE_CHAIN_ID) {
	try {
		const contractsInfo = JSON.parse(fs.readFileSync('./src/lib/contracts.json', 'utf-8'));
		process.env.VITE_CHAIN_ID = contractsInfo.chainId;
	} catch (e) {
		console.error(e);
	}
}

const config: UserConfig = {
	plugins: [sveltekit()],
	define: {
		__VERSION__: JSON.stringify(VERSION)
	}
};

export default config;
