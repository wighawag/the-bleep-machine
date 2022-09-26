// SPDX-License-Identifier: AGPL-1.0
pragma solidity 0.8.16;

abstract contract ImplementingERC721Internal {
	function _ownerAndBlockNumberOf(uint256 id) internal view virtual returns (address owner, uint256 blockNumber);

    function _approveFor(
        address owner,
        uint256 blockNumber,
        address operator,
        uint256 id
    ) internal virtual;


    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal virtual;


    function supportsInterface(bytes4) public view virtual returns(bool) {return false;}

}
