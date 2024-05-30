// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    constructor() ERC20("Tether", "USDT") {
        _mint(msg.sender, 1000000000000000000000000); // Mint 1,000,000 USDT with 18 decimals
    }

    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowance(sender, msg.sender) - amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return super.allowance(owner, spender);
    }
}
