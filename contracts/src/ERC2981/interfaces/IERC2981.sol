// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 id, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount);
}
