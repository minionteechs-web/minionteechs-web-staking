// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Staking.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();
        
        new Staking();
        
        vm.stopBroadcast();
    }
}
