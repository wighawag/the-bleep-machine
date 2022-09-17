// SPDX-License-Identifier: AGPL-1.0
pragma solidity 0.8.16;

import "./ERC721Base.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "base64-sol/base64.sol";
import "hardhat-deploy/solc_0.8/proxy/Proxied.sol";

contract AlgorithmicMusic is ERC721Base, IERC721Metadata, Proxied {
	constructor() {
		postUpgrade();
	}


    function mint(address to, bytes memory musicBytecode) external {
        bytes memory executorCreation = hex"606d600c600039606d6000f36000358060801b806000529060801c60205260006040525b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3";

        uint256 len = musicBytecode.length;
        uint256 mask = 256**(32 - len) - 1;
        assembly {
            let src := add(musicBytecode, 32)
            let dest := add(executorCreation, 68) // 32 + 36 where JUMPSET start (second one)
            for {} gt(len, 31) {
                len := sub(len, 32)
                dest := add(dest, 32)
                src := add(src, 32)
            } {
                mstore(dest, mload(src))
            }

            let srcpart := and(mload(src), not(mask)) // NOTE can remove that step by ensuring the length is a multiple of 32 bytes
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }


        uint256 executor;
        assembly {
            executor := create(0, add(executorCreation, 32), mload(executorCreation))
        }
        require(executor != 0, "CREATE_FAILS");
        _mint(executor, to);
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

	// function play(address contractAddress) external view returns (string memory) {
	// 	return _tokenURI(address(uint160(contractAddress)));
	// }

	function tokenURI(uint256 id) public view virtual override returns (string memory) {
		// address owner = _ownerOf(id);
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

	// function mint(address to, bytes memory algorithm) external payable returns (uint256) {
	// 	// TODO

	// 	uint256 id = uint256(keccak256(algorithm));
	// 	_mint(id, to);
	// 	return id;
	// }

	function _tokenURI(uint256 id) internal view returns (string memory) {
		bytes memory param = hex"0000000000000000000000000001F40300000000000000000000000000000000"; // offset of 6s :BB80";
		(, bytes memory buffer) = address(uint160(id)).staticcall(param);

		return
			string(
				bytes.concat(
					'data:application/json,{"name":"Algorithmic%20Music","description":"Onchain%20Algorithmic%20Music","external_url":"TODO","image":"',
					"data:image/svg+xml,<svg%20viewBox='0%200%2032%2016'%20xmlns='http://www.w3.org/2000/svg'><text%20x='50%'%20y='50%'%20dominant-baseline='middle'%20text-anchor='middle'%20style='fill:rgb(219,39,119);font-size:12px;'>",
					bytes(uint2str(id)),
					"</text></svg>",
					'","animation_url":"data:audio/wav;base64,UklGRgAAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAA',
					bytes(Base64.encode(buffer)),
					'"}'
				)
			);
	}

	function play(
		bytes memory musicBytecode,
		uint256 start,
		uint256 length
	) external returns (string memory) {
		 bytes memory executorCreation = hex"606d600c600039606d6000f36000358060801b806000529060801c60205260006040525b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3";

        uint256 len = musicBytecode.length;
        uint256 mask = 256**(32 - len) - 1;
        assembly {
            let src := add(musicBytecode, 32)
            let dest := add(executorCreation, 68) // 32 + 36 where JUMPSET start (second one)
            for {} gt(len, 31) {
                len := sub(len, 32)
                dest := add(dest, 32)
                src := add(src, 32)
            } {
                mstore(dest, mload(src))
            }

            let srcpart := and(mload(src), not(mask)) // NOTE can remove that step by ensuring the length is a multiple of 32 bytes
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }


        address executor;
        assembly {
            executor := create(0, add(executorCreation, 32), mload(executorCreation))
        }
        require(executor != address(0), "CREATE_FAILS");


        bytes memory param = hex"0000000000000000000000000001F40300000000000000000000000000000000"; // offset of 6s :BB80";
		(, bytes memory buffer) = executor.staticcall(param);

        return
			string(
				bytes.concat('data:audio/wav;base64,UklGRgAAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAA',bytes(Base64.encode(buffer)))
			);
	}
}
