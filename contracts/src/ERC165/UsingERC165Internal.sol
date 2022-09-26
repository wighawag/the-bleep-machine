// SPDX-License-Identifier: AGPL-1.0
pragma solidity 0.8.16;

abstract contract UsingERC165Internal {
	function supportsInterface(bytes4) public view virtual returns (bool) {
		return false;
	}
}
