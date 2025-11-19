// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StakingHelpers
 * @notice Helper functions for staking contract interactions
 */
library StakingHelpers {
    // Tier constants
    uint256 public constant TIER_1 = 1; // 7 days
    uint256 public constant TIER_2 = 2; // 30 days
    uint256 public constant TIER_3 = 3; // 90 days

    // Tier durations
    uint256 public constant TIER_1_DURATION = 7 days;
    uint256 public constant TIER_2_DURATION = 30 days;
    uint256 public constant TIER_3_DURATION = 90 days;

    // Reward multipliers (basis points: 100 = 1x)
    uint256 public constant TIER_1_MULTIPLIER = 100;
    uint256 public constant TIER_2_MULTIPLIER = 150;
    uint256 public constant TIER_3_MULTIPLIER = 200;

    /**
     * @notice Calculate tier duration
     */
    function getTierDuration(uint256 tier) internal pure returns (uint256) {
        if (tier == TIER_1) return TIER_1_DURATION;
        if (tier == TIER_2) return TIER_2_DURATION;
        if (tier == TIER_3) return TIER_3_DURATION;
        revert("Invalid tier");
    }

    /**
     * @notice Calculate tier reward multiplier
     */
    function getTierMultiplier(uint256 tier) internal pure returns (uint256) {
        if (tier == TIER_1) return TIER_1_MULTIPLIER;
        if (tier == TIER_2) return TIER_2_MULTIPLIER;
        if (tier == TIER_3) return TIER_3_MULTIPLIER;
        revert("Invalid tier");
    }

    /**
     * @notice Calculate APY based on reward rate and stake amount
     */
    function calculateAPY(uint256 rewardRate, uint256 totalSupply) internal pure returns (uint256) {
        if (totalSupply == 0) return 0;
        return (rewardRate * 365 days * 1e18) / totalSupply;
    }
}
