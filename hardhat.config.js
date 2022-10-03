/** @type import('hardhat/config').HardhatUserConfig */
require('@nomiclabs/hardhat-waffle')
const ALCHEMY_API_KEY = "Ffzi5wIdGtD2i9oiDmUGt5tLQtbJAnz8";
const GOERLI_PRIVATE_KEY = "e02fb88e9e105b6cdfe473ebdd8bf4179497e6d877272907b63d77a590ec61f6";
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`${GOERLI_PRIVATE_KEY}`]
    }
  }
};
