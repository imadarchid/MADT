Currently there is no way to simulate a Chainlink Functions request on a local chain (Anvil).

The way it's done on Hardhat is by using the startLocalFunctionsTestnet, which spins up a local Ganache server and funds the wallets with ETH and LINK.
We're going to adapt this for Foundry and Anvil. To start, we need to review how startLocalFunctionsTestnet works.

Steps:

1. Starts a server
2. Gets the address of the first account and its private key.
3. Creates a wallet instance from the private key.
4. Deploys the functions oracle using deployFunctionsOracle. This requires a deployer wallet instance.
5. The function uses the wallet to build contract factory instances fo the link token, the link price feed factory (deploys eth price feed, and link price feed), and the function router (takes the link token address as an argument). It also deploys the mock coordinator (which takes the router address, the price feeds, and the simulated coordinator config), it also deploys the allowlist and uses it to propose contract updates. the mock coordinator connects and sets the DON public key address.
6. the function returns a simulated donId, a link token contract, a functions router contract, and a functionsMockCoordinatorContract.

A bunch of default and simulated values are used, they are located under src/localFunctionsTestnet.ts

LinkTokenSource
MockV3Aggregator
FunctionsRouter
FunctionsCoordinatorTestHelper
TermsOfServiceAllowList

these are all contracts made available by chainlink.
