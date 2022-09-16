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

	function uint2str(uint256 num) private pure returns (string memory _uintAsString) {
		unchecked {
			if (num == 0) {
				return "0";
			}

			uint256 j = num;
			uint256 len;
			while (j != 0) {
				len++;
				j /= 10;
			}

			bytes memory bstr = new bytes(len);
			uint256 k = len - 1;
			while (num != 0) {
				bstr[k--] = bytes1(uint8(48 + (num % 10)));
				num /= 10;
			}

			return string(bstr);
		}
	}

	function mint(address to, bytes memory algorithm) external payable returns (uint256) {
		// TODO

		uint256 id = uint256(keccak256(algorithm));
		_mint(id, to);
		return id;
	}

	// solhint-disable-next-line code-complexity
	function _tokenURI(uint256 id) internal pure returns (string memory) {
		bytes memory buffer = ""; // empty wav

		return
			string(
				bytes.concat(
					'data:application/json,{"name":"Algorithmic%20Music","description":"Onchain%20Algorithmic%20Music","external_url":"TODO","image":"',
					"data:image/svg+xml,<svg%20viewBox='0%200%2032%2016'%20xmlns='http://www.w3.org/2000/svg'><text%20x='50%'%20y='50%'%20dominant-baseline='middle'%20text-anchor='middle'%20style='fill:rgb(219,39,119);font-size:12px;'>",
					bytes(uint2str(id)),
					"</text></svg>",
					'","animation_url":"data:audio/wav;base64,UklGRgAAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAA',
					// Base64.encode(buffer),
					buffer,
					'"}'
				)
			);
	}
}
