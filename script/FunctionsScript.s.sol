// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

import {HelperConfig} from "./HelperConfig.s.sol";
import {DataProvider} from "../src/DataProvider.sol";

import {IFunctionsSubscriptions} from "lib/foundry-chainlink-toolkit/src/interfaces/functions/IFunctionsSubscriptions.sol";
import {ILinkToken} from "src/interfaces/ILinkToken.sol";

/**
 * Deploy the Mock fees using MockV3Aggregator
 * Deploy the Functions Router using the Functions Router script
 * Deploy the Functions Coordinator Test Helper with the functions router address, a simulated config, and the price feeds.
 * Deploy the allowlist with the functions coordinator address
 * Update the allowlists and deploy a coordinator + set the don public keys.
 */

contract FunctionsScript is Script, HelperConfig {
    uint256 public constant DEFAULT_SUB_TOPUP = 1000000000000000000;

    address public consumer;
    uint64 public subscriptionId;

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        consumer = deployConsumer();
        subscriptionId = createSubscription();
        console.log("Subscription ID: %s", subscriptionId);

        addConsumerToSubscription(subscriptionId, consumer);
        fundSubscription(subscriptionId, DEFAULT_SUB_TOPUP);
        vm.stopBroadcast();
    }

    function deployConsumer() public returns (address) {
        DataProvider dataProvider = new DataProvider(
            getNetworkConfig().router,
            getNetworkConfig().donId
        );
        return address(dataProvider);
    }
    function createSubscription() public returns (uint64) {
        IFunctionsSubscriptions functionsScript = IFunctionsSubscriptions(
            getNetworkConfig().router
        );
        subscriptionId = functionsScript.createSubscription();
        return subscriptionId;
    }
    function addConsumerToSubscription(
        uint64 subscriptionId,
        address consumer
    ) public {
        IFunctionsSubscriptions functionsScript = IFunctionsSubscriptions(
            getNetworkConfig().router
        );
        functionsScript.addConsumer(subscriptionId, consumer);
    }
    function fundSubscription(uint64 subscriptionId, uint256 amount) public {
        ILinkToken linkToken = ILinkToken(getNetworkConfig().linkToken);
        linkToken.transferAndCall(
            getNetworkConfig().router,
            amount,
            abi.encode(subscriptionId)
        );
    }

    function getConsumer() public view returns (address) {
        return consumer;
    }

    function getSubscriptionId() public view returns (uint64) {
        return subscriptionId;
    }

    function sendRequest() public {
        DataProvider dataProvider = DataProvider(consumer);
        dataProvider.sendRequest(subscriptionId);
    }
}
