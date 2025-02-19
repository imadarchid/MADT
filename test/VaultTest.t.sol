// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {FunctionsScript} from "../script/FunctionsScript.s.sol";
import {IDataProvider} from "../src/interfaces/IDataProvider.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {Vault} from "../src/Vault.sol";
import {MADT} from "../src/MADT.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract VaultTest is Test, HelperConfig {
    FunctionsScript functionsScript;
    address public consumer;
    uint64 public subscriptionId;
    IDataProvider public dataProvider;
    Vault public vault;
    MADT public madt;
    IERC20 public usdt;
    address public deployer = makeAddr("deployer");
    string public MAINNET_RPC_URL = vm.envString("RPC_URL");

    function setUp() public {
        address contractAddress = DevOpsTools.get_most_recent_deployment("DataProvider", block.chainid);

        dataProvider = IDataProvider(contractAddress);
        usdt = IERC20(getNetworkConfig().usdToken);
        madt = new MADT();
        vault = new Vault(dataProvider, madt, usdt);
        madt.setVault(address(vault));

        deal(address(usdt), deployer, 100000000000000000000);
        vm.prank(deployer);
        usdt.approve(address(vault), 100000000000000000000);
    }

    /*
     *   Test cases:
     *   - Test that we can deposit/redeem collateral
     *   - Test that we can't deposit/redeem more than the user has
     *   - Test that only the vault can interact with the MADT's burn and mint functions
     *   - Test the case in which the USD/MAD conversion drops between the time of deposit and redemption
     */

    function testIfMADValueIsCorrectlyReturned() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 response = dataProvider.getMADValueInUSD();
        vm.stopBroadcast();
    }

    function testIfCollateralDepositWorks() public {
        uint256 startingBalance = usdt.balanceOf(deployer);
        uint256 amountInUsdToDeposit = 100;
        uint256 madValue = dataProvider.getMADValueInUSD();

        vm.prank(deployer);
        vault.depositCollateral(amountInUsdToDeposit);

        assertEq(usdt.balanceOf(address(vault)), amountInUsdToDeposit * 1e6);
        assertEq(madt.balanceOf(deployer), (amountInUsdToDeposit * 1e18) / madValue);
        assertEq(usdt.balanceOf(deployer), startingBalance - amountInUsdToDeposit * 1e6);
    }

    function testIfCollateralRedemptionWorks() public {
        uint256 startingBalance = usdt.balanceOf(deployer);

        vm.prank(deployer);
        vault.depositCollateral(100);

        vm.prank(deployer);
        vault.redeemCollateral(100);

        assertEq(usdt.balanceOf(deployer), startingBalance);
        assertEq(usdt.balanceOf(address(vault)), 0);
        assertEq(madt.balanceOf(deployer), 0);
    }

    function testIfVaultCannotRedeemMoreThanDeposited() public {
        vm.prank(deployer);
        vault.depositCollateral(100);

        vm.prank(deployer);
        vm.expectRevert(Vault.Vault__UserInsufficientBalance.selector);
        vault.redeemCollateral(101);
    }

    function testIfVaultCannotRedeemMoreThanItHolds() public {
        vm.prank(deployer);
        vault.depositCollateral(100);

        uint256 vaultBalance = usdt.balanceOf(address(vault));
        vm.prank(address(vault));
        usdt.transfer(address(1), vaultBalance - 50e6);

        vm.prank(deployer);
        vm.expectRevert(Vault.Vault__VaultInsufficientBalance.selector);
        vault.redeemCollateral(100);

        vm.prank(deployer);
        vault.redeemCollateral(50);
    }
}
