import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {getChainId} from 'hardhat';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const {deployments, getNamedAccounts} = hre;
	const {deploy} = deployments;

	const {deployer} = await getNamedAccounts();

	const chainId = await getChainId();
	const dev = chainId != '1'; //!hre.network.live; // TODO use tag

	await deploy('TheBleepMachine', {
		from: deployer,
		log: true,
		proxy: dev ? 'postUpgrade' : false,
		autoMine: true,
		skipIfAlreadyDeployed: !dev
	});
};
export default func;
func.tags = ['BleepBeats', 'BleepBeats_deploy'];
