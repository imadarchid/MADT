task("mint-token", "Mints MADT tokens")
  .addParam("address", "The address of the MADT contract")
  .addParam("amount", "USDT to mint")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre
    const MADT = await ethers.getContractFactory("MADT")

    const token = await MADT.attach(taskArgs.address)

    try {
      await token.mint(ethers.utils.parseUnits(taskArgs.amount))
      console.log(`Minted ${taskArgs.amount} USDT worth of MADT at address ${taskArgs.address}`)
      return taskArgs.amount
    } catch (error) {
      console.log("Error minting MADT")
      console.error(error)
    }
  })
