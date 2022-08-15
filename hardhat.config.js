require("@nomiclabs/hardhat-waffle");
require('hardhat-deploy');
require("dotenv").config({})
const {ethers} = require('ethers')
const fs = require("fs");


const toWei = (eth)=>ethers.utils.parseEther(eth)

extendEnvironment((hre)=>{
  hre.utopoAddress = process.env.utopoAddress;
})


let accounts = [];
(async function(){
  try {
    const file = '.secret';
    var info = fs.statSync(file);
    if (!info.isDirectory()) {
      const content = fs.readFileSync(file, 'utf8');
      let lines = content.split('\n');
      for (let index = 0; index < lines.length; index ++) {
        let line = lines[index];
        if (line == undefined || line == '') {
          continue;
        }
        if (!line.startsWith('0x') || !line.startsWith('0x')) {
          line = '0x' + line;
        }
        accounts.push(line);
      }
    }
  } catch (ex) {
  }
})()

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
  solidity: "0.8.4",
  defaultNetwork: "hecotest",
  networks: {
    localhost: {
      chainId: 31337,
      url:'http://localhost:8545',
      accounts:accounts
    },
    polygon :{
      url:"https://polygon-rpc.com",
      gasPrice: 50 * 1000000000,
      chainId: 137,
      gasMultiplier: 1.5,
      accounts:accounts
    },
    mumbai :{
      url:"https://rpc-mumbai.maticvigil.com",
      gasPrice: 20 * 1000000000,
      chainId: 80001,
      gasMultiplier: 1.5,
      accounts:accounts
    },
    ganache:{
      chainId:1337,
      url:"http://localhost:7545",
      accounts:accounts
    },
    ftmtest:{
      url:'https://xapi.testnet.fantom.network/lachesis',
      chainId:4002,
      accounts:accounts
    },
    bsctest:{
      url:"https://data-seed-prebsc-1-s3.binance.org:8545/",
      chainId:97,
      accounts:accounts
    },
    hecotest: {
      url: "https://http-testnet.hecochain.com",
      accounts: accounts,
      gasPrice: 2 * 1000000000,
      chainId: 256,
    },
    ropsten:{
      url:"https://ropsten.infura.io/v3/",
      chainId:3,
      accounts:accounts
    },
    hardhat:{
      accounts:accounts.map(privateKey=>({privateKey,balance:toWei("100").toString()}))
    }
  },
  namedAccounts: {
    deployer: {
      default: '0x91fddD20F2A8dF3DFE49bd1107354C912926424e',
      128: '0x91fddD20F2A8dF3DFE49bd1107354C912926424e',
      256: '0x91fddD20F2A8dF3DFE49bd1107354C912926424e',
    },
  },
};
