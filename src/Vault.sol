// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IDataProvider} from "./interfaces/IDataProvider.sol";
import {MADT} from "./MADT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

contract Vault {
    error Vault__InvalidAmount();
    error Vault__TransferFailed();
    error Vault__UserInsufficientBalance();
    error Vault__VaultInsufficientBalance();
    error Vault__ApproveFailed();

    event CollateralDeposited(address destination, uint256 amount);
    event CollateralRedeemed(address destination, uint256 amount);
    event MADTMinted(address destination, uint256 amount);

    IDataProvider public dataProvider;
    MADT public madt;
    IERC20 public immutable usdt;

    constructor(IDataProvider _dataProvider, MADT _madt, IERC20 _usdt) {
        dataProvider = _dataProvider;
        madt = _madt;
        usdt = _usdt;
    }

    /* 
        @title Deposit Collateral
        @notice User deposits USDT and receives MADT in return. Conversion rate is calculated by invoking the getMADValueInUSD function on the data provider. 
        @param amount The amount of USDT to deposit
        @return bool True if the collateral was deposited successfully
    */

    function depositCollateral(uint256 amountInUsd) public payable returns (bool) {
        uint256 madValue = dataProvider.getMADValueInUSD();
        uint256 madAmount = (amountInUsd * 1e18) / madValue;
        bool success = usdt.transferFrom(msg.sender, address(this), amountInUsd * (10 ** 6));
        if (!success) revert Vault__TransferFailed();

        emit CollateralDeposited(msg.sender, amountInUsd * (10 ** 6));
        madt.mint(msg.sender, madAmount);
        emit MADTMinted(msg.sender, madAmount);
        return success;
    }

    /* 
        @title Redeem Collateral
        @notice User redeems MADT and receives USDT in return. Conversion rate is calculated by invoking the getMADValueInUSD function on the data provider.
        @param amount The amount of MADT to redeem
        @return bool True if the collateral was redeemed successfully
    */

    function redeemCollateral(uint256 amountInUsd) public payable returns (bool) {
        uint256 madValue = dataProvider.getMADValueInUSD();
        uint256 madAmount = (amountInUsd * 1e18) / madValue;

        if (madt.balanceOf(msg.sender) < madAmount) {
            revert Vault__UserInsufficientBalance();
        }

        if (usdt.balanceOf(address(this)) < amountInUsd * 1e6) {
            revert Vault__VaultInsufficientBalance();
        }

        madt.burn(msg.sender, madAmount);

        bool success = usdt.transfer(msg.sender, amountInUsd * 1e6);
        if (!success) revert Vault__TransferFailed();

        emit CollateralRedeemed(msg.sender, amountInUsd);
        return success;
    }
}
