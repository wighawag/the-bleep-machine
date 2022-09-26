// SPDX-License-Identifier: AGPL-1.0
pragma solidity 0.8.16;

abstract contract ImplementingExternalDomainSeparator {
	function DOMAIN_SEPARATOR() public view virtual returns (bytes32);
}
