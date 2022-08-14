// const {ethers} = require("hardhat");
// const fs = require("fs")
//
// const toWei = (eth)=>ethers.utils.parseEther(""+eth)

module.exports = async({getNamedAccounts,deployments,getChainId})=>{
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    const token = await ethers.getContract("TokenV2")

    await deploy("Farm",{
        from:deployer,
        args:[token.address,8],
        log:true
    })

};
module.exports.tags = ['Farm'];
module.exports.dependencies = ['TokenV2']