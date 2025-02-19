#!/usr/bin/env node

import { ethers, providers } from "ethers";
import fs from "fs";
import path from "path";

async function main() {
  const args = process.argv.slice(2);
  if (args.length < 1) {
    console.error("Usage: setSource <consumerAddress> [port]");
    process.exit(1);
  }

  const consumerAddress = args[0];
  const port = args[1] ? parseInt(args[1]) : 8545;

  await setSource(consumerAddress, port);
}

async function setSource(consumerAddress: string, port: number = 8545) {
  // Connect to local Anvil chain
  const provider = new providers.JsonRpcProvider(`http://localhost:${port}`);

  // Get the first signer account from Anvil
  const signer = await provider.getSigner();

  // ABI fragment for the function we need
  const abi = [
    {
      inputs: [
        {
          internalType: "string",
          name: "s_sourceCode",
          type: "string",
        },
      ],
      name: "setSourceCode",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
  ];

  // Create contract instance
  const contract = new ethers.Contract(consumerAddress, abi, signer);

  // Read the source code from file
  const sourceCode = fs.readFileSync(path.join(__dirname, "./source/source.js")).toString();

  // Set the source code
  const tx = await contract.setSourceCode(sourceCode);
  await tx.wait();

  console.log("Source code set successfully");
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

export { setSource };
