import {deployments, ethers, getNamedAccounts} from 'hardhat';
import {TheBleepMachine} from '../typechain';

async function main() {
	const {execute} = deployments;
	const {deployer} = await getNamedAccounts();

	const TheBleepMachine = await ethers.getContract<TheBleepMachine>('TheBleepMachine', deployer);

	const WAV = await TheBleepMachine.callStatic.WAV(
		'0x808060081c9160091c600e1661ca98901c600f160217',
		0 /*60000*/,
		100000
	);
	console.log((WAV.length - 2) / 2);
	console.log(WAV.slice(0, 128 + 64 + 64 + 2) + '...');

	const SAMPLES = await TheBleepMachine.callStatic.generate(
		'0x808060081c9160091c600e1661ca98901c600f160217',
		0, //60000,
		100000
	);
	console.log((SAMPLES.length - 2) / 2);
	console.log(SAMPLES.slice(0, 128 + 64 + 64 + 2) + '...');

	const SELF = await TheBleepMachine.callStatic.listenTo(TheBleepMachine.address);
	console.log((SELF.length - 2) / 2);
	console.log(SELF.slice(0, 128 + 64 + 64 + 2) + '...');

	const estimate = await TheBleepMachine.estimateGas.WAV(
		'0x808060081c9160091c600e1661ca98901c600f160217',
		0, //60000,
		100000,
		{gasLimit: 30000000}
	);
	console.log({gasEstimate: estimate.toString()});

	const tx = await TheBleepMachine.WAV('0x808060081c9160091c600e1661ca98901c600f160217', 60000, 100000, {
		gasLimit: 20000000
	});
	console.log({tx: tx.hash});
	const receipt = await tx.wait();

	// const tx2 = await TheBleepMachine.listenTo('0x7CC148f3D6Db69154Dc9334eac9a70B00fA2B296', {
	// 	gasLimit: 20000000
	// });
	// console.log({tx2: tx2.hash});
	// await tx2.wait();

	// const receipt = await execute(
	// 	'TheBleepMachine',
	// 	{from: deployer, log: true},
	// 	'WAV',
	// 	'0x808060081c9160091c600e1661ca98901c600f160217',
	// 	0, //60000,
	// 	100000
	// );
	console.log({gas: receipt.gasUsed.toString()});
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
