// const {ethers} = require("hardhat");
// const fs = require("fs")
//
// const toWei = (eth)=>ethers.utils.parseEther(""+eth)

module.exports = async({getNamedAccounts,deployments,getChainId})=>{
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    await deploy("Seed",{
        from:deployer,
        args:["hlb","HLB",3600,200,100],
        log:true
    })

};
module.exports.tags = ['Seed'];
module.exports.dependencies = ['TokenV2']