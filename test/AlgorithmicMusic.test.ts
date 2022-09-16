import {expect} from './chai-setup';
import {ethers, deployments, getUnnamedAccounts} from 'hardhat';
import {setupUsers} from './utils/users';
import {AlgorithmicMusic} from '../typechain';

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
		await expect(state.users[0].AlgorithmicMusic.mint(state.users[0].address, '0xBBBBCC')).to.emit(
			state.AlgorithmicMusic,
			'Transfer'
		);
	});
});
