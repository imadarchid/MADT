task("deploy-token", "Deploys the MADT contract")
  .addParam("consumer", "The address of the exchangeConsumer contract")
  .addParam("usdtadd", "The address of the USDT contract")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre
    const MADT = await ethers.getContractFactory("MADT")
    const madToken = await MADT.deploy(taskArgs.consumer, taskArgs.usdtadd)
    await madToken.deployed()

    console.log("MADT deployed to:", madToken.address)

    return madToken.address
  })
