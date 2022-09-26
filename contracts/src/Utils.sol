// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.16;

library Utils {
	function numLeadingZeroes(uint256 x) internal pure returns (uint256) {
		uint256 y;
		uint256 n = 256;
		unchecked {
			y = x >> 128;
			if (y != 0) {
				n = n - 128;
				x = y;
			}
			y = x >> 64;
			if (y != 0) {
				n = n - 64;
				x = y;
			}
			y = x >> 32;
			if (y != 0) {
				n = n - 32;
				x = y;
			}
			y = x >> 16;
			if (y != 0) {
				n = n - 16;
				x = y;
			}
			y = x >> 8;
			if (y != 0) {
				n = n - 8;
				x = y;
			}
			y = x >> 4;
			if (y != 0) {
				n = n - 4;
				x = y;
			}
			y = x >> 2;
			if (y != 0) {
				n = n - 2;
				x = y;
			}
			y = x >> 1;
			if (y != 0) return n - 2;
		}

		return n - x;
	}
}
