// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IDataProvider} from "../src/interfaces/IDataProvider.sol";
import {FunctionsScript} from "./FunctionsScript.s.sol";

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract Interactions is Script, HelperConfig {
    IDataProvider public dataProvider;
    address contractAddress = DevOpsTools.get_most_recent_deployment("DataProvider", block.chainid);

    function getLastResponse() public returns (uint256) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        dataProvider = IDataProvider(contractAddress);
        bytes memory response = dataProvider.getLastResponse();
        return abi.decode(response, (uint256));
        vm.stopBroadcast();
    }

    function sendRequest() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        dataProvider = IDataProvider(contractAddress);
        // Source code for the DON
        string memory source = vm.readFile("./don-simulator/src/source/source.js");
        dataProvider.sendRequest(1, source);
        vm.stopBroadcast();
    }

    function getLastError() public returns (bytes memory) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        dataProvider = IDataProvider(contractAddress);
        bytes memory lastError = dataProvider.getLastError();
        return lastError;
        vm.stopBroadcast();
    }
}
