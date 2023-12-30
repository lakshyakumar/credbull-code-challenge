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
    // Platfrom owner address
    address public platformOwner;
    // Fee percent for platform owner
    uint256 public feePercent;
    // Target asset amount for the campaign
    uint256 public campaignTarget;

    // Mapping to track funds contributed by each supporter
    mapping(address => uint256) public funds;

    // Event emitted when a supporter contributes funds
    event Funded(address indexed supporter, uint256 amount);
    // Event emitted when a owner withdraws funds
    event Withdrawal(uint256 amount);

    /**
     * @dev Constructor for the CrowdFundingV6 contract.
     * @param _owner The address that will be set as the owner of the contract.
     * @param _platformOwner The address of the platform owner who will receive fees.
     * @param _asset The ERC20 token to be used for the crowdfunding campaign.
     * @param _feePercent The percentage of funds to be collected as fees.
     * @param _campaignTarget The target amount of the crowdfunding campaign.
     */
    constructor(
        address _owner,
        address _platformOwner,
        IERC20 _asset,
        uint256 _feePercent,
        uint256 _campaignTarget
    ) Ownable(_owner) ERC4626(_asset) ERC20("Vault Mock Token", "vMCK") {
        // Set the ERC20 token and campaign target
        token = _asset;
        campaignTarget = _campaignTarget;

        // Set the platform owner and fee percentage
        platformOwner = _platformOwner;
        feePercent = _feePercent;
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
     * @notice Calculates the fee amount based on the provided percentage of the total amount.
     * @dev This function is internal and view-only.
     * @param amount The total amount for which the fee needs to be calculated.
     * @return The calculated fee amount.
     */
    function calculateFee(uint256 amount) internal view returns (uint256) {
        // Calculate the fee as a percentage of the total amount
        return ((amount * feePercent) / 100);
    }

    /**
     * @notice Allows the owner to withdraw the entire token balance from the contract.
     * @dev Only the owner can call this function.
     */
    function withdraw() external onlyOwner {
        // Get the current token balance of the contract
        uint256 tokenBalance = token.balanceOf(address(this));

        // Calculating platform owner fee
        uint256 fee = calculateFee(tokenBalance);

        // Transfer the token balance to the owner
        bool success = token.transfer(owner(), tokenBalance - fee);

        // Revert execution and emit the custom TransferFailed error if transfer fails
        if (!success) {
            revert TransferFailed();
        }

        // Transfer the fee token balance to the  platform owner
        success = token.transfer(platformOwner, fee);
        if (!success) revert TransferFailed();

        // Emit a Withdrawal event to log the successful withdrawal
        emit Withdrawal(tokenBalance);
    }
}
