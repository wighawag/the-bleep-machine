<script lang="ts">
	import { chain, fallback, flow, wallet } from '$lib/blockchain/wallet';
	import WalletAccess from '$lib/blockchain/WalletAccess.svelte';
	import { JsonRpcProvider } from '@ethersproject/providers';
	import { Contract } from '@ethersproject/contracts';
	import { contractsInfos } from '$lib/blockchain/contracts';
	import { get } from 'svelte/store';
	import { generateBytecode } from '$lib/asm/evm-parser';
	// import { assemble, parse } from '@ethersproject/asm'; // Does nto work in browser

	let error: string | undefined;
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
		try {
			if (algorithm.startsWith('ASM\n')) {
				const ast = (window as any).asm.parse(algorithm.slice(4));
				musicBytecode = await (window as any).asm.assemble(ast, {});
			} else {
				musicBytecode = generateBytecode(algorithm);
			}
		} catch (err: any) {
			error = err.message;
			music = undefined;
			throw err;
		}

		console.log({ musicBytecode });

		// const provider = new JsonRpcProvider('http://localhost:8545');
		// const contracts = get(contractsInfos);
		// const contract = new Contract(
		// 	contracts.contracts.BleepBeats.address,
		// 	contracts.contracts.BleepBeats.abi,
		// 	provider
		// );
		// const result = await contract.callStatic.play(musicBytecode, 0, 128003);
		// music = result;
		// const result = await contract.callStatic.tokenURI(contracts.contracts.Executor.address);
		// const metadata = await fetch(result).then((v) => v.json());
		// music = metadata.animation_url;

		try {
			if (!wallet.contracts && fallback.provider) {
				const BleepBeats = $contractsInfos.contracts.BleepBeats;
				const contract = new Contract(BleepBeats.address, BleepBeats.abi, fallback.provider);
				const result = await contract.callStatic.play(musicBytecode, 0, 100000, {
					// gasLimit: 49000000
				});
				music = result;
			} else {
				await flow.execute(async (contracts) => {
					const result = await contracts.BleepBeats.callStatic.play(musicBytecode, 0, 100000, {
						// gasLimit: 49000000
					});
					music = result;
					// console.log(result);
				});
			}
		} catch (err) {
			error = err.message;
			music = undefined;
			throw err;
		}
	}

	async function mint() {
		if (wallet.contracts) {
			wallet.contracts.BleepBeats.mint($wallet.address, musicBytecode);
		} else {
			await flow.execute(async (contracts) => {
				contracts.BleepBeats.mint($wallet.address, musicBytecode);
			});
		}
	}

	function volume(node: HTMLAudioElement) {
		node.volume = 0.2;
	}
</script>

<a style="top:1em;right:1em;position:absolute;" id="about" href="about/">Info</a>

<WalletAccess>
	<div id="wrapper">
		<h1 id="nft-title">The Bleep Machine</h1>
		<p id="nft-description">The Bleep Machine produces music from EVM bytecode.</p>
		<center>
			<textarea bind:value={algorithm} rows="30" cols="50" placeholder="Type your code" /></center
		>
		<p />

		<button style="margin-bottom: 1rem;" on:click={() => play()}>generate</button><br />

		{#if error}
			<p>
				{error}
			</p>
		{/if}

		{#if music}
			<audio use:volume src={music} autoplay controls />
		{/if}
		<!-- {#if music}
			<audio src={music} autoplay controls />
			<br />
			<button on:click={() => mint()}>mint (on goerli)</button>
			<button on:click={() => (music = undefined)}>clear</button>
			<p>
				Once minted, you can find it on <a
					href="https://testnets.opensea.io/collection/algorithmic-music-juhg3dsjqb"
					target="_blank">opensea</a
				>
			</p>
		{:else}
			{#if musicBytecode}
				<button on:click={() => mint()}>mint (on goerli)</button>
				<p>
					Once minted, you can find it on <a
						href="https://testnets.opensea.io/collection/algorithmic-music-juhg3dsjqb"
						target="_blank">opensea</a
					>
				</p>
			{/if}
			<button on:click={() => play()}>play</button>
		{/if} -->
	</div>
</WalletAccess>

<style>
	textarea {
		display: block;
		font-size: large;
	}

	* {
		background-color: #111111;
		color: wheat;
		margin: 0;
		padding: 0;
		font-family: Hack, monospace;
	}
	p,
	h1 {
		margin: 1em 1em 1em 1em;
	}
	:root {
		--width: 80vw;
	}

	button {
		font-size: 1em;
		border: 0.1em solid;
		padding: 0.3em;
		cursor: pointer;
	}
	#wrapper {
		text-align: center;
		height: 100%;
		margin: 0;
	}

	#nft-title {
		margin-top: 1em;
	}

	#nft-description {
		margin-bottom: 2em;
	}
</style>
