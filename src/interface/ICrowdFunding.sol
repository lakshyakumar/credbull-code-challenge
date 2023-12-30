// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {IERC20} from "@openzepplin/contracts/token/ERC20/IERC20.sol";

interface ICrowdFunding {
    // Events
    event Funded(address indexed supporter, uint256 amount);
    event Fee(address indexed platformOwner, uint256 amount);
    event Withdrawl(uint256 amount);

    // Function declarations (without implementation details)
    function fund(uint256 amount) external returns (uint256 shares);

    function withdrawTokens() external;

    function maxWithdraw(address owner) external returns (uint256);

    // View functions (omit the "view" keyword in interfaces)
    function token() external returns (IERC20);

    function platformOwner() external returns (address);

    function feePercent() external returns (uint256);

    function campaignTarget() external returns (uint256);

    function expirationTime() external returns (uint256);
}
