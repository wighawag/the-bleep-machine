import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {getChainId} from 'hardhat';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const {deployments, getNamedAccounts} = hre;
	const {deploy} = deployments;

	const {deployer, initialGuardian, initialRoyaltyReceiver, initialMinterAdmin, initialRoyaltyAdmin} =
		await getNamedAccounts();

	const chainId = await getChainId();
	const dev = chainId != '1'; //!hre.network.live; // TODO use tag

	const TheBleepMachine = await deployments.get('TheBleepMachine');

	const imitialRoyaltyPer10Thousands = 50;
	await deploy('BleepBeats', {
		from: deployer,
		log: true,
		args: [
			TheBleepMachine.address,
			initialGuardian,
			initialMinterAdmin,
			initialRoyaltyReceiver,
			imitialRoyaltyPer10Thousands,
			initialRoyaltyAdmin
		],
		// proxy: dev ? 'postUpgrade' : false,
		autoMine: true,
		skipIfAlreadyDeployed: !dev
	});
};
export default func;
func.tags = ['BleepBeats', 'BleepBeats_deploy'];
func.dependencies = ['TheBleepMachine_deploy'];
