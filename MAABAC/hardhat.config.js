/**
* @type import('hardhat/config').HardhatUserConfig
*/

require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");



module.exports = {
   defaultNetwork: "polygon_mumbai",
   networks: {
     hardhat: {
     },
     polygon_mumbai: {
       url: "https://rpc-mumbai.maticvigil.com",
       accounts: [process.env.PRIVATE_KEY]
     }
   },
   etherscan: {
     apiKey: process.env.POLYGONSCAN_API_KEY
   },
   solidity: {
     version: "0.8.17",
     settings: {
       optimizer: {
         enabled: true,
         runs: 200
       }
     }
   },
  
}
