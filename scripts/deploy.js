
const hre = require("hardhat");

async function main() {

  const MSW = await hre.ethers.getContractFactory("MultiSigWallet");
  const msw = await MSW.deploy();

  await msw.deployed();
  
  console.log("Multi Signature Wallet deployed to: ", msw.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
