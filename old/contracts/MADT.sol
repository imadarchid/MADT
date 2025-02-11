// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface ExchangeConsumer {
  function s_lastResponse() external returns (bytes memory);
}

contract MADT is ERC20, AccessControl {
  IERC20 public usdtToken;

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  address public exchangeConsumer;

  constructor(address _exchangeConsumer, address _usdtAddress) ERC20("MAD Tokenized", "MADT") {
    usdtToken = IERC20(_usdtAddress);
    exchangeConsumer = _exchangeConsumer;

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
  }

  function mint(uint256 _amount) external {
    // Check if the user has approved the contract to spend USDT
    uint256 allowance = usdtToken.allowance(msg.sender, address(this));
    require(allowance >= _amount, "Check the token allowance");

    // Fetch the latest exchange rate from Oracle network
    bytes memory latestRateBytes = ExchangeConsumer(exchangeConsumer).s_lastResponse();
    uint256 latestRate = abi.decode(latestRateBytes, (uint256));
    require(latestRate > 0, "Invalid price data");

    // Transfer USDT from the user to the contract
    bool success = usdtToken.transferFrom(msg.sender, address(this), _amount);
    require(success, "USDT transfer failed");

    uint256 convertedAmount = (_amount * latestRate) / 100;
    convertedAmount = convertedAmount - (convertedAmount * 3) / 100; // 3% fee for oracle usage | TODO: Analyze oracle fee structure

    _mint(msg.sender, convertedAmount);
  }

  // Withdraw USDT by burning MADT tokens
  function withdraw(uint256 _amount) external {
    // Get user MADT balance
    uint256 balance = this.balanceOf(msg.sender);

    // Fetch the latest exchange rate
    bytes memory latestRateBytes = ExchangeConsumer(exchangeConsumer).s_lastResponse();
    uint256 latestRate = abi.decode(latestRateBytes, (uint256));
    require(latestRate > 0, "Invalid price data");

    require(balance >= _amount, "Insufficient contract balance");

    // @TODO: What happens if the rate changes and not enough USDT is available in the reserve?
    uint256 withdrawableUSDT = (_amount * 100) / latestRate;

    // Burn the equivalent amount of MADT from the user's balance
    _burn(msg.sender, _amount);

    // Withdraw USDT from the contract
    bool success = usdtToken.transfer(msg.sender, withdrawableUSDT);
    require(success, "USDT withdrawal failed");
  }

  function getBalance(address account) public view returns (uint256) {
    return balanceOf(account);
  }

  function setUSDTAddress(address _usdtAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
    usdtToken = IERC20(_usdtAddress);
  }

  function decimals() public pure override returns (uint8) {
    return 18;
  }

  function updatePriceConsumer(address _exchangeConsumer) external onlyRole(DEFAULT_ADMIN_ROLE) {
    exchangeConsumer = _exchangeConsumer;
  }
}
