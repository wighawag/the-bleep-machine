// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "base64-sol/base64.sol";

contract TheBleepMachine {
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

		address executor;
		assembly {
			executor := create(0, add(executorCreation, 32), mload(executorCreation))
		}
		require(executor != address(0), "CREATE_FAILS");

		(bool success, bytes memory buffer) = executor.staticcall(abi.encode(start | (length << 128)));
		require(success, "CALL_FAILS");

		return buffer;
	}
}
