import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const {deployments, getNamedAccounts} = hre;
	const {deploy, execute, log} = deployments;

	const {deployer} = await getNamedAccounts();

	await deploy('AlgorithmicMusic', {
		from: deployer,
		log: true,
		proxy: !hre.network.live ? 'postUpgrade' : false,
		autoMine: true,
		skipIfAlreadyDeployed: hre.network.live
	});

	if (!hre.network.live) {
		try {
			await execute('AlgorithmicMusic', {from: deployer, log: true}, 'mint', deployer, '0xbbbb');
		} catch (err) {
			console.error(err);
		}
	}
};
export default func;
func.tags = ['AlgorithmicMusic', 'AlgorithmicMusic_deploy'];