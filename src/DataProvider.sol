// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {FunctionsClient} from "@chainlink/contracts/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract DataProvider is ConfirmedOwner, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    error UnexpectedRequestID(bytes32 requestId);

    event Response(bytes32 requestId, bytes response, bytes error);

    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;
    string public s_sourceCode = "return Functions.encodeUint256(12500);";
    bytes32 private immutable i_donId;
    uint32 private constant GAS_LIMIT = 300000;

    constructor(address _router, bytes32 _donId) FunctionsClient(_router) ConfirmedOwner(msg.sender) {
        i_donId = _donId;
    }

    function sendRequest(uint64 subscriptionId) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequest(FunctionsRequest.Location.Inline, FunctionsRequest.CodeLanguage.JavaScript, s_sourceCode);

        s_lastRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, GAS_LIMIT, i_donId);

        return s_lastRequestId;
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }
        s_lastResponse = response;
        s_lastError = err;

        emit Response(requestId, s_lastResponse, s_lastError);
    }

    function getMADValueInUSD() public payable returns (uint256 madValue) {
        madValue = abi.decode(s_lastResponse, (uint256));

        return madValue;
    }

    function getLastResponse() public view returns (bytes memory) {
        return s_lastResponse;
    }

    function getLastError() public view returns (bytes memory) {
        return s_lastError;
    }

    function getLastRequestId() public view returns (bytes32) {
        return s_lastRequestId;
    }

    function setSourceCode(string memory sourceCode) external onlyOwner {
        s_sourceCode = sourceCode;
    }

    function getSourceCode() public view returns (string memory) {
        return s_sourceCode;
    }
}
