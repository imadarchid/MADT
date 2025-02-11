// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {FunctionsClient} from "@chainlink/contracts/v0.8/functions/v1_3_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

import {console} from "forge-std/console.sol";

contract DataProvider is ConfirmedOwner, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    error UnexpectedRequestID(bytes32 requestId);

    event Response(bytes32 requestId, bytes response, bytes error);

    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;
    string public s_aggregationLogic;
    bytes32 private immutable i_donId;
    uint32 private constant GAS_LIMIT = 300000;
    address public immutable i_router;

    constructor(address _router, bytes32 _donId, string memory _aggregationLogic)
        FunctionsClient(_router)
        ConfirmedOwner(msg.sender)
    {
        i_router = _router;
        i_donId = _donId;
        s_aggregationLogic = _aggregationLogic;
    }

    function sendExchangeRateRequest(uint64 subscriptionId, string[] calldata args)
        external
        onlyOwner
        returns (bytes32 requestId)
    {
        FunctionsRequest.Request memory req;
        req.initializeRequest(
            FunctionsRequest.Location.Inline, FunctionsRequest.CodeLanguage.JavaScript, s_aggregationLogic
        );
        req.setArgs(args);

        s_lastRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, GAS_LIMIT, i_donId);

        return s_lastRequestId;
    }

    function _fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }
        s_lastResponse = response;
        s_lastError = err;

        emit Response(requestId, s_lastResponse, s_lastError);
    }

    function getMADValueInUSD() public payable returns (uint256 madValue) {
        madValue = abi.decode(s_lastResponse, (uint256));
        console.log(madValue);

        return madValue;
    }
}
