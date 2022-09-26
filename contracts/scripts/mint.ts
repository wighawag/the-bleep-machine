import {BigNumber} from 'ethers';
import {deployments, getNamedAccounts} from 'hardhat';

async function main() {
	const {execute} = deployments;
	const {deployer} = await getNamedAccounts();

	const args = process.argv.slice(2);

	const receipt = await execute('BleepBeats', {from: deployer, log: true}, 'mint', deployer, args[0]);
	const id = (receipt as any).logs[0].topics[3];
	console.log(BigNumber.from(id).toString());
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
