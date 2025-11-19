// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Staking.sol";
import "../src/MockERC20.sol";

contract StakingTest is Test {
    StakingRewards staking;
    MockERC20 stakingToken;
    MockERC20 rewardsToken;
    
    address user1 = address(0x1);
    address user2 = address(0x2);
    address owner = address(this);

    function setUp() public {
        // Deploy mock tokens
        stakingToken = new MockERC20("Staking Token", "STK", 1_000_000);
        rewardsToken = new MockERC20("Rewards Token", "RWD", 1_000_000);
        
        // Deploy staking contract
        staking = new StakingRewards(address(stakingToken), address(rewardsToken), 1e18); // 1 token/sec
        
        // Fund users
        stakingToken.transfer(user1, 10_000 * 1e18);
        stakingToken.transfer(user2, 10_000 * 1e18);
        rewardsToken.transfer(address(staking), 1_000_000 * 1e18);
    }

    // ========== STAKING TESTS ==========
    
    function testStakeTier1() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 1);
        
        assertEq(staking.balanceOf(user1), 1000 * 1e18);
        assertEq(staking.totalSupply(), 1000 * 1e18);
        assertEq(staking.tier(user1), 1);
        vm.stopPrank();
    }
    
    function testStakeTier2() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 2);
        
        assertEq(staking.tier(user1), 2);
        vm.stopPrank();
    }
    
    function testStakeTier3() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 3);
        
        assertEq(staking.tier(user1), 3);
        vm.stopPrank();
    }
    
    function testInvalidTier() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        vm.expectRevert("Invalid tier");
        staking.stake(1000 * 1e18, 4);
        vm.stopPrank();
    }

    // ========== WITHDRAWAL TESTS ==========
    
    function testCannotWithdrawBeforeLockEnd() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 1); // 7 days lock
        
        vm.expectRevert("Tokens locked");
        staking.withdraw(100 * 1e18);
        vm.stopPrank();
    }
    
    function testWithdrawAfterLockEnd() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 1); // 7 days lock
        vm.stopPrank();
        
        // Fast forward past lock period
        vm.warp(block.timestamp + 8 days);
        
        vm.startPrank(user1);
        staking.withdraw(500 * 1e18);
        assertEq(staking.balanceOf(user1), 500 * 1e18);
        vm.stopPrank();
    }
    
    function testEmergencyWithdrawal() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 3); // 90 days lock
        
        uint256 initialBalance = stakingToken.balanceOf(user1);
        staking.emergencyWithdraw(1000 * 1e18);
        
        // Should receive 95% (5% fee)
        uint256 expectedAmount = 950 * 1e18;
        assertEq(stakingToken.balanceOf(user1) - initialBalance, expectedAmount);
        vm.stopPrank();
    }

    // ========== REWARDS TESTS ==========
    
    function testRewardAccrual() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 1);
        vm.stopPrank();
        
        // Fast forward 1 day
        vm.warp(block.timestamp + 1 days);
        
        uint256 earned = staking.earned(user1);
        assertGt(earned, 0);
    }
    
    function testClaimReward() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 1);
        vm.stopPrank();
        
        vm.warp(block.timestamp + 1 days);
        
        uint256 rewardBefore = rewardsToken.balanceOf(user1);
        vm.startPrank(user1);
        staking.getReward();
        vm.stopPrank();
        
        assertGt(rewardsToken.balanceOf(user1), rewardBefore);
    }

    // ========== ADMIN TESTS ==========
    
    function testSetRewardRate() public {
        uint256 newRate = 2e18;
        staking.setRewardRate(newRate);
        assertEq(staking.rewardRate(), newRate);
    }
    
    function testSetEmergencyWithdrawalFee() public {
        staking.setEmergencyWithdrawalFee(1000); // 10%
        
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        staking.stake(1000 * 1e18, 1);
        
        uint256 initialBalance = stakingToken.balanceOf(user1);
        staking.emergencyWithdraw(1000 * 1e18);
        
        // Should receive 90% (10% fee)
        uint256 expectedAmount = 900 * 1e18;
        assertEq(stakingToken.balanceOf(user1) - initialBalance, expectedAmount);
        vm.stopPrank();
    }
    
    function testPauseUnpause() public {
        staking.setPause(true);
        assert(staking.paused());
        
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        vm.expectRevert("Paused");
        staking.stake(1000 * 1e18, 1);
        vm.stopPrank();
        
        staking.setPause(false);
        assert(!staking.paused());
        
        vm.startPrank(user1);
        staking.stake(1000 * 1e18, 1);
        assertEq(staking.balanceOf(user1), 1000 * 1e18);
        vm.stopPrank();
    }
    
    function testFundRewards() public {
        uint256 fundAmount = 10_000 * 1e18;
        rewardsToken.approve(address(staking), fundAmount);
        staking.fundRewards(fundAmount);
        // Should not revert
    }
    
    function testRecoverERC20() public {
        MockERC20 otherToken = new MockERC20("Other Token", "OTH", 1000);
        otherToken.transfer(address(staking), 100 * 1e18);
        
        uint256 balanceBefore = otherToken.balanceOf(owner);
        staking.recoverERC20(address(otherToken), 100 * 1e18);
        assertEq(otherToken.balanceOf(owner), balanceBefore + 100 * 1e18);
    }
    
    function testTransferOwnership() public {
        address newOwner = address(0x123);
        staking.transferOwnership(newOwner);
        assertEq(staking.owner(), newOwner);
        
        // New owner should be able to call onlyOwner functions
        vm.startPrank(newOwner);
        staking.setRewardRate(5e18);
        assertEq(staking.rewardRate(), 5e18);
        vm.stopPrank();
    }

    // ========== EDGE CASES ==========
    
    function testZeroStake() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 1000 * 1e18);
        vm.expectRevert("Cannot stake 0");
        staking.stake(0, 1);
        vm.stopPrank();
    }
    
    function testMultipleStakes() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 10_000 * 1e18);
        
        staking.stake(1000 * 1e18, 1);
        staking.stake(2000 * 1e18, 1);
        staking.stake(3000 * 1e18, 1);
        
        assertEq(staking.balanceOf(user1), 6000 * 1e18);
        assertEq(staking.totalSupply(), 6000 * 1e18);
        vm.stopPrank();
    }
}

