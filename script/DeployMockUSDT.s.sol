// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockUSDT} from "../src/MockUSDT.sol";

contract DeployMockUSDT is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new MockUSDT();
        vm.stopBroadcast();
    }
}
