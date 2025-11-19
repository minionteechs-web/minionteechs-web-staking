// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Staking.sol";
import "../src/MockERC20.sol";

/**
 * @title StakingFuzzTest
 * @notice Fuzz tests for staking contract
 */
contract StakingFuzzTest is Test {
    StakingRewards staking;
    MockERC20 stakingToken;
    MockERC20 rewardsToken;
    
    function setUp() public {
        stakingToken = new MockERC20("Staking Token", "STK", 1_000_000);
        rewardsToken = new MockERC20("Rewards Token", "RWD", 1_000_000);
        staking = new StakingRewards(address(stakingToken), address(rewardsToken), 1e18);
        
        rewardsToken.transfer(address(staking), 500_000 * 1e18);
    }

    function testFuzzStakeWithinBounds(uint256 amount, uint256 tier) public {
        amount = bound(amount, 1, 1e24); // Bound to reasonable values
        tier = bound(tier, 1, 3);
        
        address user = address(0x1);
        stakingToken.transfer(user, amount);
        
        vm.startPrank(user);
        stakingToken.approve(address(staking), amount);
        staking.stake(amount, tier);
        
        assertEq(staking.balanceOf(user), amount);
        assertEq(staking.tier(user), tier);
        vm.stopPrank();
    }

    function testFuzzWithdrawAfterUnlock(uint256 amount, uint256 withdrawAmount) public {
        amount = bound(amount, 100, 1e24);
        withdrawAmount = bound(withdrawAmount, 1, amount);
        
        address user = address(0x1);
        stakingToken.transfer(user, amount);
        
        vm.startPrank(user);
        stakingToken.approve(address(staking), amount);
        staking.stake(amount, 1);
        vm.stopPrank();
        
        // Fast forward past lock
        vm.warp(block.timestamp + 8 days);
        
        vm.startPrank(user);
        staking.withdraw(withdrawAmount);
        assertEq(staking.balanceOf(user), amount - withdrawAmount);
        vm.stopPrank();
    }

    function testFuzzRewardAccrual(uint256 amount, uint256 timeSkip) public {
        amount = bound(amount, 1e18, 1e24);
        timeSkip = bound(timeSkip, 1, 365 days);
        
        address user = address(0x1);
        stakingToken.transfer(user, amount);
        
        vm.startPrank(user);
        stakingToken.approve(address(staking), amount);
        staking.stake(amount, 1);
        vm.stopPrank();
        
        vm.warp(block.timestamp + timeSkip);
        
        uint256 earned = staking.earned(user);
        assertGt(earned, 0);
    }

    function testFuzzEmergencyWithdrawalFee(uint256 amount) public {
        amount = bound(amount, 1e18, 1e24);
        
        address user = address(0x1);
        stakingToken.transfer(user, amount);
        
        vm.startPrank(user);
        stakingToken.approve(address(staking), amount);
        staking.stake(amount, 3);
        
        staking.emergencyWithdraw(amount);
        
        // Should receive 95% of amount (5% fee)
        uint256 expected = (amount * 95) / 100;
        assertGe(stakingToken.balanceOf(user), expected - 1); // -1 for rounding
        vm.stopPrank();
    }
}
