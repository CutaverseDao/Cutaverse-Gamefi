module.exports = async ({ ethers, getNamedAccounts, deployments, getChainId, getUnnamedAccounts }) => {
    const { deploy } = deployments;
    const { deployer} = await ethers.getNamedSigners();
    const deployerAddress = deployer.address;

    const feeTo = "0xdd765bD518F247703771BCda4B56cdE2DCa6B185";
    const createFarmPrice = ethers.utils.parseUnits("0.05", 18);
    const landUintPrice = ethers.utils.parseUnits("0.02", 18);
    //wateringRate = 50
    const wateringRate = ethers.utils.parseUnits("0.05", 3);

    let cutaverse = await ethers.getContract('Cutaverse');
    let cutaverseAddr = cutaverse.address;
    console.log("cutaverseAddr=", cutaverseAddr);

    await deploy("Farm", {
        from: deployerAddress,
        contract: "Farm",
        log: true,
        args:[cutaverseAddr,feeTo,createFarmPrice,landUintPrice,wateringRate],
        deterministicDeployment: false
    });

    let contract = await ethers.getContract('Farm');
    let info = {
        Cutaverse: {
            contractAddress: contract.address
        }
    }
    console.log(info);

};
module.exports.tags = ['Farm'];
module.exports.dependencies = ['Cutaverse']