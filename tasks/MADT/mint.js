task("mint-token", "Mints MADT tokens")
  .addParam("address", "The address of the MADT contract")
  .addParam("amount", "The amount of tokens to mint")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre;
    const MADT = await ethers.getContractFactory("MADT");
    const token = await MADT.attach(taskArgs.address);

    // Mint tokens
    await token.mint(taskArgs.amount);

    console.log(`Minted ${taskArgs.amount} tokens of MADT at address ${taskArgs.address}`);
  });