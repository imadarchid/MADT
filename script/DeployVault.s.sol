// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IDataProvider} from "../src/interfaces/IDataProvider.sol";
import {FunctionsScript} from "./FunctionsScript.s.sol";
import {Vault} from "../src/Vault.sol";
import {MADT} from "../src/MADT.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract DeployVault is Script, HelperConfig {
    function run() public {
        address contractAddress = DevOpsTools.get_most_recent_deployment("DataProvider", block.chainid);
        address MADTAddress = DevOpsTools.get_most_recent_deployment("MADT", block.chainid);

        MADT madt = MADT(MADTAddress);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Deploying Vault..");
        IDataProvider dataProvider = IDataProvider(contractAddress);
        IERC20 usdt = IERC20(getNetworkConfig().usdToken);
        Vault vault = new Vault(dataProvider, madt, usdt);
        madt.setVault(address(vault));
        vm.stopBroadcast();
    }
}
