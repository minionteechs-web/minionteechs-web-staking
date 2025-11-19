// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Staking.sol";
import "../src/MockERC20.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();
        
        // Deploy mock tokens (for testing/development)
        MockERC20 stakingToken = new MockERC20("Staking Token", "STK", 1_000_000);
        MockERC20 rewardsToken = new MockERC20("Rewards Token", "RWD", 1_000_000);
        
        // Deploy staking contract with 1 token per second reward rate
        StakingRewards staking = new StakingRewards(
            address(stakingToken),
            address(rewardsToken),
            1e18 // 1 token per second
        );
        
        // Fund the staking contract with rewards
        rewardsToken.approve(address(staking), 500_000 * 1e18);
        staking.fundRewards(500_000 * 1e18);
        
        vm.stopBroadcast();
        
        // Log deployment info
        console.log("StakingRewards deployed at:", address(staking));
        console.log("Staking Token deployed at:", address(stakingToken));
        console.log("Rewards Token deployed at:", address(rewardsToken));
    }
}

// Deployment helper for mainnet/testnet with real addresses
contract DeployMainnetScript is Script {
    // Update these with actual token addresses
    address constant STAKING_TOKEN = 0x0000000000000000000000000000000000000000;
    address constant REWARDS_TOKEN = 0x0000000000000000000000000000000000000000;
    
    function run() public {
        require(STAKING_TOKEN != address(0), "Update STAKING_TOKEN address");
        require(REWARDS_TOKEN != address(0), "Update REWARDS_TOKEN address");
        
        vm.startBroadcast();
        
        // Deploy staking contract
        StakingRewards staking = new StakingRewards(
            STAKING_TOKEN,
            REWARDS_TOKEN,
            1e18 // Adjust reward rate as needed
        );
        
        vm.stopBroadcast();
        
        console.log("StakingRewards deployed at:", address(staking));
    }
}
