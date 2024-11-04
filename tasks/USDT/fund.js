const { task } = require("hardhat/config")

task("fund-usdt", "Deploys the USDT token contract").setAction(async (taskArgs, hre) => {
  const { ethers } = hre
  const USDT = await ethers.getContractFactory("USDT")
  const usdt = await USDT.deploy()
  await usdt.deployed()

  console.log("USDT deployed to:", usdt.address)

  return usdt.address
})
