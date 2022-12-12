require('@nomiclabs/hardhat-ethers')
require('@openzeppelin/hardhat-upgrades')
require('@nomiclabs/hardhat-etherscan')
require('hardhat-contract-sizer');
require('dotenv').config()

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: 'localhost',
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    // rinkeby: {
    //   url: process.env.ALCHEMYKEY_RINKEBY,
    //   accounts: [process.env.PRIVATEKEY],
    // },
    // goerli: {
    //   url: process.env.ALCHEMYKEY_GOERLI,
    //   accounts: [process.env.PRIVATEKEY],
    // },
    // mumbai: {
    //   url: process.env.ALCHEMYKEY_POLYGON,
    //   accounts: [process.env.PRIVATEKEY],
    // },
  },
  solidity: {
    version: '0.8.15',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  etherscan: {
    apiKey: {
      rinkeby: process.env.ETHERSCAN_KEY,
      goerli: process.env.ETHERSCAN_KEY,
      polygonMumbai: process.env.POLYGONSCAN_KEY,
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  mocha: {
    timeout: 40000,
  },
}
