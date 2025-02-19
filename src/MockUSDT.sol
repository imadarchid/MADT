// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20 {
    // USDT uses 6 decimals
    uint8 private constant DECIMALS = 6;
    uint256 private constant INITIAL_SUPPLY = 1000e18;

    constructor() ERC20("Mock USDT", "USDT") {
        _mint(msg.sender, 100000000000000000000);
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    // Function to mint tokens for testing
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // Function to burn tokens for testing
    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}
