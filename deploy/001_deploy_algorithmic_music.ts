import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther} from '@ethersproject/units';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const {deployments, getNamedAccounts} = hre;
	const {deploy, execute, log} = deployments;

	const {deployer} = await getNamedAccounts();

	await deploy('AlgorithmicMusic', {
		from: deployer,
		log: true,
		args: [],
		proxy: !hre.network.live ? 'postUpgrade' : false,
		autoMine: true,
		skipIfAlreadyDeployed: hre.network.live
	});

	if (!hre.network.live) {
		await execute('AlgorithmicMusic', {from: deployer, log: true}, 'mint', deployer, '0xbbbb');
	}
};
export default func;
func.tags = ['AlgorithmicMusic', 'AlgorithmicMusic_deploy'];
