// SPDX-License-Identifier: AGPL-1.0
pragma solidity 0.8.16;

contract Executor {
	fallback(bytes calldata payload) external returns (bytes memory) {
		uint256 length = uint128(bytes16(payload[:16]));
		uint256 time = uint128(bytes16(payload[16:32]));

		bytes memory buffer = new bytes(length);

		uint256 resultPtr;
		assembly {
			resultPtr := add(buffer, 32)

			function f(t) -> value {
				// value := and(t, shr(8, t)) // (t >> 8) & t
				value := mul(t, and(shr(10, t), 42)) // ((t >> 10) & 42) * t
			}

			for {
				let i := 0
			} lt(i, length) {
				i := add(i, 1)
			} {
				let intValue := f(time)

				mstore8(resultPtr, and(intValue, 0xFF))
				resultPtr := add(resultPtr, 1)
				time := add(time, 1)
			}
		}
		return buffer;
	}
}
