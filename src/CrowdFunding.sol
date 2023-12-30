// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC4626, ERC20, IERC20} from "@openzepplin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Custom error for failed transfers
error TransferFailed();

/**
 * @title CrowdFunding
 * @dev A simple crowdfunding contract that allows supporters to contribute funds using ERC20 tokens.
 */
contract CrowdFunding is ERC4626, Ownable {
    // ERC20 token to be used for funding
    IERC20 public token;

    // Mapping to track funds contributed by each supporter
    mapping(address => uint256) public funds;

    // Event emitted when a supporter contributes funds
    event Funded(address indexed supporter, uint256 amount);
    // Event emitted when a owner withdraws funds
    event Withdrawl(uint256 amount);

    /**
     * @dev Constructor to initialize the contract with a specific ERC20 token.
     * @param _owner The owner token address to be used for withdrawing.
     * @param _asset The IERC20 token address to be used for funding.
     */
    constructor(
        address _owner,
        IERC20 _asset
    ) Ownable(_owner) ERC4626(_asset) ERC20("Vault Mock Token", "vMCK") {
        token = _asset;
    }

    /**
     * @notice Allows supporters to contribute funds to the CrowdFunding contract.
     * @dev It deposits the specified amount of ERC20 tokens, mints shares, and emits a Funded event.
     * @param amount The amount of ERC20 tokens to be contributed.
     * @return shares number of shares minted for the supporter.
     */
    function fund(uint256 amount) external returns (uint256 shares) {
        // Deposit the specified amount of ERC20 tokens and mint shares
        shares = deposit(amount, msg.sender);

        // Emit a Funded event to log the contribution
        emit Funded(msg.sender, amount);
    }

    /**
     * @notice Allows the owner to withdraw the entire token balance from the contract.
     * @dev Only the owner can call this function.
     */
    function withdraw() external onlyOwner {
        // Get the current token balance of the contract
        uint256 tokenBalance = token.balanceOf(address(this));

        // Transfer the entire token balance to the owner
        bool success = token.transfer(owner(), tokenBalance);

        // Revert execution and emit the custom TransferFailed error if transfer fails
        if (!success) {
            revert TransferFailed();
        }

        // Emit a Withdrawal event to log the successful withdrawal
        emit Withdrawl(tokenBalance);
    }
}
