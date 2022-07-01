require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-etherscan");
require('hardhat-contract-sizer');
require("hardhat-gas-reporter");

let secrets = require("./secrets");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "hardhat",
  optimizer: {
    enabled: true,
    runs: 1000,
  },
  networks: {
    hardhat: {
      loggingEnabled: true,
      gasPrice: 20000000000
    },
    rinkeby: {
      url: secrets.url,
      accounts: [secrets.key1, secrets.key2, secrets.key3],
      gas: 100000,
      gasPrice: 8000000000
    },
    ropsten: {
      url: secrets.url_ropsten,
      accounts: [secrets.key1, secrets.key2, secrets.key3],
      gas: 2100000,
      gasPrice: 8000000000
    },
    eth: {
      url: "https://eth-mainnet.alchemyapi.io/v2/SgucBf1iFfhnCzz_1_-T4jTwx-1aurLy",
      accounts: [secrets.PRIVKEYMAINNET],
      gasPrice: 32000000000
    },
    arbitrum: {
      url: secrets.ARBITRUM_RPC,
      accounts: [secrets.key1, secrets.key2, secrets.key3],
    },
  },
  etherscan: {

    apiKey: {
      rinkeby: secrets.APIKEY_RINKEBY,
      arbitrumTestnet: secrets.APIKEY_ARBITRUM_TESTNET,
      mainnet: secrets.APIKEY_ETH_MAINNET,
    }
  },
  mocha: {
    timeout: 600000,
    // reporter: 'eth-gas-reporter',
    // eporterOptions: {
    //   currency: 'USD', outputFile: 'gasreport.txt',
    //   url: 'http://localhost:8545'
    // }
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
    gasPrice: 19,
    coinmarketcap: secrets.CoinmarketcapApi,
    //outputFile: './createdData/gasreport.txt',
  }
};
