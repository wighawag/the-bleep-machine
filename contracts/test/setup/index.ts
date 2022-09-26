import {ethers, deployments, getUnnamedAccounts} from 'hardhat';
import {setupUsers} from '../utils/users';
import {BleepBeats} from '../../typechain';

export const setup = deployments.createFixture(async () => {
	await deployments.fixture('BleepBeats');
	const contracts = {
		BleepBeats: <BleepBeats>await ethers.getContract('BleepBeats')
	};
	const users = await setupUsers(await getUnnamedAccounts(), contracts);

	return {
		...contracts,
		users
	};
});

export type Setup = Awaited<ReturnType<typeof setup>>;
