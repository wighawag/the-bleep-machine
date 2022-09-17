// SPDX-License-Identifier: AGPL-1.0
pragma solidity 0.8.16;

import "./ERC721Base.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "hardhat-deploy/solc_0.8/proxy/Proxied.sol";

// TODO use a more modern ERC721base
contract AlgorithmicMusic is ERC721Base, /*IERC721Metadata*/ Proxied {
    using Strings for uint256;

    // 1F403 = 128003 = 16.000375 seconds
    // 186A258 = 25600600 = 3200.075 seconds
    // offset of 6s :BB80";
    // bytes constant DEFAULT_PARAMS = hex"0000000000000000000000000001F40300000000000000000000000000000000";
    // bytes constant DEFAULT_PARAMS = hex"0000000000000000000000000186A25800000000000000000000000000000000";
    bytes constant DEFAULT_PARAMS = hex"0000000000000000000000000001F40300000000000000000000000000000000";

	constructor() {
		postUpgrade(); //proxied for hot reload
	}
    function postUpgrade() public proxied {} //proxied for hot reload


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

	/// @notice A descriptive name for a collection of NFTs in this contract
	function name() external pure returns (string memory) {
		return "Algorithmic Music";
	}

	/// @notice An abbreviated name for NFTs in this contract
	function symbol() external pure returns (string memory) {
		return "AM";
	}

	function tokenURI(uint256 id) public returns (string memory) {
        // TODO fails on non owner ?
		// address owner = _ownerOf(id);
		return _tokenURI(id);
	}


	function _tokenURI(uint256 id) internal view returns (string memory) {
        (, bytes memory buffer) = address(uint160(id)).staticcall(DEFAULT_PARAMS);

		return
			string(
				bytes.concat(
					'data:application/json,{"name":"Algorithmic%20Music","description":"Onchain%20Algorithmic%20Music","external_url":"TODO","image":"',
					"data:image/svg+xml,<svg%20viewBox='0%200%2032%2016'%20xmlns='http://www.w3.org/2000/svg'><text%20x='50%'%20y='50%'%20dominant-baseline='middle'%20text-anchor='middle'%20style='fill:rgb(219,39,119);font-size:12px;'>",
					bytes(id.toString()),
					"</text></svg>",
					'","animation_url":"data:audio/wav;base64,UklGRgAAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAA',
					bytes(Base64.encode(buffer)),
					'"}'
				)
			);

        // TODO _finishBuffer(bytes(result), 0x1F403);
	}

	function play(
		bytes memory musicBytecode,
		uint256 start,
		uint256 length
	) external returns (string memory) {
        return string(bytes.concat('data:audio/wav;base64,UklGRgAAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAA', _execute(musicBytecode, start, length)));

        // TODO _finishBuffer(bytes(result), 0x1F403);
	}

    function _execute(bytes memory musicBytecode, uint256 start,
		uint256 length) internal returns (bytes memory) {
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

        (bool success, bytes memory buffer) = executor.staticcall(abi.encode(start | (length << 128)));
        require(success, 'CALL_FAILS');

        return bytes(Base64.encode(buffer));
    }
}
