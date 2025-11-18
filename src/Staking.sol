// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Staking {
    mapping(address => uint256) public balances;
    uint256 public rewardRate = 10;

    function stake(uint256 amount) external {
        balances[msg.sender] += amount;
    }

    function getReward(address user) public view returns (uint256) {
        return balances[user] * rewardRate;
    }
}
