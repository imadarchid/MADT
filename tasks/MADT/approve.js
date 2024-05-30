task("approve-usdt", "Approves a spender to spend USDT tokens")
  .addParam("tokenadd", "The address of the USDT token contract")
  .addParam("spender", "The address of the MADT contract to approve")
  .addParam("amount", "The amount of USDT tokens to approve")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre;
    const { tokenadd, spender, amount } = taskArgs;

    const USDT = await ethers.getContractAt("USDT", tokenadd);
    const approveTx = await USDT.approve(spender, amount);
    await approveTx.wait();

    console.log(`Approved ${spender} to spend ${amount} USDT tokens`);
  });
