// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./UsingERC721AdminRoles.sol";
import "../../ERC721/implementations/ERC721.sol";
import "../interfaces/ITokenURI.sol";

abstract contract ERC721WithAdminRoles is ERC721, UsingERC721AdminRoles {

    event RoyaltySet(address receiver, uint256 royaltyPer10Thousands);
    event TokenURIContractSet(ITokenURI newTokenURIContract);

    /// @notice the contract that actually generate the sound (and all metadata via the a data: uri via tokenURI call).
    ITokenURI public tokenURIContract;

    struct Royalty {
        address receiver;
        uint96 per10Thousands;
    }

    Royalty internal _royalty;


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
    )
        UsingERC721AdminRoles(ens, initialOwner, initialTokenURIAdmin, initialMinterAdmin, initialRoyaltyAdmin, initialGuardian)
    {
        tokenURIContract = initialTokenURIContract;
        emit TokenURIContractSet(initialTokenURIContract);

        _royalty.receiver = initialRoyaltyReceiver;
        _royalty.per10Thousands = imitialRoyaltyPer10Thousands;
        emit RoyaltySet(initialRoyaltyReceiver, imitialRoyaltyPer10Thousands);
    }

    /// @notice Returns the Uniform Resource Identifier (URI) for the token collection.
    function contractURI() external view returns (string memory) {
        return tokenURIContract.contractURI(_royalty.receiver, _royalty.per10Thousands);
    }

    /// @notice Returns the Uniform Resource Identifier (URI) for token `id`.
    function tokenURI(uint256 id) external view returns (string memory) {
        return tokenURIContract.tokenURI(id);
    }

    /// @notice set a new tokenURI contract, that generate the metadata including the wav file, Can only be set by the `tokenURIAdmin`.
    /// @param newTokenURIContract The address of the new tokenURI contract.
    function setTokenURIContract(ITokenURI newTokenURIContract) external {
        require(msg.sender == tokenURIAdmin, "NOT_AUTHORIZED");
        tokenURIContract = newTokenURIContract;
        emit TokenURIContractSet(newTokenURIContract);
    }

    /// @notice give the list of owners for the list of ids given.
    /// @param ids The list if token ids to check.
    /// @return addresses The list of addresses, corresponding to the list of ids.
    function owners(uint256[] calldata ids) external view returns (address[] memory addresses) {
        addresses = new address[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            addresses[i] = address(uint160(_owners[id]));
        }
    }

    /// @notice Check if the sender approved the operator.
    /// @param owner The address of the owner.
    /// @param operator The address of the operator.
    /// @return isOperator The status of the approval.
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool isOperator)
    {
        return super.isApprovedForAll(owner, operator);
    }

    /// @notice Check if the contract supports an interface.
    /// @param id The id of the interface.
    /// @return Whether the interface is supported.
    function supportsInterface(bytes4 id)
        public
        view
        virtual
        override
        returns (bool)
    {
        return super.supportsInterface(id) || id == 0x2a55205a; /// 0x2a55205a is ERC2981 (royalty standard)
    }

    /// @notice Called with the sale price to determine how much royalty is owed and to whom.
    /// @param //id - the token queried for royalty information.
    /// @param salePrice - the sale price of the token specified by id.
    /// @return receiver - address of who should be sent the royalty payment.
    /// @return royaltyAmount - the royalty payment amount for salePrice.
    function royaltyInfo(uint256 /*id*/, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _royalty.receiver;
        royaltyAmount = (salePrice * uint256(_royalty.per10Thousands)) / 10000;
    }

    /// @notice set a new royalty receiver and rate, Can only be set by the `royaltyAdmin`.
    /// @param newReceiver the address that should receive the royalty proceeds.
    /// @param royaltyPer10Thousands the share of the salePrice (in 1/10000) given to the receiver.
    function setRoyaltyParameters(address newReceiver, uint96 royaltyPer10Thousands) external {
        require(msg.sender == royaltyAdmin, "NOT_AUTHORIZED");
        // require(royaltyPer10Thousands <= 50, "ROYALTY_TOO_HIGH"); ?
        _royalty.receiver = newReceiver;
        _royalty.per10Thousands = royaltyPer10Thousands;
        emit RoyaltySet(newReceiver, royaltyPer10Thousands);
    }

}
