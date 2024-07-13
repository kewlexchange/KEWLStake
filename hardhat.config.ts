import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "@nomiclabs/hardhat-web3";
import "hardhat-contract-sizer"
require('hardhat-contract-sizer');
require("@openzeppelin/hardhat-upgrades");
import "hardhat-diamond-abi";


dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


// @ts-ignore
const config: HardhatUserConfig = {
  contractSizer: {
    alphaSort: true,
    runOnCompile: false,
    disambiguatePaths: false,
  },
  diamondAbi: {
    strict: false,
    name: "KEWLSTAKE",
    include: ["KEWL","Settings","Vault","Factory"],
    exclude: [],
  },
  solidity: {
    compilers: [
      {
        version: "0.4.18"
      },
      /*  {
          version: "0.5.16"
        },
        {
          version: "0.6.2"
        },
        {
          version: "0.6.6",
          settings: {
            optimizer: {
              enabled: true,
              runs: 1000
            },
            outputSelection: {
              "*": {
                "*": ["storageLayout"],
              },
            },
          }
        },
        {
          version: "0.7.0"
        },
        {
          version: "0.7.6",
          settings: {
            optimizer: {
              enabled: true,
              runs: 1000
            },
            outputSelection: {
              "*": {
                "*": ["storageLayout"],
              },
            },
          }
        },
        {
          version: "0.8.0",
          settings: {
            optimizer: {
              enabled: true,
              runs: 1000
            },
            outputSelection: {
              "*": {
                "*": ["storageLayout"],
              },
            },
          }
        },
        {
          version: "0.8.8",
          settings: {
            optimizer: {
              enabled: true,
              runs: 200
            }
          }
        },*/
        {
          version: "0.8.20",
          settings: {
            optimizer: {
              enabled: true,
              runs: 200,
            },
          },
        },
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.13",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.14",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      }
    ]
  },
  mocha: {
    timeout: 1000000
  },
  networks: {
    hardhat:  {
      allowUnlimitedContractSize: true,
      blockGasLimit:8000000
    },
    matic: {
      url: process.env.MATIC_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    sepolia: {
      url: process.env.SEPOLIA_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    goerli: {
      url: process.env.GOERLI_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    mumbai: {
      url: process.env.MUMBAI_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    eth: {
      url: process.env.ETH_MAIN || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    oe: {
      url: process.env.OPTIMISM_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    oekovan: {
      url: process.env.OPTIMISM_KOVAN_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    ropsten: {
      url: process.env.ROPSTEN_HTTP || "",
      //gasPrice: 1000000000,
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    rinkeby: {
      url: process.env.RINKEBY_HTTP || "",
      gasPrice: 1000000000,
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    kovan: {
      url: process.env.KOVAN_HTTP || "",
      gasPrice: 1000000000,
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    avax:{
      url: process.env.AVAX_MAIN_HTTP || "",
      // gasPrice: 470000000000,
      chainId: 43114,
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    avaxfuji: {
      allowUnlimitedContractSize: true,
      url: process.env.AVAX_FUJI_HTTP || "",
      //gasPrice: 470000000000,
      chainId: 43113,
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    bsc: {
      url: process.env.BSC_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    ftm: {
      url: process.env.FTM_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    kcs: {
      url: process.env.KCS_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    ftmtest: {
      url: process.env.FTM_TEST || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    bsctest: {
      allowUnlimitedContractSize: true,
      url: process.env.BSC_TEST_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    polygon: {
      chainId: 137,
      url: process.env.POLYGON_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    arbitrum: {
      chainId: 42161,
      url: process.env.ARBITRUM_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    gmbl: {
      chainId: 8866,
      url: process.env.GMBL_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    arb: {
      chainId: 42161,
      url: process.env.ARBITRUM_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    polygontest: {
      chainId: 80001,
      allowUnlimitedContractSize: true,
      url: process.env.POLYGON_TEST_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    bitci: {
      chainId: 1907,
      allowUnlimitedContractSize: true,
      url: process.env.BITCI_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    bitcitest: {
      chainId: 1908,
      allowUnlimitedContractSize: true,
      url: process.env.BITCI_TEST_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    chiliz: {
      chainId: 88888,
      allowUnlimitedContractSize: true,
      url: process.env.CHILIZ_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    chilizspicy: {
      chainId: 88882,
      allowUnlimitedContractSize: true,
      url: process.env.CHILIZ_SPICY_HTTP || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: false,
    showTimeSpent: false,
    gasPrice: 225,
    currency:'USD'
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
