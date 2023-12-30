// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";
import {ERC20Mock} from "@openzepplin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title CrowdFundingTest
 * @dev Test contract for the CrowdFunding contract.
 */
contract CrowdFundingTest is Test {
    CrowdFunding private crowdFunding;
    ERC20Mock private mockERC20;
    address tokenOwner;
    address campaignDeployer;

    /**
     * @dev Set up the test environment.
     */
    function setUp() public {
        // Creating a token owner
        tokenOwner = makeAddr("tokenOwner");
        // Creating a campaign owner
        campaignDeployer = makeAddr("campaignDeployer");

        // Deploying the contract with token owner address
        vm.prank(tokenOwner);
        mockERC20 = new ERC20Mock();

        // Creating crowdfund campaign
        crowdFunding = new CrowdFunding(address(campaignDeployer), mockERC20);
    }

    /**
     * @dev Test the fund function in the CrowdFunding contract.
     */
    function test_fund() public {
        // Taking the amount to be 100 ERC tokens
        uint256 amount = 100e18;

        // Minting 100 Tokens
        vm.prank(tokenOwner);
        mockERC20.mint(address(tokenOwner), amount);

        // Approving the address for the crowdfund contract
        vm.prank(tokenOwner);
        mockERC20.approve(address(crowdFunding), amount);

        // Funding the token owner
        vm.prank(tokenOwner);
        bool success = crowdFunding.fund(amount);

        // Asserting on the successful transaction
        assertTrue(success);

        // GEtting the balance for the crowdFund
        uint256 crowdFundingBalance = mockERC20.balanceOf(
            address(crowdFunding)
        );
        assertEq(amount, crowdFundingBalance);
    }

    /**
     * @dev Test the fund function in the CrowdFunding contract with a negative case.
     */
    function test_fund_negative() public {
        // Taking the amount to be 100 ERC tokens
        uint256 amount = 100e18;

        // Minting tokens
        vm.prank(tokenOwner);
        mockERC20.mint(address(tokenOwner), amount);

        // Trying to fund campaign without approving
        vm.prank(tokenOwner);
        vm.expectRevert();
        crowdFunding.fund(amount);

        // Getting the balance for the crowdFund
        uint256 crowdFundingBalance = mockERC20.balanceOf(
            address(crowdFunding)
        );
        // Asserting on the balance of crowdfund
        assertEq(0, crowdFundingBalance);
    }

    /**
     * @notice Tests the withdrawal function in the CrowdFunding contract.
     * @dev It funds the contract, withdraws the funds, and asserts on the resulting balances.
     */
    function test_withdrawl() public {
        // Taking the amount to be 100 ERC tokens
        uint256 amount = 100e18;

        // Minting 100 Tokens
        vm.prank(tokenOwner);
        mockERC20.mint(address(tokenOwner), amount);

        // Approving the address for the crowdfund contract
        vm.prank(tokenOwner);
        mockERC20.approve(address(crowdFunding), amount);

        // Funding the token owner
        vm.prank(tokenOwner);
        crowdFunding.fund(amount);

        // Withdrawing funds
        vm.prank(campaignDeployer);
        crowdFunding.withdraw();

        // Getting balances
        uint256 crowdFundingBalance = mockERC20.balanceOf(
            address(crowdFunding)
        );
        uint256 ownerBalance = mockERC20.balanceOf(address(campaignDeployer));

        // Asserting on balances
        assertEq(0, crowdFundingBalance);
        assertEq(amount, ownerBalance);
    }

    /**
     * @notice Tests the negative scenario of the withdrawal function in the CrowdFunding contract.
     * @dev It funds the contract, attempts to withdraw without being the owner, and asserts on the resulting balances.
     */
    function test_withdrawl_negative() public {
        // Taking the amount to be 100 ERC tokens
        uint256 amount = 100e18;

        // Minting 100 Tokens
        vm.prank(tokenOwner);
        mockERC20.mint(address(tokenOwner), amount);

        // Approving the address for the crowdfund contract
        vm.prank(tokenOwner);
        mockERC20.approve(address(crowdFunding), amount);

        // Funding the token owner
        vm.prank(tokenOwner);
        crowdFunding.fund(amount);

        // Trying Withdrawing funds
        vm.expectRevert();
        crowdFunding.withdraw();

        // Getting balances
        uint256 crowdFundingBalance = mockERC20.balanceOf(
            address(crowdFunding)
        );
        uint256 ownerBalance = mockERC20.balanceOf(address(campaignDeployer));

        // Asserting on balances
        assertEq(amount, crowdFundingBalance);
        assertEq(0, ownerBalance);
    }
}
