require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");


const HqConfig = require('./HqConfig');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "ropsten",
  networks:{
  
    hardhat:{
      forking:{
        url: "https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
        blockNumber:12718020 
      }
    },
    rinkeby:{
      url: "https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: [HqConfig.lender.privateKey]
    },
    ropsten:{
      url:'https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
      accounts: [HqConfig.lender.privateKey]
    },
    localhost:{
      url:"http://127.0.0.1:8545/",
    }
  },
  solidity: { 
    version: "0.8.15",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  etherscan:{
    apiKey: HqConfig.apiKey.ropsten,
  },
};
// npx hardhat verify ----constructor-args 0x3a71e9A4d27BEA1B6Dd4A2263C3415ac9351213B  --contract  0x2964e2FDA052fADf577a350afDb8559A692D3cB8 --list-networks ropsten
