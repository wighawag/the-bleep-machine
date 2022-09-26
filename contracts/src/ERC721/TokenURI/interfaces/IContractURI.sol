// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IContractURI {
	function contractURI(address receiver, uint96 per10Thousands) external view returns (string memory);
}
