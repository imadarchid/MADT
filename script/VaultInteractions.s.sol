// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IDataProvider} from "../src/interfaces/IDataProvider.sol";
import {FunctionsScript} from "./FunctionsScript.s.sol";
import {Vault} from "../src/Vault.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract VaultInteractions is Script, HelperConfig {
    IDataProvider public dataProvider;
    address contractAddress = DevOpsTools.get_most_recent_deployment("Vault", block.chainid);

    Vault public vault = Vault(contractAddress);

    function depositCollateral() public {
        vm.startBroadcast();
        vault.depositCollateral(100);
        vm.stopBroadcast();
    }
}
