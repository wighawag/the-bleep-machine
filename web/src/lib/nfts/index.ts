import { chain, wallet } from '$lib/blockchain/wallet';
import { writable } from 'svelte/store';

const store = writable({ step: 'Idle', list: [] });

// TODO
function fetchLatestTokens() {}

chain.subscribe(($chain) => {});

export const nfts = {
	subscribe: store.subscribe
};
