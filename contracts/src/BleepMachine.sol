// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC721/implementations/ERC721WithAdminRoles.sol";
import "./ERC721/ERC4494/implementations/UsingERC4494PermitWithDynamicChainId.sol";
import "./Multicall/UsingMulticall.sol";

contract BleepMachine is ERC721WithAdminRoles, UsingERC4494PermitWithDynamicChainId, UsingMulticall {

    /// @dev Setup the roles
    /// @param ens ENS address for the network the contract is deployed to
    /// @param initialOwner address that can set the ENS name of the contract and that can witthdraw ERC20 tokens sent by mistake here.
    /// @param initialTokenURIAdmin admin able to update the tokenURI contract.
    /// @param initialMinterAdmin admin able to set the minter contract.
    /// @param initialRoyaltyAdmin admin able to update the royalty receiver and rates.
    /// @param initialGuardian guardian able to immortalize rules
    /// @param initialRoyaltyReceiver receiver of royalties
    /// @param imitialRoyaltyPer10Thousands amount of royalty in 10,000 basis point
    /// @param initialTokenURIContract initial tokenURI contract that generate the metadata including the wav file.
    constructor(
        address ens,
        address initialOwner,
        address initialTokenURIAdmin,
        address initialMinterAdmin,
        address initialRoyaltyAdmin,
        address initialGuardian,
        address initialRoyaltyReceiver,
        uint96 imitialRoyaltyPer10Thousands,
        ITokenURI initialTokenURIContract
    ) ERC721WithAdminRoles(ens, initialOwner, initialTokenURIAdmin, initialMinterAdmin, initialRoyaltyAdmin, initialGuardian, initialRoyaltyReceiver, imitialRoyaltyPer10Thousands, initialTokenURIContract) {

    }

     /// @notice A descriptive name for a collection of NFTs in this contract.
    function name() public pure override returns (string memory) {
        return "The Bleep Machine";
    }

    /// @notice An abbreviated name for NFTs in this contract.
    function symbol() external pure returns (string memory) {
        return "EVM";
    }


     function supportsInterface(bytes4 id) public view virtual override(ERC721WithAdminRoles, UsingERC4494Permit) returns (bool) {
        return super.supportsInterface(id);
    }

}
