import {expect} from './chai-setup';
import {ethers, deployments, getUnnamedAccounts} from 'hardhat';
import {setupUsers} from './utils/users';
import {AlgorithmicMusic} from '../typechain';
import {computeNextContractAddress} from '../utils/ethereum';
import {AddressZero} from '@ethersproject/constants';
import {execSync} from 'child_process';

const setup = deployments.createFixture(async () => {
	await deployments.fixture('AlgorithmicMusic');
	const contracts = {
		AlgorithmicMusic: <AlgorithmicMusic>await ethers.getContract('AlgorithmicMusic')
	};
	const users = await setupUsers(await getUnnamedAccounts(), contracts);
	return {
		...contracts,
		users
	};
});

describe('AlgorithmicMusic', function () {
	it('works', async function () {
		const state = await setup();
		const expectedID = await computeNextContractAddress(state.AlgorithmicMusic.address);
		await expect(state.users[0].AlgorithmicMusic.mint(state.users[0].address, '0x8060081c9016'))
			.to.emit(state.AlgorithmicMusic, 'Transfer')
			.withArgs(AddressZero, state.users[0].address, expectedID);

		const uri = await state.AlgorithmicMusic.tokenURI(expectedID);
		const preludeLength = `data:application/json,`.length;
		const metadata = JSON.parse(uri.substring(preludeLength).replace('%20', ' '));
		console.log(`echo ${metadata.animation_url} | base64 -d | aplay`);
	});

	it('works with play', async function () {
		const state = await setup();

		const result = await state.AlgorithmicMusic.callStatic.play('0x8060081c9016', 0, 128003);
		console.log(result);
	});
});
