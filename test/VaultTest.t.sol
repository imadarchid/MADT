// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Vault} from "../src/Vault.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DataProvider} from "../src/DataProvider.sol";
import {MADT} from "../src/MADT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDataProvider} from "../src/interfaces/IDataProvider.sol";

contract VaultTest is Test {
    Vault vault;
    MADT madt;
    HelperConfig helperConfig;

    address user = makeAddr("user");

    function setUp() public {
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getNetworkConfig();
        vm.startBroadcast();
        DataProvider dataProvider = new DataProvider(networkConfig.router, networkConfig.donId, "return 1;");
        // dataProvider.sendExchangeRateRequest(
        //     networkConfig.subscriptionId,
        //     networkConfig.args
        // );

        madt = new MADT();
        vault = new Vault(IDataProvider(address(dataProvider)), madt, IERC20(networkConfig.usdToken));
        vm.stopBroadcast();
    }

    /*
     *   Test cases:
     *   - Test that we can deposit/redeem collateral
     *   - Test that we can't deposit/redeem more than the user has
     *   - Test that only the vault can interact with the MADT's burn and mint functions
     *   - Test the case in which the USD/MAD conversion drops between the time of deposit and redemption
     */

    function testDepositUSDTforMADT() public {
        vm.startPrank(user);

        vm.stopPrank();
    }
}
