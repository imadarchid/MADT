// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

/**
 * @title Chainlink Functions example on-demand consumer contract example
 */
contract FunctionsConsumer is FunctionsClient, ConfirmedOwner, AutomationCompatibleInterface {
  using FunctionsRequest for FunctionsRequest.Request;

  bytes32 public donId; // DON ID for the Functions DON to which the requests are sent

  bytes public s_requestCBOR;
  uint64 public s_subscriptionId;
  uint32 public s_fulfillGasLimit;
  bytes32 public s_lastRequestId;
  bytes public s_lastResponse;
  bytes public s_lastError;

  uint256 public rate;

  // State variables for Chainlink Automation
  uint256 public s_updateInterval;
  uint256 public s_lastUpkeepTimeStamp;
  uint256 public s_upkeepCounter;
  uint256 public s_requestCounter;
  uint256 public s_responseCounter;

  event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);
  event RequestRevertedWithErrorMsg(string reason);
  event RequestRevertedWithoutErrorMsg(bytes data);

  constructor(address router, bytes32 _donId) FunctionsClient(router) ConfirmedOwner(msg.sender) {
    donId = _donId;
    s_lastUpkeepTimeStamp = 0;
  }

  /**
   * @notice Set the DON ID
   * @param newDonId New DON ID
   */
  function setDonId(bytes32 newDonId) external onlyOwner {
    donId = newDonId;
  }

  /**
   * @notice Triggers an on-demand Functions request using remote encrypted secrets
   * @param source JavaScript source code
   * @param secretsLocation Location of secrets (only Location.Remote & Location.DONHosted are supported)
   * @param encryptedSecretsReference Reference pointing to encrypted secrets
   * @param args String arguments passed into the source code and accessible via the global variable `args`
   * @param bytesArgs Bytes arguments passed into the source code and accessible via the global variable `bytesArgs` as hex strings
   * @param subscriptionId Subscription ID used to pay for request (FunctionsConsumer contract address must first be added to the subscription)
   * @param callbackGasLimit Maximum amount of gas used to call the inherited `handleOracleFulfillment` method
   */
  function sendRequest(
    string calldata source,
    FunctionsRequest.Location secretsLocation,
    bytes calldata encryptedSecretsReference,
    string[] calldata args,
    bytes[] calldata bytesArgs,
    uint64 subscriptionId,
    uint32 callbackGasLimit
  ) external onlyOwner {
    FunctionsRequest.Request memory req;
    req.initializeRequest(FunctionsRequest.Location.Inline, FunctionsRequest.CodeLanguage.JavaScript, source);
    req.secretsLocation = secretsLocation;
    req.encryptedSecretsReference = encryptedSecretsReference;
    if (args.length > 0) {
      req.setArgs(args);
    }
    if (bytesArgs.length > 0) {
      req.setBytesArgs(bytesArgs);
    }
    s_lastRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, callbackGasLimit, donId);
  }

  function setRequest(
    uint64 _subscriptionId,
    uint32 _fulfillGasLimit,
    uint256 _updateInterval,
    bytes calldata requestCBOR
  ) external onlyOwner {
    s_updateInterval = _updateInterval;
    s_subscriptionId = _subscriptionId;
    s_fulfillGasLimit = _fulfillGasLimit;
    s_requestCBOR = requestCBOR;
  }

  function checkUpkeep(bytes memory) public view override returns (bool upkeepNeeded, bytes memory) {
    upkeepNeeded = (block.timestamp - s_lastUpkeepTimeStamp) > s_updateInterval;
  }

  function performUpkeep(bytes calldata) external override {
    (bool upkeepNeeded, ) = checkUpkeep("");
    require(upkeepNeeded, "Time interval not met");
    s_lastUpkeepTimeStamp = block.timestamp;
    s_upkeepCounter = s_upkeepCounter + 1;

    try
      i_router.sendRequest(
        s_subscriptionId,
        s_requestCBOR,
        FunctionsRequest.REQUEST_DATA_VERSION,
        s_fulfillGasLimit,
        donId
      )
    returns (bytes32 requestId) {
      s_requestCounter = s_requestCounter + 1;
      s_lastRequestId = requestId;
      emit RequestSent(requestId);
    } catch Error(string memory reason) {
      emit RequestRevertedWithErrorMsg(reason);
    } catch (bytes memory data) {
      emit RequestRevertedWithoutErrorMsg(data);
    }
  }

  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    s_lastResponse = response;
    s_lastError = err;

    bool nilErr = (err.length == 0);
    if (nilErr) {
      rate = abi.decode(response, (uint256));
    }
    emit OCRResponse(requestId, response, err);
  }
}
