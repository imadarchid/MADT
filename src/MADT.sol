// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MADT is ERC20, Ownable {
    error MADT__NotVault();
    error MADT__InvalidVaultAddress();

    address public vault;

    constructor() ERC20("Tokenized MAD", "MADT") Ownable(msg.sender) {}

    modifier onlyVault() {
        if (msg.sender != vault) revert MADT__NotVault();
        _;
    }

    function setVault(address _vault) external onlyOwner {
        if (_vault == address(0)) revert MADT__InvalidVaultAddress();
        vault = _vault;
    }

    function mint(address to, uint256 amount) public onlyVault {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyVault {
        _burn(from, amount);
    }
}
