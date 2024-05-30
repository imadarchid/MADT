# MADT

This is an educational project where we attempt to create a tokenized version of the Moroccan Dirham (MADT). The point of this project is to propose a mechanism by which we can create syntethic tokens that are derived from the USD/MAD parity. The project also aims to explain how key features of Chainlink (Functions, Automation, CCIP) can be implemented.

## Token features

- ERC20.
- Uncapped supply (Supply should match the amount in reserve minus fees).
- Withdrawal fee of 0.05% to fund chain operations (Functions & Automation fees).
- Value of token is pegged to the value of MAD from custom price feeds.

## Use case

This project is for educational purposes only. A synthetic asset such as MADT could be used for transactions in the context of:

- Hedging against FX rate fluctuations
- Settling P2P transactions

## Roadmap

- [ ] USD/MAD Aggregation Function
- [ ] Reserve and Supply Mechanism
- [ ] Token Contract

## Resources

This repository is based on Chainlink's hardhat starter project. I have borrowed heavily from their codebase while making adjustments for this use case.

You will need to use Hardhat for the purposes of building, testing, and deplopying the smart contracts.
