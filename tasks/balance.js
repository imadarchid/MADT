const network = process.env.NETWORK

task("balance", "Prints an account's balance")
  .addParam("account", "The account's address")
  .addOptionalParam("token", "Balance for a specific token address")
  .addOptionalParam("ticker", "Token ticker")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre
    const provider = ethers.getDefaultProvider("http://localhost:8545/")

    let balance

    if (taskArgs.token) {
      const tokenAddress = await ethers.getContractAt(taskArgs.ticker, taskArgs.token)
      balance = await tokenAddress.balanceOf(taskArgs.account)
      console.log(`${taskArgs.ticker} balance of ${taskArgs.account}: ${ethers.utils.formatUnits(balance, 18)}`)
      return ethers.utils.formatUnits(balance, 18)
    } else {
      balance = await provider.getBalance(taskArgs.account)
      console.log(ethers.utils.formatEther(balance), "ETH")
      return ethers.utils.formatUnits(balance, 7)
    }
  })
