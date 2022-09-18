import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {getChainId} from 'hardhat';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const {deployments, getNamedAccounts} = hre;
	const {deploy} = deployments;

	const {deployer} = await getNamedAccounts();

	const chainId = await getChainId();
	const dev = chainId != '1'; //!hre.network.live; // TODO use tag

	await deploy('AlgorithmicMusic', {
		from: deployer,
		log: true,
		proxy: dev ? 'postUpgrade' : false,
		autoMine: true,
		skipIfAlreadyDeployed: hre.network.live
	});

	// if (!hre.network.live) {
	// 	try {
	// 		await execute(
	// 			'AlgorithmicMusic',
	// 			{from: deployer, log: true},
	// 			'mint',
	// 			deployer,
	// 			'0x808060081c9160091c600e1661ca98901c600f160217'
	// 		);
	// 	} catch (err) {
	// 		console.error(err);
	// 	}
	// }
};
export default func;
func.tags = ['AlgorithmicMusic', 'AlgorithmicMusic_deploy'];
