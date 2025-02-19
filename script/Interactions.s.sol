// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IDataProvider} from "../src/interfaces/IDataProvider.sol";
import {FunctionsScript} from "./FunctionsScript.s.sol";

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract Interactions is Script, HelperConfig {
    IDataProvider public dataProvider;
    address public consumer;

    function run() public {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "DataProvider",
            block.chainid
        );
        dataProvider = IDataProvider(contractAddress);
        // sendRequest();
        console.log(bytesToUint(getLastResponse()));
    }

    function getLastResponse() public returns (bytes memory) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        bytes memory response = dataProvider.getLastResponse();
        vm.stopBroadcast();
        return response;
    }

    function sendRequest() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        dataProvider.sendRequest(1, "return Functions.encodeUint256(10);");
        vm.stopBroadcast();
    }

}
