// SPDX-License-Identifier: AGPL-3.0-or-later

// _/\/\/\/\/\/\__/\/\________________________/\/\/\/\/\____/\/\____________________________________________/\/\______/\/\__________________________/\/\________/\/\___________________________
// _____/\/\______/\/\__________/\/\/\________/\/\____/\/\__/\/\______/\/\/\______/\/\/\____/\/\/\/\________/\/\/\__/\/\/\__/\/\/\________/\/\/\/\__/\/\________________/\/\/\/\______/\/\/\___
// _____/\/\______/\/\/\/\____/\/\/\/\/\______/\/\/\/\/\____/\/\____/\/\/\/\/\__/\/\/\/\/\__/\/\__/\/\______/\/\/\/\/\/\/\______/\/\____/\/\________/\/\/\/\____/\/\____/\/\__/\/\__/\/\/\/\/\_
// _____/\/\______/\/\__/\/\__/\/\____________/\/\____/\/\__/\/\____/\/\________/\/\________/\/\/\/\________/\/\__/\__/\/\__/\/\/\/\____/\/\________/\/\__/\/\__/\/\____/\/\__/\/\__/\/\_______
// _____/\/\______/\/\__/\/\____/\/\/\/\______/\/\/\/\/\____/\/\/\____/\/\/\/\____/\/\/\/\__/\/\____________/\/\______/\/\__/\/\/\/\/\____/\/\/\/\__/\/\__/\/\__/\/\/\__/\/\__/\/\____/\/\/\/\_
// _________________________________________________________________________________________/\/\_______________________________________________________________________________________________

// The Bleep Machine Generates Music From Ethereum Bytecode.

// Try the following:
// cast call --rpc-url https://rpc.bleeps.art machine.bleeps.eth "WAV(bytes,uint256,uint256)(bytes)" 0x808060081c9160091c600e1661ca98901c600f160217  0 100000 | xxd -r -p | aplay
// Note: this requires cast (see: https://github.com/foundry-rs) + aplay + xxd + a working ethereum rpc node.

// Copyright (C) 2022 Ronan Sandford

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.16;

error MusicByteCodeTooLarge();
error MusicContractCreationFailure();
error MusicExecutionFailure();

contract TheBleepMachine {
	/// @notice Generates a WAV file (8 bits, 8000Hz, mono) from EVM bytecode (`musicBytecode`) with a specific offset and length.
	/// @param musicBytecode the evm bytecode that the Bleep Machine will execute in a loop.
	/// @param start sample offset at which the music starts.
	/// @param length the number of samples to generate.
	/// @return WAV file (8 bits, 8000Hz, mono).
	function WAV(
		bytes memory musicBytecode,
		uint256 start,
		uint256 length
	) external returns (bytes memory) {
		return _wrapInWAV(generate(musicBytecode, start, length));
	}

	/// @notice Generates raw 8 bits samples from EVM bytecode (`musicBytecode`) with a specific offset and length.
	/// @param musicBytecode the evm bytecode that the Bleep Machine will execute in a loop.
	/// @param start sample offset at which the music starts.
	/// @param length the number of samples to generate.
	/// @return 8bit samples buffer.
	function generate(
		bytes memory musicBytecode,
		uint256 start,
		uint256 length
	) public returns (bytes memory) {
		// We create the contract from the music bytecode.
		address executor = _create(musicBytecode);

		// Execute a call on the generated contract with the start and length specified.
		// If the music bytecode behaves, it will create a buffer of length `length`.
		(bool success, bytes memory buffer) = executor.staticcall(
			abi.encode((start & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | (length << 128))
		);

		// If there is any error, we revert.
		if (!success) {
			revert MusicExecutionFailure();
		}

		return buffer;
	}

	// ----------------------------------------------------------------------------------------------------------------
	// INTERNAL
	// ----------------------------------------------------------------------------------------------------------------

	/// @dev Creates a new contract that generate the music from a given start offset and length.
	/// @param musicBytecode the evm bytecode the Bleep Machine will execute in a loop.
	/// @return executor address of the contract that will generate samples when executed.
	function _create(bytes memory musicBytecode) public returns (address executor) {
		// This code generates a contract creation-code that loops over the provided `musicBytecode`.

		// 61006d600081600b8239f3 => simply copy the code after it.

		// 6000358060801b806000529060801c60205260006040525b => prepare the data
		// In particular it parse the calldata to extract start and length parameters (Stored in 128bit each)
		// it then ensure that starting time is on top of the stack before the loop start
		// the last `5b` is a JUMPDEST that will be jump to each time

		// 60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3
		// => performs the loop and when it ends (start + time >= length), it copy the generate buffer in return data

		bytes memory executorCreation = bytes.concat(
			hex"61006d600081600b8239f36000358060801b806000529060801c60205260006040525b",
			musicBytecode,
			hex"60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3"
		);
		uint256 len = musicBytecode.length;

		// We make sure the generated code length can be encoded in the PUSH2.
		uint256 codeLen;
		unchecked {
			codeLen = 0x4d + len;
		}
		if (codeLen > 0xFFFF) {
			revert MusicByteCodeTooLarge();
		}

		// We store the generated creationCode length so that the creationCode work with its new length.
		assembly {
			mstore8(add(executorCreation, 33), shr(8, codeLen))
			mstore8(add(executorCreation, 34), and(codeLen, 0xFF))
		}

		// We create the contract.
		assembly {
			executor := create(0, add(executorCreation, 32), mload(executorCreation))
		}

		// If there is any error, we revert.
		if (executor == address(0)) {
			revert MusicContractCreationFailure();
		}
	}

	/// @dev Prepends the WAV file header for 8 bits samples at 8000Hz, mono sounds.
	/// @param samples 8 bits samples representing 8000Hz, mono sounds.
	/// @return WAV file (8 bits, 8000Hz, mono) made of the samples given.
	function _wrapInWAV(bytes memory samples) internal pure returns (bytes memory) {
		// WAV file header, 8 bits, 8000Hz, mono, empty length.
		bytes
			memory dynHeader = hex"524946460000000057415645666d74201000000001000100401f0000401f0000010008006461746100000000";

		uint256 length = samples.length;
		assembly {
			// Top header length is length of data + 36 bytes.
			// More precisely: (4 + (8 + SubChunk1Size) + (8 + SubChunk2Size)).
			// Where SubChunk1Size is 16 (for PCM) and SubChunk2Size is the length of the data.
			let t := add(length, 36)

			// We write that length info in the top header (in little endian).
			mstore8(add(dynHeader, 36), and(t, 0xFF))
			mstore8(add(dynHeader, 37), and(shr(8, t), 0xFF))
			mstore8(add(dynHeader, 38), and(shr(16, t), 0xFF))

			// We also write the exact data length just before the data stream as per WAV file format spec (in little endian).
			mstore8(add(dynHeader, 72), and(length, 0xFF))
			mstore8(add(dynHeader, 73), and(shr(8, length), 0xFF))
			mstore8(add(dynHeader, 74), and(shr(16, length), 0xFF))
		}

		// We concatenate the samples buffer we got from computing the music with the header above.
		return bytes.concat(dynHeader, samples);
	}
}
