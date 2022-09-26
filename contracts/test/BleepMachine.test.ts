import {expect} from './chai-setup';
import {ethers, deployments, getUnnamedAccounts} from 'hardhat';
import {setupUsers} from './utils/users';
import {BleepMachine} from '../typechain';
import {computeNextContractAddress} from '../utils/ethereum';
import {AddressZero} from '@ethersproject/constants';
import {execSync} from 'child_process';

const setup = deployments.createFixture(async () => {
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

describe('BleepMachine', function () {
	it('works', async function () {
		const state = await setup();
		const expectedID = await computeNextContractAddress(state.BleepMachine.address);
		await expect(state.users[0].BleepMachine.mint(state.users[0].address, '0x8060081c9016'))
			.to.emit(state.BleepMachine, 'Transfer')
			.withArgs(AddressZero, state.users[0].address, expectedID);

		const uri = await state.BleepMachine.tokenURI(expectedID);
		const preludeLength = `data:application/json,`.length;
		const metadata = JSON.parse(uri.substring(preludeLength).replace('%20', ' '));
		console.log(`echo ${metadata.animation_url} | base64 -d | aplay`);
	});

	it('works with play', async function () {
		const state = await setup();

		const result = await state.BleepMachine.callStatic.play('0x8060081c9016', 0, 128003);
		console.log(result);
	});

	it('gas: play', async function () {
		const state = await setup();

		const result = await state.BleepMachine.estimateGas.play('0x8060081c9016', 0, 128003, {gasLimit: 30000000});
		console.log(result.toNumber());
	});

	it('gas: tx submitted play', async function () {
		const state = await setup();

		const receipt = await state.users[0].BleepMachine.play('0x8060081c9016', 0, 128003, {gasLimit: 10000000}).then(
			(tx) => tx.wait()
		);
		console.log(receipt.gasUsed.toNumber());
	});

	it('gas: tokenURI', async function () {
		const state = await setup();

		const expectedID = await computeNextContractAddress(state.BleepMachine.address);
		await expect(state.users[0].BleepMachine.mint(state.users[0].address, '0x8060081c9016'));
		const result = await state.BleepMachine.estimateGas.tokenURI(expectedID, {gasLimit: 30000000});
		console.log(result.toNumber());
	});
});
