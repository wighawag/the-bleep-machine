import {ethers, deployments, getUnnamedAccounts} from 'hardhat';
import {setupUsers} from '../utils/users';
import {AlgorithmicMusic} from '../../typechain';

export const setup = deployments.createFixture(async () => {
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

export type Setup = Awaited<ReturnType<typeof setup>>;
