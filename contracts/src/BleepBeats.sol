// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC721/implementations/ERC721.sol";
import "./ERC721/ERC4494/implementations/UsingERC4494PermitWithDynamicChainId.sol";
import "./Multicall/UsingMulticall.sol";
import "./ERC721/implementations/UsingExternalMinter.sol";
import "./ERC2981/implementations/UsingGlobalRoyalties.sol";
import "./Guardian/implementations/UsingGuardian.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

contract BleepBeats is
	ERC721,
	UsingERC4494PermitWithDynamicChainId,
	UsingMulticall,
	UsingGuardian,
	UsingExternalMinter,
	UsingGlobalRoyalties
{
	/// @dev Setup the roles
	/// @param initialMinterAdmin admin able to set the minter contract.
	/// @param initialRoyaltyAdmin admin able to update the royalty receiver and rates.
	/// @param initialGuardian guardian able to immortalize rules
	/// @param initialRoyaltyReceiver receiver of royalties
	/// @param imitialRoyaltyPer10Thousands amount of royalty in 10,000 basis point
	constructor(
		address initialGuardian,
		address initialMinterAdmin,
		address initialRoyaltyReceiver,
		uint96 imitialRoyaltyPer10Thousands,
		address initialRoyaltyAdmin
	)
		UsingExternalMinter(initialMinterAdmin)
		UsingGlobalRoyalties(initialRoyaltyReceiver, imitialRoyaltyPer10Thousands, initialRoyaltyAdmin)
		UsingGuardian(initialGuardian)
	{}

	/// @notice A descriptive name for a collection of NFTs in this contract.
	function name() public pure override returns (string memory) {
		return "The Bleep Machine";
	}

	/// @notice An abbreviated name for NFTs in this contract.
	function symbol() external pure returns (string memory) {
		return "EVM";
	}

	function supportsInterface(bytes4 id)
		public
		view
		virtual
		override(ERC721, UsingERC4494Permit, UsingGlobalRoyalties)
		returns (bool)
	{
		return super.supportsInterface(id);
	}

	// ----------------------------------------------------------------------------------------------------------------
	// MAGIC
	// ----------------------------------------------------------------------------------------------------------------

	using Strings for uint256;

	// 1F403 = 128003 = 16.000375 seconds
	// 186A258 = 25600600 = 3200.075 seconds
	// offset of 6s :BB80";
	// bytes constant DEFAULT_PARAMS = hex"0000000000000000000000000001F40300000000000000000000000000000000";
	// bytes constant DEFAULT_PARAMS = hex"0000000000000000000000000186A25800000000000000000000000000000000";
	bytes constant DEFAULT_PARAMS = hex"000000000000000000000000000186A000000000000000000000000000000000"; // 100000

	bytes32 constant HEX = "0123456789abcdef0000000000000000";

	// TODO get rid of it
	mapping(uint256 => bytes32) musicByteCodes;

	function mint(address to, bytes memory musicBytecode) external {
		// TODO require(msg.sender == minter, "NOT_AUTHORIZED");
		bytes memory executorCreation = bytes.concat(
			hex"606d600c600039606d6000f36000358060801b806000529060801c60205260006040525b",
			musicBytecode,
			hex"60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3"
		);

		uint256 len = musicBytecode.length;
		uint256 mask = 256**(32 - len) - 1;
		assembly {
			let src := add(musicBytecode, 32)
			let dest := add(executorCreation, 68) // 32 + 36 where JUMPSET start (second one)
			for {

			} gt(len, 31) {
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
			b := mload(add(musicBytecode, 32))
		}
		musicByteCodes[executor] = b;
	}

	function tokenURI(uint256 id) public view override returns (string memory) {
		// TODO fails on non owner ?
		// address owner = _ownerOf(id);
		return _tokenURI(id);
	}

	function _tokenURI(uint256 id) internal view returns (string memory str) {
		(, bytes memory buffer) = address(uint160(id)).staticcall(DEFAULT_PARAMS);

		bytes
			memory header = hex"52494646c486010057415645666d74201000000001000100401f0000401f00000100080064617461a0860100";
		str = string(
			bytes.concat(
				'data:application/json,{"name":"The%20Bleep%20Machine","description":"The%20Bleep%20Machine%20produces%20music%20from%20EVM%20bytecode.","external_url":"TODO","image":"',
				"data:image/svg+xml;charset=utf8,<svg%2520xmlns='http://www.w3.org/2000/svg'%2520shape-rendering='crispEdges'%2520width='512'%2520height='512'><style>*{background-color:white}.b{animation:ba%25201s%2520steps(5,start)%2520infinite;-webkit-animation:ba%25201s%2520steps(5,start)%2520infinite;}@keyframes%2520ba{to{visibility: hidden;}}@-webkit-keyframes%2520ba{to{visibility:hidden;}}.b01{ animation-delay:.031s}.b02{animation-delay:.062s}.b03{animation-delay:.093s}.b04{animation-delay:.124s}.b05{animation-delay:.155s}.b06{animation-delay:.186s}.b07{animation-delay:.217s}.b08{animation-delay:.248s}.b09{animation-delay:.279s}.b10{animation-delay:.310s}.b11{animation-delay:.342s}.b12{animation-delay:.373s}.b13{animation-delay:.403s}.b14{animation-delay:.434s}.b15{animation-delay:.465s}.b16{animation-delay:.496s}.b17{animation-delay:.527s}.b18{animation-delay:.558s}.b19{animation-delay:.589s}.b20{animation-delay:.620s}.b21{animation-delay:.651s}.b22{animation-delay:.682s}.b23{animation-delay:.713s}.b24{animation-delay:.744s}.b25{animation-delay:.775s}.b26{animation-delay:.806s}.b27{animation-delay:.837s}.b28{animation-delay:.868s}.b29{animation-delay:.899s}.b30{animation-delay:.930s}.b31{animation-delay:.961s}.b32{animation-delay:.992s}</style><defs><path%2520id='Z'%2520d='M0,0h1v1h-1z'/><use%2520id='0'%2520href='%2523Z'%2520fill='%2523000c24'/><use%2520id='1'%2520href='%2523Z'%2520fill='%25239e0962'/><use%2520id='2'%2520href='%2523Z'%2520fill='%2523ff1c3a'/><use%2520id='3'%2520href='%2523Z'%2520fill='%2523bc0b22'/><use%2520id='4'%2520href='%2523Z'%2520fill='%2523ff991c'/><use%2520id='5'%2520href='%2523Z'%2520fill='%2523c16a00'/><use%2520id='6'%2520href='%2523Z'%2520fill='%2523ffe81c'/><use%2520id='7'%2520href='%2523Z'%2520fill='%25239e8b00'/><use%2520id='8'%2520href='%2523Z'%2520fill='%252323e423'/><use%2520id='9'%2520href='%2523Z'%2520fill='%2523009900'/><use%2520id='a'%2520href='%2523Z'%2520fill='%25231adde0'/><use%2520id='b'%2520href='%2523Z'%2520fill='%2523008789'/><use%2520id='c'%2520href='%2523Z'%2520fill='%25233d97ff'/><use%2520id='d'%2520href='%2523Z'%2520fill='%25233e5ca0'/><use%2520id='e'%2520href='%2523Z'%2520fill='%2523831bf9'/><use%2520id='f'%2520href='%2523Z'%2520fill='%2523522982'/></defs><g%2520transform='scale(64)'><use%2520x='00'%2520class='b%2520b01'%2520y='00'%2520href='%25230'/><use%2520x='01'%2520y='00'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b02'%2520y='00'%2520href='%25230'/><use%2520x='03'%2520y='00'%2520href='%25230'/><use%2520x='04'%2520class='b%2520b03'%2520y='00'%2520href='%25230'/><use%2520x='05'%2520y='00'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b04'%2520y='00'%2520href='%25230'/><use%2520x='07'%2520y='00'%2520href='%25230'/><use%2520x='00'%2520class='b%2520b05'%2520y='01'%2520href='%25230'/><use%2520x='01'%2520y='01'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b06'%2520y='01'%2520href='%25230'/><use%2520x='03'%2520y='01'%2520href='%25230'/><use%2520x='04'%2520class='b%2520b07'%2520y='01'%2520href='%25230'/><use%2520x='05'%2520y='01'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b08'%2520y='01'%2520href='%25230'/><use%2520x='07'%2520y='01'%2520href='%25230'/><use%2520x='00'%2520class='b%2520b09'%2520y='02'%2520href='%25230'/><use%2520x='01'%2520y='02'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b10'%2520y='02'%2520href='%25230'/><use%2520x='03'%2520y='02'%2520href='%25230'/><use%2520x='04'%2520class='b%2520b11'%2520y='02'%2520href='%25230'/><use%2520x='05'%2520y='02'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b12'%2520y='02'%2520href='%25230'/><use%2520x='07'%2520y='02'%2520href='%25230'/><use%2520x='00'%2520class='b%2520b13'%2520y='03'%2520href='%25230'/><use%2520x='01'%2520y='03'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b14'%2520y='03'%2520href='%25230'/><use%2520x='03'%2520y='03'%2520href='%25230'/><use%2520x='04'%2520class='b%2520b15'%2520y='03'%2520href='%25230'/><use%2520x='05'%2520y='03'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b16'%2520y='03'%2520href='%25230'/><use%2520x='07'%2520y='03'%2520href='%25230'/><use%2520x='00'%2520class='b%2520b17'%2520y='04'%2520href='%25230'/><use%2520x='01'%2520y='04'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b18'%2520y='04'%2520href='%25230'/><use%2520x='03'%2520y='04'%2520href='%25230'/><use%2520x='04'%2520class='b%2520b19'%2520y='04'%2520href='%25230'/><use%2520x='05'%2520y='04'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b20'%2520y='04'%2520href='%25230'/><use%2520x='07'%2520y='04'%2520href='%25230'/><use%2520x='00'%2520class='b%2520b21'%2520y='05'%2520href='%25230'/><use%2520x='01'%2520y='05'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b22'%2520y='05'%2520href='%25230'/><use%2520x='03'%2520y='05'%2520href='%25230'/><use%2520x='04'%2520class='b%2520b23'%2520y='05'%2520href='%25230'/><use%2520x='05'%2520y='05'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b24'%2520y='05'%2520href='%25230'/><use%2520x='07'%2520y='05'%2520href='%25230'/><use%2520x='00'%2520class='b%2520b25'%2520y='06'%2520href='%25230'/><use%2520x='01'%2520y='06'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b26'%2520y='06'%2520href='%25230'/><use%2520x='03'%2520y='06'%2520href='%25230'/><use%2520x='04'%2520class='b%2520b27'%2520y='06'%2520href='%25230'/><use%2520x='05'%2520y='06'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b28'%2520y='06'%2520href='%25230'/><use%2520x='07'%2520y='06'%2520href='%25230'/><use%2520x='00'%2520class='b%2520b29'%2520y='07'%2520href='%25230'/><use%2520x='01'%2520y='07'%2520href='%25230'/><use%2520x='02'%2520class='b%2520b30'%2520y='07'%2520href='%25230'/><use%2520x='03'%2520y='07'%2520href='%25230'/><use%2520x='04'%2520class='b%2520b31'%2520y='07'%2520href='%25230'/><use%2520x='05'%2520y='07'%2520href='%25230'/><use%2520x='06'%2520class='b%2520b32'%2520y='07'%2520href='%25230'/><use%2520x='07'%2520y='07'%2520href='%25230'/></g></svg>",
				'","animation_url":"data:audio/wav;base64,',
				bytes(Base64.encode(bytes.concat(header, buffer))),
				'"}'
			)
		);

		// TODO get rid of it
		bytes32 musicByteCode = musicByteCodes[id];

		for (uint256 i = 0; i < 64; i += 2) {
			uint256 pre = i / 2;
			uint8 v = uint8(musicByteCode[pre]);
			bytes(str)[(pre * 22) + 167 + 2327 + i * 46] = HEX[uint8(v >> 4)];
			bytes(str)[(pre * 22) + 167 + 2327 + 46 + i * 46] = HEX[uint8(v & 0x0F)];
		}
	}

	function play(
		bytes memory musicBytecode,
		uint256 start,
		uint256 length
	) external returns (string memory) {
		bytes
			memory dynHeader = hex"524946460000000057415645666d74201000000001000100401f0000401f0000010008006461746100000000";
		assembly {
			let t := add(length, 36)
			mstore8(add(dynHeader, 36), and(t, 0xFF))
			mstore8(add(dynHeader, 37), and(shr(8, t), 0xFF))
			mstore8(add(dynHeader, 38), and(shr(16, t), 0xFF))

			mstore8(add(dynHeader, 72), and(length, 0xFF))
			mstore8(add(dynHeader, 73), and(shr(8, length), 0xFF))
			mstore8(add(dynHeader, 74), and(shr(16, length), 0xFF))
		}

		return
			string(
				bytes.concat(
					"data:audio/wav;base64,",
					bytes(Base64.encode(bytes.concat(dynHeader, _execute(musicBytecode, start, length))))
				)
			);
	}

	function _execute(
		bytes memory musicBytecode,
		uint256 start,
		uint256 length
	) internal returns (bytes memory) {
		bytes
			memory executorCreation = hex"606d600c600039606d6000f36000358060801b806000529060801c60205260006040525b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3";

		uint256 len = musicBytecode.length;
		uint256 mask = 256**(32 - len) - 1;
		assembly {
			let src := add(musicBytecode, 32)
			let dest := add(executorCreation, 68) // 32 + 36 where JUMPSET start (second one)
			for {

			} gt(len, 31) {
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
		require(success, "CALL_FAILS");

		return buffer;
	}

	function _mint(uint256 id, address to) internal {
		require(to != address(0), "NOT_TO_ZEROADDRESS");
		require(to != address(this), "NOT_TO_THIS");
		address owner = _ownerOf(id);
		require(owner == address(0), "ALREADY_CREATED");
		_safeTransferFrom(address(0), to, id, "");
	}
}
