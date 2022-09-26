import {ethers, deployments, getUnnamedAccounts} from 'hardhat';
import {setupUsers} from '../utils/users';
import {BleepMachine} from '../../typechain';

export const setup = deployments.createFixture(async () => {
	await deployments.fixture('BleepMachine');
	const contracts = {
		BleepMachine: <BleepMachine>await ethers.getContract('BleepMachine')
	};
	const users = await setupUsers(await getUnnamedAccounts(), contracts);

	return {
		...contracts,
		users
	};
});

export type Setup = Awaited<ReturnType<typeof setup>>;
