// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {FunctionsScript} from "../script/FunctionsScript.s.sol";
import {IDataProvider} from "../src/interfaces/IDataProvider.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract VaultTest is Test, HelperConfig {
    FunctionsScript functionsScript;
    address public consumer;
    uint64 public subscriptionId;
    IDataProvider public dataProvider;

    address public deployer = makeAddr("deployer");
    string public MAINNET_RPC_URL = vm.envString("RPC_URL");

    function setUp() public {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "DataProvider",
            block.chainid
        );

        dataProvider = IDataProvider(contractAddress);
    }

    /*
     *   Test cases:
     *   - Test that we can deposit/redeem collateral
     *   - Test that we can't deposit/redeem more than the user has
     *   - Test that only the vault can interact with the MADT's burn and mint functions
     *   - Test the case in which the USD/MAD conversion drops between the time of deposit and redemption
     */

    // function testSendConsumerRequest() public {
    //     vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
    //     bytes32 requestId = dataProvider.sendRequest(subscriptionId);
    //     console.logBytes32(requestId);
    //     bytes memory response = dataProvider.getLastResponse();
    //     console.logBytes(response);
    //     vm.stopBroadcast();
    // }

    function testIfConsumerRequestIsFulfilled() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        bytes memory response = dataProvider.getLastResponse();
        console.logBytes(response);
        vm.stopBroadcast();
    }
}
