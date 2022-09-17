<script lang="ts">
	import { flow } from '$lib/blockchain/wallet';
	import WalletAccess from '$lib/blockchain/WalletAccess.svelte';
	import { JsonRpcProvider } from '@ethersproject/providers';
	import { Contract } from '@ethersproject/contracts';
	import { contractsInfos } from '$lib/blockchain/contracts';
	import { get } from 'svelte/store';
	import { generateBytecode } from '$lib/asm/evm-parser';
	// import { assemble, parse } from '@ethersproject/asm'; // Does nto work in browser

	let music: string | undefined;
	let algorithm: string = `DUP1
PUSH1 0a
SHR
PUSH1 2a
AND
MUL
`;
	async function play() {
		// const ast = parse(algorithm);
		// const musicBytecode = await assemble(ast);

		const musicBytecode = generateBytecode(algorithm);

		console.log({ musicBytecode });

		const provider = new JsonRpcProvider('http://localhost:8545');
		const contracts = get(contractsInfos);
		const contract = new Contract(
			contracts.contracts.AlgorithmicMusic.address,
			contracts.contracts.AlgorithmicMusic.abi,
			provider
		);
		const result = await contract.callStatic.play(musicBytecode, 0, 128003);
		music = result;
		// const result = await contract.callStatic.tokenURI(contracts.contracts.Executor.address);
		// const metadata = await fetch(result).then((v) => v.json());
		// music = metadata.animation_url;

		// await flow.execute(async (contracts) => {
		// 	const result = contracts?.AlgorithmicMusic.play('0x8060081c9016', 0, 4000);
		// 	console.log(result);
		// });
	}

	async function mint() {}
</script>

<WalletAccess>
	<textarea bind:value={algorithm} rows="30" cols="50" placeholder="Type your code" />
</WalletAccess>

{#if music}
	<audio src={music} autoplay controls />
	<br />
	<button on:click={() => mint()}>mint</button>
	<button on:click={() => (music = undefined)}>clear</button>
{:else}
	<button on:click={() => play()}>play</button>
{/if}

<style>
	textarea {
		display: block;
	}
</style>
