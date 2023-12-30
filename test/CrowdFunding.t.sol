// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";
import {MyModule} from "../src/MyModule.sol";
import {MockSafe} from "./mocks/MockSafe.sol";
import {ERC20Mock} from "@openzepplin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title CrowdFundingTest
 * @dev Test contract for the CrowdFunding contract.
 */
contract CrowdFundingTest is Test {
    CrowdFunding private crowdFunding;
    ERC20Mock private mockERC20;
    MockSafe private safe;
    MyModule private module;
    address tokenOwner;
    address platformOwner;

    /**
     * @dev Set up the test environment.
     */
    function setUp() public {
        // Creating a token owner
        tokenOwner = makeAddr("tokenOwner");

        // Creating a platform owner
        platformOwner = makeAddr("platformOwner");

        // Deploying mock safe
        safe = new MockSafe();

        // Deploying the contract with token owner address
        vm.prank(tokenOwner);
        mockERC20 = new ERC20Mock();

        // Creating crowdfund campaign
        crowdFunding = new CrowdFunding(
            address(safe),
            address(platformOwner),
            mockERC20,
            10,
            100e18
        );

        // Creating Module contract
        module = new MyModule(
            address(safe),
            address(crowdFunding),
            address(mockERC20)
        );
        safe.enableModule(address(module));
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
        uint256 shares = crowdFunding.fund(amount);

        // Asserting share and amount on the successful transaction
        assertEq(shares, amount);

        // GEtting the balance for the crowdFund
        uint256 crowdFundingBalance = mockERC20.balanceOf(
            address(crowdFunding)
        );
        // asserting on balance for crowdfund
        assertEq(amount, crowdFundingBalance);
        // Asserting on total supply of shares
        assertEq(amount, crowdFunding.totalSupply());
        // Asserting of total assets in vault
        assertEq(amount, crowdFunding.totalAssets());
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

        // Asserting on the shares of crowdfund
        assertEq(0, crowdFunding.totalSupply());
        // Asserting on the asset of crowdfund
        assertEq(0, crowdFunding.totalAssets());
    }

    /**
     * @notice Tests the withdrawal function in the CrowdFunding contract.
     * @dev It funds the contract, withdraws the funds, and asserts on the resulting balances.
     */
    function test_withdrawl() public {
        // Taking the amount to be 100 ERC tokens
        uint256 amount = 100e18;

        // Defining a platform fee
        uint256 fee = 10e18;

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
        module.withdraw();

        // Getting balances
        uint256 crowdFundingBalance = mockERC20.balanceOf(
            address(crowdFunding)
        );
        uint256 ownerBalance = mockERC20.balanceOf(address(safe));
        uint256 platformOwnerBalance = mockERC20.balanceOf(
            address(platformOwner)
        );

        // Asserting on balances
        assertEq(0, crowdFundingBalance);
        assertEq(fee, platformOwnerBalance);
        assertEq(amount - fee, ownerBalance);
    }

    /**
     * @notice Tests the negative scenario of the withdrawal function in the CrowdFunding contract.
     * @dev It funds the contract, attempts to withdraw without being the owner, and asserts on the resulting balances.
     */
    function test_withdrawl_negative() public {
        // Taking the amount to be 100 ERC tokens
        uint256 amount = 99e18;

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
        module.withdraw();

        // Getting balances
        uint256 crowdFundingBalance = mockERC20.balanceOf(
            address(crowdFunding)
        );
        uint256 ownerBalance = mockERC20.balanceOf(address(safe));

        // Asserting on balances
        assertEq(amount, crowdFundingBalance);
        assertEq(0, ownerBalance);
    }
}
