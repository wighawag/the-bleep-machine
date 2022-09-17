import { initWeb3W } from 'web3w';
import { contractsInfos } from '$lib/blockchain/contracts';
import { finality, fallbackProviderOrUrl, chainId, localDev } from '$lib/config';
import { isCorrected, correctTime } from '$lib/time';
import { base } from '$app/paths';
import { chainTempo } from '$lib/blockchain/chainTempo';
import { get } from 'svelte/store';

const walletStores = initWeb3W({
	chainConfigs: get(contractsInfos),
	builtin: { autoProbe: true },
	transactions: {
		autoDelete: false,
		finality
	},
	flow: {
		autoUnlock: true
	},
	autoSelectPrevious: true,
	localStoragePrefix:
		(base && base.startsWith('/ipfs/')) || base.startsWith('/ipns/') ? base.slice(6) : undefined, // ensure local storage is not conflicting across web3w-based apps on ipfs gateways
	options: ['builtin'],
	fallbackNode: fallbackProviderOrUrl,
	checkGenesis: localDev
});

export const { wallet, transactions, builtin, chain, balance, flow, fallback } = walletStores;

chain.subscribe(async (v) => {
	chainTempo.startOrUpdateProvider(wallet.provider);
	if (!isCorrected()) {
		if (v.state === 'Connected' || v.state === 'Ready') {
			const latestBlock = await wallet.provider?.getBlock('latest');
			if (latestBlock) {
				correctTime(latestBlock.timestamp);
			}
		}
	}
});

fallback.subscribe(async (v) => {
	if (!isCorrected()) {
		if (v.state === 'Connected' || v.state === 'Ready') {
			const latestBlock = await wallet.provider?.getBlock('latest');
			if (latestBlock) {
				correctTime(latestBlock.timestamp);
			}
		}
	}
});

// TODO remove
if (typeof window !== 'undefined') {
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	(window as any).walletStores = walletStores;
}

chainTempo.startOrUpdateProvider(wallet.provider);

contractsInfos.subscribe(async ($contractsInfo) => {
	await chain.updateContracts($contractsInfo);
});
