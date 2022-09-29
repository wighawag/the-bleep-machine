import {deployments, ethers, getNamedAccounts} from 'hardhat';
import {TheBleepMachine} from '../typechain';

async function main() {
	const {deployer} = await getNamedAccounts();

	const TheBleepMachine = await ethers.getContract<TheBleepMachine>('TheBleepMachine', deployer);

	const musicBytecode = '0x808060081c9160091c600e1661ca98901c600f160217';
	const start = 0;
	const length = 100000;
	const estimate = await TheBleepMachine.estimateGas.WAV(musicBytecode, start, length, {gasLimit: 30000000});
	console.log({gasEstimate: estimate.toString()});

	const tx = await TheBleepMachine.WAV(musicBytecode, start, length, {
		gasLimit: estimate.add(100000)
	});
	console.log({tx: tx.hash});
	const receipt = await tx.wait();

	console.log({gas: receipt.gasUsed.toString()});
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
