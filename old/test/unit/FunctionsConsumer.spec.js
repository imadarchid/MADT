const { expect } = require("chai")
const { getPriceUSD } = require("../../tasks/utils/price")

describe("Dry run", async function () {
  // To do: add actual unit tests

  it("Mint 5 USDT - Sufficient Balance", async () => {
    let signer = await ethers.getSigner()

    let subId = await hre.run("functions-sub-create", { amount: "10" }) // in LINK
    subId = subId.toString()
    let consumer = await hre.run("functions-deploy-auto-consumer", { subid: subId })

    let USDTAddress = await hre.run("fund-usdt")
    let MADTAddress = await hre.run("deploy-token", { consumer: consumer, usdtadd: USDTAddress })

    let startingUSDTBalance = await hre.run("balance", { account: signer.address, token: USDTAddress, ticker: "USDT" })

    await hre.run("approve-usdt", { tokenadd: USDTAddress, spender: MADTAddress, amount: "1000" })
    await hre.run("functions-request", { contract: consumer, subid: subId })

    let mintedTokens = await hre.run("mint-token", { address: MADTAddress, amount: "5" })

    let finalUSDTBalance = await hre.run("balance", { account: signer.address, token: USDTAddress, ticker: "USDT" })
    let finalMADTBalance = await hre.run("balance", { account: signer.address, token: MADTAddress, ticker: "MADT" })

    await hre.run("redeem", { address: MADTAddress, amount: "47.25" })

    finalMADTBalance = await hre.run("balance", { account: signer.address, token: MADTAddress, ticker: "MADT" })
    finalUSDTBalance = await hre.run("balance", { account: signer.address, token: USDTAddress, ticker: "USDT" })

    expect(finalMADTBalance).to.equal("0.5225")
  })

  // it("Mint 5 USDT - Insufficient Balance", async () => {
  //   let subId = await hre.run("functions-sub-create", { amount: "10" }) // in LINK
  //   subId = subId.toString()
  //   let consumer = await hre.run("functions-deploy-auto-consumer", { subid: subId })

  //   let USDTAddress = await hre.run("fund-usdt")
  //   let MADTAddress = await hre.run("deploy-token", { consumer: consumer, usdtadd: USDTAddress })

  //   await hre.run("approve-usdt", { tokenadd: USDTAddress, spender: MADTAddress, amount: "1"})
  //   let mintedTokens = await hre.run("mint-token", { address: MADTAddress, amount: "5" })

  //   expect(mintedTokens).to.equal(undefined)
  // })
})
