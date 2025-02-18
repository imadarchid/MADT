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
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address contractAddress = DevOpsTools.get_most_recent_deployment("DataProvider", block.chainid);
        dataProvider = IDataProvider(contractAddress);
        // sendRequest();
        console.log(bytesToUint(dataProvider.getLastResponse()));
        // console.log(dataProvider.getSourceCode());
        vm.stopBroadcast();
    }

    function getLastResponse() public view returns (bytes memory) {
        return dataProvider.getLastResponse();
    }

    function sendRequest() public {
        dataProvider.sendRequest(2);
    }

    function getSourceCode() public view returns (string memory) {
        return dataProvider.getSourceCode();
    }
}
