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
    bytes constant DEFAULT_PARAMS = hex"000000000000000000000000000186A000000000000000000000000000000000";

    bytes32 constant HEX = "0123456789abcdef0000000000000000";

	constructor() {
		postUpgrade(); //proxied for hot reload
	}
    function postUpgrade() public proxied {} //proxied for hot reload


    // TODO get rid of it
    mapping(uint256 => bytes32) musicByteCodes;


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

        // TODO get rid of it
        bytes32 b;
        assembly {
            b := mload(add(musicBytecode,32))
        }
        musicByteCodes[executor] = b;
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


	function _tokenURI(uint256 id) internal view returns (string memory str) {
        (, bytes memory buffer) = address(uint160(id)).staticcall(DEFAULT_PARAMS);

		str =
			string(
				bytes.concat(
					'data:application/json,{"name":"The%20Bleep%20Machine","description":"The%20Bleep%20Machine%20produces%20music%20from%20EVM%20bytecode.","external_url":"TODO","image":"',
					"data:image/svg+xml;charset=utf8,<svg%2520xmlns='http://www.w3.org/2000/svg'%2520shape-rendering='crispEdges'%2520width='512'%2520height='512'><style>.b{animation:ba%25201s%2520steps(5,start)%2520infinite;-webkit-animation:ba%25201s%2520steps(5,start)%2520infinite;}@keyframes%2520ba{to{visibility: hidden;}}@-webkit-keyframes%2520ba{to{visibility:hidden;}}.b5{ animation-delay:.5s}.b7{animation-delay:.7s}</style><defs><path%2520id='Z'%2520d='M0,0h1v1h-1z'/><use%2520id='0'%2520href='%2523Z'%2520fill='%2523000c24'/><use%2520id='1'%2520href='%2523Z'%2520fill='%25239e0962'/><use%2520id='2'%2520href='%2523Z'%2520fill='%2523ff1c3a'/><use%2520id='3'%2520href='%2523Z'%2520fill='%2523bc0b22'/><use%2520id='4'%2520href='%2523Z'%2520fill='%2523ff991c'/><use%2520id='5'%2520href='%2523Z'%2520fill='%2523c16a00'/><use%2520id='6'%2520href='%2523Z'%2520fill='%2523ffe81c'/><use%2520id='7'%2520href='%2523Z'%2520fill='%25239e8b00'/><use%2520id='8'%2520href='%2523Z'%2520fill='%252323e423'/><use%2520id='9'%2520href='%2523Z'%2520fill='%2523009900'/><use%2520id='a'%2520href='%2523Z'%2520fill='%25231adde0'/><use%2520id='b'%2520href='%2523Z'%2520fill='%2523008789'/><use%2520id='c'%2520href='%2523Z'%2520fill='%25233d97ff'/><use%2520id='d'%2520href='%2523Z'%2520fill='%25233e5ca0'/><use%2520id='e'%2520href='%2523Z'%2520fill='%2523831bf9'/><use%2520id='f'%2520href='%2523Z'%2520fill='%2523522982'/></defs><g%2520transform='scale(64)'><use%2520x='00'%2520class='b%2520b0'%2520y='00'%2520href='%25230'/><use%2520x='01'%2520y='00'%2520href='%25230'/><use%2520x='02'%2520y='00'%2520href='%25230'/><use%2520x='03'%2520y='00'%2520href='%25230'/><use%2520x='04'%2520y='00'%2520href='%25230'/><use%2520x='05'%2520y='00'%2520href='%25230'/><use%2520x='06'%2520y='00'%2520href='%25230'/><use%2520x='07'%2520y='00'%2520href='%25230'/><use%2520x='00'%2520y='01'%2520href='%25230'/><use%2520x='01'%2520y='01'%2520href='%25230'/><use%2520x='02'%2520y='01'%2520href='%25230'/><use%2520x='03'%2520y='01'%2520href='%25230'/><use%2520x='04'%2520y='01'%2520href='%25230'/><use%2520x='05'%2520y='01'%2520href='%25230'/><use%2520x='06'%2520y='01'%2520href='%25230'/><use%2520x='07'%2520y='01'%2520href='%25230'/><use%2520x='00'%2520y='02'%2520href='%25230'/><use%2520x='01'%2520y='02'%2520href='%25230'/><use%2520x='02'%2520y='02'%2520href='%25230'/><use%2520x='03'%2520y='02'%2520href='%25230'/><use%2520x='04'%2520y='02'%2520href='%25230'/><use%2520x='05'%2520y='02'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b5'%2520y='02'%2520href='%25230'/><use%2520x='07'%2520y='02'%2520href='%25230'/><use%2520x='00'%2520y='03'%2520href='%25230'/><use%2520x='01'%2520y='03'%2520href='%25230'/><use%2520x='02'%2520y='03'%2520href='%25230'/><use%2520x='03'%2520y='03'%2520href='%25230'/><use%2520x='04'%2520y='03'%2520href='%25230'/><use%2520x='05'%2520y='03'%2520href='%25230'/><use%2520x='06'%2520y='03'%2520href='%25230'/><use%2520x='07'%2520y='03'%2520href='%25230'/><use%2520x='00'%2520y='04'%2520href='%25230'/><use%2520x='01'%2520y='04'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b7'%2520y='04'%2520href='%25230'/><use%2520x='03'%2520y='04'%2520href='%25230'/><use%2520x='04'%2520y='04'%2520href='%25230'/><use%2520x='05'%2520y='04'%2520href='%25230'/><use%2520x='06'%2520y='04'%2520href='%25230'/><use%2520x='07'%2520y='04'%2520href='%25230'/><use%2520x='00'%2520y='05'%2520href='%25230'/><use%2520x='01'%2520y='05'%2520href='%25230'/><use%2520x='02'%2520y='05'%2520href='%25230'/><use%2520x='03'%2520y='05'%2520href='%25230'/><use%2520x='04'%2520y='05'%2520href='%25230'/><use%2520x='05'%2520y='05'%2520href='%25230'/><use%2520x='06'%2520y='05'%2520href='%25230'/><use%2520x='07'%2520y='05'%2520href='%25230'/><use%2520x='00'%2520y='06'%2520href='%25230'/><use%2520x='01'%2520y='06'%2520href='%25230'/><use%2520x='02'%2520y='06'%2520href='%25230'/><use%2520x='03'%2520y='06'%2520href='%25230'/><use%2520x='04'%2520y='06'%2520href='%25230'/><use%2520x='05'%2520y='06'%2520href='%25230'/><use%2520x='06'%2520y='06'%2520href='%25230'/><use%2520x='07'%2520y='06'%2520href='%25230'/><use%2520x='00'%2520y='07'%2520href='%25230'/><use%2520x='01'%2520y='07'%2520href='%25230'/><use%2520x='02'%2520y='07'%2520href='%25230'/><use%2520x='03'%2520y='07'%2520href='%25230'/><use%2520x='04'%2520y='07'%2520href='%25230'/><use%2520x='05'%2520y='07'%2520href='%25230'/><use%2520x='06'%2520y='07'%2520href='%25230'/><use%2520x='07'%2520y='07'%2520href='%25230'/></g></svg>",
					'","animation_url":"data:audio/wav;base64,UklGRgAAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAA',
					bytes(Base64.encode(buffer)),
					'"}'
				)
			); // 1193, 46


        // TODO get rid of it
        bytes32 musicByteCode = musicByteCodes[id];

        for (uint256 i = 0; i < 64; i +=2) {
            uint256 offset = 0;
            if (i > 4*8+1) {
                 offset = 42;
            } else
             if (i > 2*8+5) {
                offset = 21;
            }
            uint8 v = uint8(musicByteCode[i / 2]);
            bytes(str)[offset + 167 + 1485 + i*46] = HEX[uint8(v >> 4)];
            bytes(str)[offset + 167 + 1485 + 46 + i*46 ] = HEX[uint8(v & 0x0F)];
        }

        // bytes(str)[1193+46] = '5';
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
