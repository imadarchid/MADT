// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface ExchangeConsumer {
    function sendRequest() external returns (bytes32);
    function fulfillRequest() external returns (uint32);
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

        // // Transfer USDT from the user to the contract
        bool success = usdtToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "USDT transfer failed");

        ExchangeConsumer(exchangeConsumer).sendRequest();
        uint256 latestRate = ExchangeConsumer(exchangeConsumer).fulfillRequest();
        require(latestRate > 0, "Invalid price data");

        uint256 convertedAmount = _amount * latestRate;

        // Mint the equivalent amount of MyToken to the user
        _mint(msg.sender, convertedAmount);
    }

    function withdrawUSDT(uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // Withdraw USDT from the contract
        bool success = usdtToken.transfer(msg.sender, _amount);
        require(success, "USDT withdrawal failed");
    }

    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function setUSDTAddress(address _usdtAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        usdtToken = IERC20(_usdtAddress);
    }

	function decimals() public pure override returns (uint8) {
    	return 2;
	}

    function updatePriceConsumer(address _exchangeConsumer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        exchangeConsumer = _exchangeConsumer;
    }
}