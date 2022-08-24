module.exports = async ({ ethers, getNamedAccounts, deployments, getChainId, getUnnamedAccounts }) => {
    const { deploy } = deployments;
    const { deployer} = await ethers.getNamedSigners();
    const deployerAddress = deployer.address;

    const price = ethers.utils.parseUnits("0.01", 18);
    const yield = ethers.utils.parseUnits("100", 18);
    const matureTime = 1*24*60*60;
    const oneDayLimit = 1000;

    await deploy("Seed", {
        from: deployerAddress,
        contract: "Seed",
        log: true,
        args:["Maize","MZ",price,yield,matureTime,oneDayLimit],
        deterministicDeployment: false
    });

    let contract = await ethers.getContract('Seed');
    let info = {
        Cutaverse: {
            contractAddress: contract.address
        }
    }
    console.log(info);

};
module.exports.tags = ['Seed'];