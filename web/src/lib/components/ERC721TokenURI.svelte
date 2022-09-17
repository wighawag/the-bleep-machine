<script lang="ts">
	import { contractsInfos } from '$lib/blockchain/contracts';
	import { chain, fallback, wallet } from '$lib/blockchain/wallet';
	import { onDestroy, onMount } from 'svelte';
	import { Contract } from '@ethersproject/contracts';

	export let contractAddress: string;
	export let tokenID: string;

	let imgURI: string | undefined;

	function wait(sec: number): Promise<void> {
		return new Promise((resolve) => {
			setTimeout(resolve, sec * 1000);
		});
	}

	function refresh() {
		const provider = wallet.provider || fallback.provider;
		if (provider) {
			console.log('refreshing...');
			const contract = new Contract(
				contractAddress,
				[
					{
						inputs: [
							{
								internalType: 'uint256',
								name: 'tokenId',
								type: 'uint256'
							}
						],
						name: 'tokenURI',
						outputs: [
							{
								internalType: 'string',
								name: '',
								type: 'string'
							}
						],
						stateMutability: 'pure',
						type: 'function'
					}
				],
				provider
			);
			contract.callStatic.tokenURI(tokenID, { blockTag: 'latest' }).then((uri) => {
				return fetch(uri)
					.then((response) => response.json())
					.then((json) => json.image)
					.then((img) => {
						imgURI = img;
					});
			});
		} else {
			console.log(`no provider`);
		}
	}

	$: {
		if (
			($contractsInfos.contracts.AlgorithmicMusic && $wallet.state === 'Ready') ||
			$fallback.state === 'Ready' ||
			$chain.state === 'Ready'
		) {
			refresh();
		} else {
			console.log({
				wallet: $wallet.state,
				fallback: $fallback.state
			});
		}
	}

	let timeout: NodeJS.Timeout | undefined;
	function refreshAgainAndAgain() {
		refresh();
		timeout = setTimeout(refreshAgainAndAgain, 1000);
	}
	onMount(() => {
		refreshAgainAndAgain();
	});
	onDestroy(() => {
		if (timeout) {
			clearTimeout(timeout);
			timeout = undefined;
		}
	});
</script>

{#if imgURI}
	<img src={imgURI} alt={`${contractAddress}:${tokenID}`} />
{:else}
	Loading...
{/if}
