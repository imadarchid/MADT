// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FunctionsSetup} from "./Functions/FunctionsSetup.s.sol";
import {MockLinkToken} from "@chainlink/contracts/v0.8/mocks/MockLinkToken.sol";
import {FunctionsRouter} from "@chainlink/contracts/v0.8/functions/v1_0_0/FunctionsRouter.sol";
import {FunctionsCoordinator} from "@chainlink/contracts/v0.8/functions/v1_3_0/FunctionsCoordinator.sol";

contract HelperConfig is Script {
    // If we are on a local chain, we deploy the mock contract
    // Otherwise, we fetch the existing address from the live network

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;

    struct NetworkConfig {
        address linkToken;
        address usdToken;
        uint256 subscriptionId;
        bytes32 donId;
        address router;
    }

    NetworkConfig public activeNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfig;

    constructor() {
        if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory sepoliaConfig) {
        sepoliaConfig = NetworkConfig({
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            usdToken: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            subscriptionId: 4303,
            donId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000,
            router: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0
        });

        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory anvilConfig) {
        (string memory donId, MockLinkToken linkToken, FunctionsRouter router, FunctionsCoordinator coordinator) =
            new FunctionsSetup().deployChainlinkContracts();

        console.log("donId", donId);
        console.log("linkToken", address(linkToken));
        console.log("router", address(router));
        console.log("coordinator", address(coordinator));

        anvilConfig = NetworkConfig({
            linkToken: address(linkToken),
            usdToken: address(0),
            subscriptionId: 0,
            donId: bytes32(bytes(donId)),
            router: address(router)
        });

        return anvilConfig;
    }

    function getNetworkConfig() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }
}
