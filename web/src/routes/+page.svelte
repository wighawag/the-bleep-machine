<script lang="ts">
	import { flow } from '$lib/blockchain/wallet';
	import WalletAccess from '$lib/blockchain/WalletAccess.svelte';
	import { JsonRpcProvider } from '@ethersproject/providers';
	import { Contract } from '@ethersproject/contracts';
	import { contractsInfos } from '$lib/blockchain/contracts';
	import { get } from 'svelte/store';

	let music: string | undefined;
	let algorithm: string = '';
	async function play() {
		const provider = new JsonRpcProvider('http://localhost:8545');
		const contracts = get(contractsInfos);
		const contract = new Contract(
			contracts.contracts.AlgorithmicMusic.address,
			contracts.contracts.AlgorithmicMusic.abi,
			provider
		);
		const result = await contract.callStatic.play('0x8060081c9016', 0, 4000);
		// const result = await contract.callStatic.tokenURI(contracts.contracts.Executor.address);
		// console.log(result);
		const metadata = await fetch(result).then((v) => v.json());
		// console.log(metadata.animation_url);
		music = metadata.animation_url;
		// await flow.execute(async (contracts) => {
		// 	const result = contracts?.AlgorithmicMusic.play('0x8060081c9016', 0, 4000);
		// 	console.log(result);
		// });
	}

	async function mint() {}
</script>

<WalletAccess>
	<textarea value={algorithm} rows="4" cols="50" placeholder="Type your code" />
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
