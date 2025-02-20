// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MADT is ERC20, Ownable {
    error MADT__NotVault();
    error MADT__InvalidVaultAddress();

    address public vault;
    uint256 public rebaseFactor = 1e18;

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

    function balanceOf(address account) public view override returns (uint256) {
        return (super.balanceOf(account) * rebaseFactor) / 1e18;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        uint256 scaledAmount = (amount * 1e18) / rebaseFactor;
        return super.transfer(to, scaledAmount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        uint256 scaledAmount = (amount * 1e18) / rebaseFactor;
        return super.transferFrom(from, to, scaledAmount);
    }

    function rebase(uint256 madtToUSDTPrice) public onlyVault {
        require(madtToUSDTPrice > 0, "Invalid MADT to USDT price");

        // uint256 oldRebaseFactor = rebaseFactor;
        uint256 scalingFactor = 100;

        // Calculate the new rebase factor based on the ratio
        uint256 newRebaseFactor = (rebaseFactor * madtToUSDTPrice) / scalingFactor;
        rebaseFactor = newRebaseFactor;
        // emit Rebase(oldRebaseFactor, rebaseFactor);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
