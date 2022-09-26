// SPDX-License-Identifier: AGPL-3.0-or-later

// _/\/\/\/\/\/\__/\/\________________________/\/\/\/\/\____/\/\____________________________________________/\/\______/\/\__________________________/\/\________/\/\___________________________
// _____/\/\______/\/\__________/\/\/\________/\/\____/\/\__/\/\______/\/\/\______/\/\/\____/\/\/\/\________/\/\/\__/\/\/\__/\/\/\________/\/\/\/\__/\/\________________/\/\/\/\______/\/\/\___
// _____/\/\______/\/\/\/\____/\/\/\/\/\______/\/\/\/\/\____/\/\____/\/\/\/\/\__/\/\/\/\/\__/\/\__/\/\______/\/\/\/\/\/\/\______/\/\____/\/\________/\/\/\/\____/\/\____/\/\__/\/\__/\/\/\/\/\_
// _____/\/\______/\/\__/\/\__/\/\____________/\/\____/\/\__/\/\____/\/\________/\/\________/\/\/\/\________/\/\__/\__/\/\__/\/\/\/\____/\/\________/\/\__/\/\__/\/\____/\/\__/\/\__/\/\_______
// _____/\/\______/\/\__/\/\____/\/\/\/\______/\/\/\/\/\____/\/\/\____/\/\/\/\____/\/\/\/\__/\/\____________/\/\______/\/\__/\/\/\/\/\____/\/\/\/\__/\/\__/\/\__/\/\/\__/\/\__/\/\____/\/\/\/\_
// _________________________________________________________________________________________/\/\_______________________________________________________________________________________________

// https://machine.bleeps.art
//
// The Bleep Machine Generates Music From Ethereum bytecode
//
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

import "base64-sol/base64.sol";

error MusicByteCodeTooLarge();
error MusicContractCreationFailure();
error MusicExecutionFailure();

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
			hex"61006d600081600b8239f36000358060801b806000529060801c60205260006040525b",
			musicBytecode,
			hex"60ff9016604051806080019091905360010180604052602051600051600101806000529110601757602051806060526020016060f3"
		);
		uint256 len = musicBytecode.length;

		uint256 codeLen;
		unchecked {
			codeLen = 0x4d + len;
		}
		if (codeLen > 0xFFFF) {
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

		if (executor == address(0)) {
			revert MusicContractCreationFailure();
		}

		(bool success, bytes memory buffer) = executor.staticcall(abi.encode(start | (length << 128)));
		if (!success) {
			revert MusicExecutionFailure();
		}

		return buffer;
	}
}
