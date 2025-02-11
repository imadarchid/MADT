// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MockLinkToken} from "@chainlink/contracts/v0.8/mocks/MockLinkToken.sol";
import {MockV3Aggregator} from "@chainlink/contracts/v0.8/tests/MockV3Aggregator.sol";
import {FunctionsRouter} from "@chainlink/contracts/v0.8/functions/v1_0_0/FunctionsRouter.sol";
import {FunctionsCoordinator} from "@chainlink/contracts/v0.8/functions/v1_3_0/FunctionsCoordinator.sol";
import {FunctionsBillingConfig} from "@chainlink/contracts/v0.8/functions/v1_3_0/FunctionsBilling.sol";
import {TermsOfServiceAllowList, TermsOfServiceAllowListConfig} from "@chainlink/contracts/v0.8/functions/v1_3_0/accessControl/TermsOfServiceAllowList.sol";

import {Script} from "forge-std/Script.sol";

contract FunctionsConstants {
    string public constant DON_ID = "local-functions-testnet";
}

contract FunctionsSetup is Script, FunctionsConstants {
    function deployChainlinkContracts()
        public
        returns (
            string memory donId,
            MockLinkToken linkToken,
            FunctionsRouter router,
            FunctionsCoordinator coordinator
        )
    {
        vm.startBroadcast();
        linkToken = new MockLinkToken();

        MockV3Aggregator linkEthPriceFeed = new MockV3Aggregator(18, 2000e8);
        MockV3Aggregator linkUsdPriceFeed = new MockV3Aggregator(18, 1e8);

        router = new FunctionsRouter(
            address(linkToken),
            _getFunctionsRouterConfig()
        );

        coordinator = new FunctionsCoordinator(
            address(router),
            _getFunctionsCoordinatorConfig(),
            address(linkEthPriceFeed),
            address(linkUsdPriceFeed)
        );

        TermsOfServiceAllowList termsOfServiceAllowList = new TermsOfServiceAllowList(
                _getTermsOfServiceAllowListConfig(),
                new address[](0),
                new address[](0)
            );

        bytes32 allowListId = router.getAllowListId();
        bytes32[] memory ids = new bytes32[](2);
        address[] memory addresses = new address[](2);

        ids[0] = allowListId;
        ids[1] = bytes32(bytes("COORDINATOR"));

        addresses[0] = address(termsOfServiceAllowList);
        addresses[1] = address(coordinator);

        router.proposeContractsUpdate(ids, addresses);
        coordinator.setDONPublicKey(
            bytes(
                "0x46e62235e8ac8a4f84aa62baf7c67d73a23c5641821bab8d24a161071b90ed8295195d81ba34e4492f773c84e63617879c99480a7d9545385b56b5fdfd88d0da"
            )
        );
        coordinator.setThresholdPublicKey(
            bytes(
                "0x30783436653632323335653861633861346638346161363262616637633637643733613233633536343138323162616238643234613136313037316239306564383239353139356438316261333465343439326637373363383465363336313738373963393934383061376439353435333835623536623566646664383864306461"
            )
        );

        vm.stopBroadcast();

        return (DON_ID, linkToken, router, coordinator);
    }

    function _getFunctionsRouterConfig()
        internal
        pure
        returns (FunctionsRouter.Config memory config)
    {
        uint32[] memory maxCallbackGasLimits = new uint32[](3);
        maxCallbackGasLimits[0] = 300_000;
        maxCallbackGasLimits[1] = 500_000;
        maxCallbackGasLimits[2] = 1_000_000;

        return
            FunctionsRouter.Config({
                maxConsumersPerSubscription: 100,
                adminFee: 0,
                handleOracleFulfillmentSelector: 0x0ca76175,
                gasForCallExactCheck: 5000,
                maxCallbackGasLimits: maxCallbackGasLimits,
                subscriptionDepositMinimumRequests: 0,
                subscriptionDepositJuels: 0
            });
    }

    function _getFunctionsCoordinatorConfig()
        internal
        pure
        returns (FunctionsBillingConfig memory config)
    {
        return
            FunctionsBillingConfig({
                fulfillmentGasPriceOverEstimationBP: 0,
                feedStalenessSeconds: 86_400,
                gasOverheadBeforeCallback: 44_615,
                gasOverheadAfterCallback: 44_615,
                minimumEstimateGasPriceWei: 1000000000,
                maxSupportedRequestDataVersion: 1,
                fallbackUsdPerUnitLink: 1e18,
                fallbackUsdPerUnitLinkDecimals: 8,
                fallbackNativePerUnitLink: 1400000000,
                requestTimeoutSeconds: 0,
                donFeeCentsUsd: 100,
                operationFeeCentsUsd: 0
            });
    }

    function _getTermsOfServiceAllowListConfig()
        internal
        pure
        returns (TermsOfServiceAllowListConfig memory config)
    {
        return
            TermsOfServiceAllowListConfig({
                enabled: false,
                signerPublicKey: address(0)
            });
    }
}
