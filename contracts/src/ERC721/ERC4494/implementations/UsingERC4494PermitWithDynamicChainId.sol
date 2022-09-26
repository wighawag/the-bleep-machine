// SPDX-License-Identifier: AGPL-1.0
pragma solidity 0.8.16;

import "./UsingERC4494Permit.sol";

abstract contract UsingERC4494PermitWithDynamicChainId is UsingERC4494Permit, UsingERC712WithDynamicChainId {
	function DOMAIN_SEPARATOR() public view virtual override returns (bytes32) {
		return _currentDomainSeparator();
	}
}
