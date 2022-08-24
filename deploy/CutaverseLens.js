module.exports = async ({ ethers, getNamedAccounts, deployments, getChainId, getUnnamedAccounts }) => {
    const { deploy } = deployments;
    const { deployer} = await ethers.getNamedSigners();
    const deployerAddress = deployer.address;

    await deploy("CutaverseLens", {
        from: deployerAddress,
        contract: "CutaverseLens",
        log: true,
        args:[],
        deterministicDeployment: false
    });

    let contract = await ethers.getContract('CutaverseLens');
    let info = {
        CutaverseLens: {
            contractAddress: contract.address
        }
    }
    console.log(info);

};
module.exports.tags = ['CutaverseLens'];