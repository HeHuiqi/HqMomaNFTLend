// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  let lenderMasterAddress = '0x62d36a245c35c2c6ccb6b72a5c83d7DeB436E2e4';
  lenderMasterAddress = '0x3a71e9A4d27BEA1B6Dd4A2263C3415ac9351213B';

  const MQuery = await hre.ethers.getContractFactory("MQuery");
  const que = await MQuery.deploy(lenderMasterAddress);

  await que.deployed();

  console.log("MQuery deployed to:", que.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
