// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface IDataProvider {
    function sendRequest(uint64 subscriptionId) external returns (bytes32 requestId);
    function setSourceCode(string memory sourceCode) external;
    function getSourceCode() external view returns (string memory);
    function getMADValueInUSD() external returns (uint256);
    function getLastResponse() external view returns (bytes memory);
    function getLastError() external view returns (bytes memory);
    function getLastRequestId() external view returns (bytes32);
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) external;
}
