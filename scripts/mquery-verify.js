
const hre = require("hardhat");
let contractAddress = '0x2964e2FDA052fADf577a350afDb8559A692D3cB8';
let lenderMasterAddress = '0x62d36a245c35c2c6ccb6b72a5c83d7DeB436E2e4';
lenderMasterAddress = '0x3a71e9A4d27BEA1B6Dd4A2263C3415ac9351213B';

async function main() {
    
    await hre.run("verify:verify", {
        address: contractAddress,
        // contract:'contracts/MQuery.sol:MQuery',
        constructorArguments: [
        lenderMasterAddress,
        ],
      });
}
main();