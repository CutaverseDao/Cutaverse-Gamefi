// const {ethers} = require("hardhat");
// const fs = require("fs")
//
// const toWei = (eth)=>ethers.utils.parseEther(""+eth)

module.exports = async({getNamedAccounts,deployments,getChainId})=>{
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    await deploy("TokenV2",{
        from:deployer,
        args:[],
        log:true
    })

};
module.exports.tags = ['TokenV2'];