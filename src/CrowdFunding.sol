// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20} from "@openzepplin/contracts/token/ERC20/IERC20.sol";

// Custom error for failed transfers
error TransferFailed();

/**
 * @title CrowdFunding
 * @dev A simple crowdfunding contract that allows supporters to contribute funds using ERC20 tokens.
 */
contract CrowdFunding {
    // ERC20 token to be used for funding
    IERC20 public token;

    // Mapping to track funds contributed by each supporter
    mapping(address => uint256) public funds;

    // Event emitted when a supporter contributes funds
    event Funded(address indexed supporter, uint256 amount);

    /**
     * @dev Constructor to initialize the contract with a specific ERC20 token.
     * @param _token The ERC20 token address to be used for funding.
     */
    constructor(IERC20 _token) {
        token = _token;
    }

    /**
     * @dev External function allowing supporters to contribute funds.
     * @param amount The amount of funds to be contributed.
     * @return A boolean indicating whether the contribution was successful.
     */
    function fund(uint256 amount) external returns (bool) {
        // Attempt to transfer funds from the supporter to the contract
        bool success = IERC20(token).transferFrom(
            msg.sender,
            address(this),
            amount
        );

        // If the transfer is successful, update funds and emit the Funded event
        if (success) {
            funds[msg.sender] += amount;
            emit Funded(msg.sender, amount);
        } else {
            // Revert execution and emit the custom TransferFailed error if transfer fails
            revert TransferFailed();
        }

        // Return the success status of the transfer
        return success;
    }
}
