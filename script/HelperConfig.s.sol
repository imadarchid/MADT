// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {MockUSDT} from "../test/mocks/MockUSDT.sol";

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
        address coordinator;
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

    function getSepoliaEthConfig()
        public
        pure
        returns (NetworkConfig memory sepoliaConfig)
    {
        sepoliaConfig = NetworkConfig({
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            usdToken: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            subscriptionId: 4303,
            donId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000,
            router: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
            coordinator: 0x74Ef777777777777777777777777777777777777
        });

        return sepoliaConfig;
    }

    function getAnvilEthConfig()
        public
        returns (NetworkConfig memory anvilConfig)
    {
        MockUSDT usdt = new MockUSDT();
        anvilConfig = NetworkConfig({
            linkToken: vm.envAddress("LINK_TOKEN_ADDRESS"),
            usdToken: address(usdt),
            subscriptionId: 1,
            donId: stringToBytes32(vm.envString("DON_ID")),
            router: vm.envAddress("FUNCTIONS_ROUTER_ADDRESS"),
            coordinator: vm.envAddress("MOCK_COORDINATOR_ADDRESS")
        });

        return anvilConfig;
    }

    function getNetworkConfig() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    function stringToBytes32(
        string memory source
    ) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
