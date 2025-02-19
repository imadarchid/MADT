include .env
.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

-include ${FCT_PLUGIN_PATH}/makefile-sandbox

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"
# Update Dependencies
update:; forge update

build:; forge build

test :; forge test

snapshot :; forge snapshot

format :; forge fmt

simulate-don: 
	printf "%s\n" "Launching local don simulator..." && \
	npx tsx ./don-simulator/src/localFunctionsTestnet.ts

setup-functions:
	forge script script/FunctionsScript.s.sol:FunctionsScript --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

deploy-all:
	make deploy-madt && \
	make deploy-usdt && \
	make setup-functions && \
	make send-request && \
	make deploy-vault

# Interactions with the DON via the DataProvider contract
send-request:
	forge script script/Interactions.s.sol:Interactions --sig "sendRequest()" --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast -vv

get-last-response:
	forge script script/Interactions.s.sol:Interactions --sig "getLastResponse()" --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast -vv

get-last-error:
	cast call $(CONTRACT_ADDRESS) "getLastError()" --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY)

get-last-request-id:
	cast call $(CONTRACT_ADDRESS) "getLastRequestId()" --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY)

# Deploy the MADT and Vault contract
deploy-madt:
	forge script script/DeployMADT.s.sol:DeployMADT --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

deploy-usdt:
	forge script script/DeployMockUSDT.s.sol:DeployMockUSDT --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

deploy-vault:
	forge script script/DeployVault.s.sol:DeployVault --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast -vv

# Interactions with the Vault contract
# Deposit collateral
deposit-collateral:
	forge script script/VaultInteractions.s.sol:VaultInteractions --sig "depositCollateral()" --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast -vv

# Redeem collateral
redeem-collateral:
	forge script script/VaultInteractions.s.sol:VaultInteractions --sig "redeemCollateral(uint256)" $(AMOUNT) --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast -vv

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --interactive --broadcast --verify -vvvv
endif

