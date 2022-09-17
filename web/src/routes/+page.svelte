<script lang="ts">
	import { chain, fallback, flow, wallet } from '$lib/blockchain/wallet';
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
	let musicBytecode: string | undefined;
	async function play() {
		if (algorithm.startsWith('ASM\n')) {
			const ast = (window as any).asm.parse(algorithm.slice(4));
			musicBytecode = await (window as any).asm.assemble(ast, {});
		} else {
			musicBytecode = generateBytecode(algorithm);
		}

		console.log({ musicBytecode });

		// const provider = new JsonRpcProvider('http://localhost:8545');
		// const contracts = get(contractsInfos);
		// const contract = new Contract(
		// 	contracts.contracts.AlgorithmicMusic.address,
		// 	contracts.contracts.AlgorithmicMusic.abi,
		// 	provider
		// );
		// const result = await contract.callStatic.play(musicBytecode, 0, 128003);
		// music = result;
		// const result = await contract.callStatic.tokenURI(contracts.contracts.Executor.address);
		// const metadata = await fetch(result).then((v) => v.json());
		// music = metadata.animation_url;

		if (!wallet.contracts && fallback.provider) {
			const AlgorithmMusic = $contractsInfos.contracts.AlgorithmicMusic;
			const contract = new Contract(AlgorithmMusic.address, AlgorithmMusic.abi, fallback.provider);
			const result = await contract.callStatic.play(musicBytecode, 0, 128003);
			music = result;
		} else {
			await flow.execute(async (contracts) => {
				const result = await contracts.AlgorithmicMusic.callStatic.play(musicBytecode, 0, 128003);
				music = result;
				// console.log(result);
			});
		}
	}

	async function mint() {
		if (wallet.contracts) {
			wallet.contracts.AlgorithmicMusic.mint($wallet.address, musicBytecode);
		} else {
			await flow.execute(async (contracts) => {
				contracts.AlgorithmicMusic.mint($wallet.address, musicBytecode);
			});
		}
	}
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
	{#if musicBytecode}
		<button on:click={() => mint()}>mint</button>
	{/if}
	<button on:click={() => play()}>play</button>
{/if}

<style>
	textarea {
		display: block;
	}
</style>
