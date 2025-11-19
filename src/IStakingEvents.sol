// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StakingEvents
 * @notice Centralized event definitions for staking contracts
 */
interface IStakingEvents {
    // Staking events
    event Staked(address indexed user, uint256 amount, uint256 tier);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdrawal(address indexed user, uint256 amount, uint256 fee);
    
    // Reward events
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);
    event RewardsFunded(uint256 amount);
    
    // Admin events
    event OwnerTransferred(address oldOwner, address newOwner);
    event Paused();
    event Unpaused();
    event FeeUpdated(uint256 newFee);
    event FeeRecipientUpdated(address newRecipient);
}
