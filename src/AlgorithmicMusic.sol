// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC721Base.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "hardhat-deploy/solc_0.8/proxy/Proxied.sol";

contract AlgorithmicMusic is ERC721Base, IERC721Metadata, Proxied {
	bytes internal constant TEMPLATE =
		"data:application/json,{\"name\":\"Mandala%200x0000000000000000000000000000000000000000\",\"description\":\"A%20Unique%20Mandala\",\"image\":\"data:image/svg+xml,<svg%20xmlns='http://www.w3.org/2000/svg'%20shape-rendering='crispEdges'%20width='512'%20height='512'><g%20transform='scale(64)'><image%20width='8'%20height='8'%20style='image-rendering:pixelated;'%20href='data:image/gif;base64,R0lGODdhEwATAMQAAAAAAPb+Y/7EJfN3NNARQUUKLG0bMsR1SujKqW7wQwe/dQBcmQeEqjDR0UgXo4A0vrlq2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkKAAAALAAAAAATABMAAAdNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA6gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGBADs='/></g></svg>\"}";

	constructor() {
		postUpgrade();
	}

	function postUpgrade() public proxied {}

	/// @notice A descriptive name for a collection of NFTs in this contract
	function name() external pure override returns (string memory) {
		return "Algorithmic Music";
	}

	/// @notice An abbreviated name for NFTs in this contract
	function symbol() external pure override returns (string memory) {
		return "AM";
	}

	function tokenURI(uint256 id) public view virtual override returns (string memory) {
		address owner = _ownerOf(id);
		// require(owner != address(0), "NOT_EXISTS");
		return _tokenURI(id);
	}

	function mint(address to, bytes memory algorithm) external payable returns (uint256) {
		// TODO

		uint256 id = uint256(keccak256(algorithm));
		_mint(id, to);
		return id;
	}

	// solhint-disable-next-line code-complexity
	function _tokenURI(uint256 id) internal pure returns (string memory) {
		return "dsdsd";
	}
}
