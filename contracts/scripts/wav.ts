// cast call --rpc-url http://localhost:8545 0x334b2aEbA57B01c7cb9E8C78d843Ca642566CFEF "WAV(bytes,uint256,uint256)(bytes)" 0x808060081c9160091c600e1661ca98901c600f160217 60000 60000 | xxd -r -p | aplay

import {execSync} from 'child_process';
import {deployments, ethers, getNamedAccounts} from 'hardhat';
import {TheBleepMachine} from '../typechain';

async function main() {
	const {deployer} = await getNamedAccounts();

	const args = process.argv.slice(2);

	const TheBleepMachine = await ethers.getContract<TheBleepMachine>('TheBleepMachine', deployer);
	const WAV = await TheBleepMachine.callStatic.WAV(
		args[0] || '0x808060081c9160091c600e1661ca98901c600f160217',
		args[1] || 0 /*60000*/,
		args[2] || 100000
	);

	execSync(`xxd -r -p | aplay`, {input: WAV});
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
