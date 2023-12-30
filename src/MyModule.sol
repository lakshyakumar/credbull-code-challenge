// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.21;

import "@gnosis.pm/zodiac/contracts/core/Module.sol";
import {ICrowdFunding} from "./interface/ICrowdFunding.sol";
import {IERC20} from "@openzepplin/contracts/token/ERC20/IERC20.sol";

// Custom error for campaign target not reached
error CampaignTargetNotReached(uint256 tokenBalance);

/**
 * @title MyModule
 * @dev A Gnosis Safe module for interacting with a crowdfunding campaign.
 */
contract MyModule is Module {
    // Address of the crowdfunding campaign
    address public campaign;

    // Address of the ERC20 token used in the campaign
    address public asset;

    /**
     * @dev Constructor to initialize the module.
     * @param _owner The owner of the module.
     * @param _campaign The address of the crowdfunding campaign.
     * @param _asset The address of the ERC20 token used in the campaign.
     */
    constructor(address _owner, address _campaign, address _asset) {
        bytes memory initializeParams = abi.encode(_owner, _campaign, _asset);
        setUp(initializeParams);
    }

    /**
     * @notice Initialize function, triggered when a new proxy is deployed.
     * @dev Sets up the module with the specified parameters.
     * @param initializeParams Parameters of initialization encoded.
     */
    function setUp(bytes memory initializeParams) public override initializer {
        (address _owner, address _campaign, address _asset) = abi.decode(
            initializeParams,
            (address, address, address)
        );

        // Set the ERC20 token and crowdfunding campaign addresses
        asset = _asset;
        campaign = _campaign;

        // Initialize the module
        __Ownable_init(msg.sender);
        setAvatar(_owner);
        setTarget(_owner);
        transferOwnership(_owner);
    }

    /**
     * @notice Withdraws funds from the crowdfunding campaign.
     * @dev Checks if the current campaign balance is greater than or equal to the target
     *      before executing the withdrawal.
     */
    function withdraw() external {
        // Get the current campaign balance and target
        uint256 currentCampaignBalance = IERC20(asset).balanceOf(campaign);
        uint256 campaignTarget = ICrowdFunding(campaign).campaignTarget();

        // Revert if the campaign target is not reached
        if (currentCampaignBalance < campaignTarget) {
            revert CampaignTargetNotReached(currentCampaignBalance);
        }

        // Execute the withdrawal on the campaign
        exec(
            campaign,
            0,
            abi.encodePacked(bytes4(keccak256("withdraw()"))),
            Enum.Operation.Call
        );
    }
}
