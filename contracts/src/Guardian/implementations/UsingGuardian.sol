// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract UsingGuardian {
	event GuardianSet(address newGuardian);

	// bytes32 GUARDIAN_SLOT = bytes32(uint256(keccak256('guardian')) - 1); // 0x8fbcb4375b910093bcf636b6b2f26b26eda2a29ef5a8ee7de44b5743c3bf9a27

	constructor(address initialGuardian) {
		if (initialGuardian != address(0)) {
			assembly {
				sstore(0x8fbcb4375b910093bcf636b6b2f26b26eda2a29ef5a8ee7de44b5743c3bf9a27, initialGuardian)
			}
			emit GuardianSet(initialGuardian);
		}
	}

	/// @notice guardian has some special vetoing power to guide the direction of the DAO. It can only remove rights from the DAO. It could be used to immortalize rules.
	/// For example: the royalty setup could be frozen.
	function guardian() external view returns (address g) {
		assembly {
			g := sload(0x8fbcb4375b910093bcf636b6b2f26b26eda2a29ef5a8ee7de44b5743c3bf9a27)
		}
	}

	/**
	 * @notice set the new guardian that can freeze the other admins (except owner).
	 * Can only be called by the current guardian.
	 */
	function setGuardian(address newGuardian) external {
		address currentGuardian;
		assembly {
			currentGuardian := sload(0x8fbcb4375b910093bcf636b6b2f26b26eda2a29ef5a8ee7de44b5743c3bf9a27)
		}
		require(msg.sender == currentGuardian, "NOT_AUTHORIZED");
		if (currentGuardian != newGuardian) {
			assembly {
				sstore(0x8fbcb4375b910093bcf636b6b2f26b26eda2a29ef5a8ee7de44b5743c3bf9a27, newGuardian)
			}
			emit GuardianSet(newGuardian);
		}
	}
}
