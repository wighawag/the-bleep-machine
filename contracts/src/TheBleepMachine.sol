// SPDX-License-Identifier: AGPL-1.0
pragma solidity 0.8.16;

import "base64-sol/base64.sol";

error MusicByteCodeTooLarge();
error MusicContractCreationFailure();
error MusicExecutionFailure();

contract TheBleepMachine{

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
            hex"61006d600081600b8239f36000358060801b806000529060801c60205260006040525b",
			musicBytecode,
			hex"60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3"
		);
        uint256 len = musicBytecode.length;


        uint256 codeLen;
        unchecked {
            codeLen = 0x4d + len;
        }
        if( codeLen > 0xFFFF) {
            revert MusicByteCodeTooLarge();
        }
        assembly {
            mstore8(add(executorCreation, 33), shr(8, codeLen))
			mstore8(add(executorCreation, 34), and(codeLen, 0xFF))
		}

		address executor;
		assembly {
			executor := create(0, add(executorCreation, 32), mload(executorCreation))
		}

		if(executor == address(0)) {
            revert MusicContractCreationFailure();
        }

		(bool success, bytes memory buffer) = executor.staticcall(abi.encode(start | (length << 128)));
		if (!success) {
            revert MusicExecutionFailure();
        }

		return buffer;
	}
}
