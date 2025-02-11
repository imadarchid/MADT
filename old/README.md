# MADT

This is an educational project where we attempt to create a tokenized version of the Moroccan Dirham (MADT). The point of this project is to propose a mechanism by which we can create a syntethic token that is derived from the USD/MAD parity. The project also aims to explain how key features of Chainlink (Functions, Automation, CCIP) can be implemented.

## Token features

- ERC20.
- Uncapped supply (Supply should match the amount in reserve minus fees).
- Mint fee of 5% to fund chain operations (Oracle & Automation fees).
- Value of token is pegged to the value of MAD from custom price feeds.

## Use case

This project is for educational purposes only. A synthetic asset such as MADT could be used for transactions in the context of:

- Hedging against FX rate fluctuations
- Settling P2P transactions

## Roadmap

**Smart contract**
- [x] USD/MAD aggregation function
- [x] Mint and Burn mechanisms
- [x] Consumer contract with automation support

**Tokenomics**
- [ ] Reserve mechanism
- [ ] Fees associated with using Chainlink Automation & Functions
- [ ] Currency exchange risk and liquidity risk

**Other**
- [ ] UI to interact with the smart contract
- [ ] More details on potential use cases
- [ ] Deployment on Sepolia
- [ ] Using more efficient/less expensive chains
 
## Resources

This repository is based on Chainlink's hardhat starter project. I have borrowed heavily from their codebase while making adjustments for this use case.
You will need to use Hardhat for the purposes of building, testing, and deploying the smart contracts.
