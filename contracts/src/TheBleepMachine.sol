// SPDX-License-Identifier: AGPL-3.0-or-later

// _/\/\/\/\/\/\__/\/\________________________/\/\/\/\/\____/\/\____________________________________________/\/\______/\/\__________________________/\/\________/\/\___________________________
// _____/\/\______/\/\__________/\/\/\________/\/\____/\/\__/\/\______/\/\/\______/\/\/\____/\/\/\/\________/\/\/\__/\/\/\__/\/\/\________/\/\/\/\__/\/\________________/\/\/\/\______/\/\/\___
// _____/\/\______/\/\/\/\____/\/\/\/\/\______/\/\/\/\/\____/\/\____/\/\/\/\/\__/\/\/\/\/\__/\/\__/\/\______/\/\/\/\/\/\/\______/\/\____/\/\________/\/\/\/\____/\/\____/\/\__/\/\__/\/\/\/\/\_
// _____/\/\______/\/\__/\/\__/\/\____________/\/\____/\/\__/\/\____/\/\________/\/\________/\/\/\/\________/\/\__/\__/\/\__/\/\/\/\____/\/\________/\/\__/\/\__/\/\____/\/\__/\/\__/\/\_______
// _____/\/\______/\/\__/\/\____/\/\/\/\______/\/\/\/\/\____/\/\/\____/\/\/\/\____/\/\/\/\__/\/\____________/\/\______/\/\__/\/\/\/\/\____/\/\/\/\__/\/\__/\/\__/\/\/\__/\/\__/\/\____/\/\/\/\_
// _________________________________________________________________________________________/\/\_______________________________________________________________________________________________

// The Bleep Machine Generates Music From Ethereum Bytecode

// Try it.
// Note, this requires [cast](https://github.com/foundry-rs/foundry/tree/master/cast) + a working ethereum rpc node

// cast call --rpc-url https://rpc.bleeps.art machine.bleeps.eth "wav(bytes,uint256,uint256)(bytes)" 0x808060081c9160091c600e1661ca98901c600f160217  0 100000 | xxd -r -p | aplay

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
	/// @notice generate a wav file from EVM bytecode (`musicBytecode`) with a specific offset and length
	/// @param musicBytecode the evm bytecode the Bleep Machine will execute in a loop
	/// @param start sample offset at whcih the music start
	/// @param length the number of sample to generate
	function wav(
		bytes memory musicBytecode,
		uint256 start,
		uint256 length
	) external returns (bytes memory) {
		bytes memory samples = execute(musicBytecode, start, length);
		return _wrapInWAV(samples);
	}

	/// @notice generate a wav file from a contract pre-created and a specific offset and length
	/// @param executor the generated contract that perform the Bleep Machine loop (see `create`)
	/// @param start sample offset at whcih the music start
	/// @param length the number of sample to generate
	function wav(
		address executor,
		uint256 start,
		uint256 length
	) external returns (bytes memory) {
		bytes memory samples = execute(executor, start, length);
		return _wrapInWAV(samples);
	}

	/// @notice create a contract that generate the music from a given start offset and length
	/// @param musicBytecode the evm bytecode the Bleep Machine will execute in a loop
	function create(bytes memory musicBytecode) public returns (address executor) {
		// This code generate a contract creation-code that loop over the provided `musicBytecode`
		//
		// 61006d600081600b8239f3 simply copy the code after it
		//
		// 6000358060801b806000529060801c60205260006040525b prepare the data
		// In particular it parse the calldata to extract start and length parameters (Stored in 128bit each)
		// it then ensure that starting time is on top of the stack before the loop start
		// the last `5b` is a JUMPDEST that will be jump to each time
		//
		// 60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3
		// performs the loop and when it ends (start + time >= length), it copy the generate buffer in return data
		bytes memory executorCreation = bytes.concat(
			hex"61006d600081600b8239f36000358060801b806000529060801c60205260006040525b",
			musicBytecode,
			hex"60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3"
		);
		uint256 len = musicBytecode.length;

		// we make sure the generated code length can be encoded in the PUSH2
		uint256 codeLen;
		unchecked {
			codeLen = 0x4d + len;
		}
		if (codeLen > 0xFFFF) {
			revert MusicByteCodeTooLarge();
		}

		// we store the generated creationCode length so that the creationCode work with its new length
		assembly {
			mstore8(add(executorCreation, 33), shr(8, codeLen))
			mstore8(add(executorCreation, 34), and(codeLen, 0xFF))
		}

		// we create the contract
		assembly {
			executor := create(0, add(executorCreation, 32), mload(executorCreation))
		}

		// if there is any error, we revert
		if (executor == address(0)) {
			revert MusicContractCreationFailure();
		}
	}

	/// @notice generate a raw 8 bits samples from a contract pre-created and a specific offset and length
	/// @param musicBytecode the evm bytecode the Bleep Machine will execute in a loop
	/// @param start sample offset at whcih the music start
	/// @param length the number of sample to generate
	function execute(
		bytes memory musicBytecode,
		uint256 start,
		uint256 length
	) public returns (bytes memory) {
		address executor = create(musicBytecode);
		return execute(executor, start, length);
	}

	/// @notice generate a raw 8 bits samples from EVM bytecode (`musicBytecode`) with a specific offset and length
	/// @param executor the generated contract that perform the Bleep Machine loop (see `create`)
	/// @param start sample offset at whcih the music start
	/// @param length the number of sample to generate
	function execute(
		address executor,
		uint256 start,
		uint256 length
	) public view returns (bytes memory) {
		// We execute the generated contract
		// if the music bytecode behaves, it will create a buffer of length `length`
		(bool success, bytes memory buffer) = executor.staticcall(
			abi.encode((start & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | (length << 128))
		);
		if (!success) {
			revert MusicExecutionFailure();
		}

		return buffer;
	}

	function _wrapInWAV(bytes memory samples) internal pure returns (bytes memory) {
		// WAV file header, 8 bits, 8000Hz, mono, zero length
		bytes
			memory dynHeader = hex"524946460000000057415645666d74201000000001000100401f0000401f0000010008006461746100000000";

		uint256 length = samples.length;
		assembly {
			// top header length is length of data + 36
			// more precisely: (4 + (8 + SubChunk1Size) + (8 + SubChunk2Size))
			// where SubChunk1Size is 16 (for PCM) and SubChunk2Size is the length of the data
			let t := add(length, 36)

			// we write that in the top header  (in little endian)
			mstore8(add(dynHeader, 36), and(t, 0xFF))
			mstore8(add(dynHeader, 37), and(shr(8, t), 0xFF))
			mstore8(add(dynHeader, 38), and(shr(16, t), 0xFF))

			// we also write the data length just before the data stream as per WAV file format spec (in little endian)
			mstore8(add(dynHeader, 72), and(length, 0xFF))
			mstore8(add(dynHeader, 73), and(shr(8, length), 0xFF))
			mstore8(add(dynHeader, 74), and(shr(16, length), 0xFF))
		}

		// We concatenate the buffer we got from computing the music with the header above
		return bytes.concat(dynHeader, samples);
	}
}
