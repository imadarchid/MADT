task("redeem", "Reedem MADT token for USDT")
  .addParam("address", "The address of the MADT contract")
  .addParam("amount", "USDT to redeem")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre
    const MADT = await ethers.getContractFactory("MADT")
    const token = await MADT.attach(taskArgs.address)

    try {
      await token.withdrawUSDT(ethers.utils.parseUnits(taskArgs.amount))
      console.log(`Reedemed ${taskArgs.amount} MAD`)
      return taskArgs.amount
    } catch (error) {
      console.log("Error redeeming MAD for USD")
      console.error(error)
    }
  })
