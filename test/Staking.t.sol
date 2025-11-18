// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Staking.sol";

contract StakingTest is Test {
    Staking staking;

    function setUp() public {
        staking = new Staking();
    }

    function testStake() public {
        staking.stake(100);
        assertEq(staking.balances(address(this)), 100);
    }
}

