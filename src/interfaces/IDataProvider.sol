// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface IDataProvider {
    function sendExchangeRateRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external returns (bytes32 requestId);

    function getMADValueInUSD() external returns (uint256);
}
