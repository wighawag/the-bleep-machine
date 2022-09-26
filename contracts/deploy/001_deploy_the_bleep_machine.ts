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

	const imitialRoyaltyPer10Thousands = 50;
	await deploy('BleepMachine', {
		from: deployer,
		log: true,
		args: [
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
func.tags = ['BleepMachine', 'BleepMachine_deploy'];
