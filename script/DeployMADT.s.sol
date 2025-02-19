// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MADT} from "../src/MADT.sol";

contract DeployMADT is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new MADT();
        vm.stopBroadcast();
    }
}
