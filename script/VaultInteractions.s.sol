// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IDataProvider} from "../src/interfaces/IDataProvider.sol";
import {FunctionsScript} from "./FunctionsScript.s.sol";
import {Vault} from "../src/Vault.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MockUSDT} from "../src/MockUSDT.sol";
contract VaultInteractions is Script, HelperConfig {
    IDataProvider public dataProvider;
    address contractAddress =
        DevOpsTools.get_most_recent_deployment("Vault", block.chainid);

    Vault public vault = Vault(contractAddress);
    MockUSDT public usdt = MockUSDT(usdtAddress);

    function depositCollateral() public {
        vm.startBroadcast();
        usdt.approve(contractAddress, 100000000000000000000000000000);
        vault.depositCollateral(12500);
        vm.stopBroadcast();
    }

    function redeemCollateral(uint256 amountInUsd) public {
        vm.startBroadcast();
        vault.redeemCollateral(amountInUsd);
        vm.stopBroadcast();
    }
}
