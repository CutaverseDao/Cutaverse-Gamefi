module.exports = async ({ ethers, getNamedAccounts, deployments, getChainId, getUnnamedAccounts }) => {
    const { deploy } = deployments;
    const { deployer} = await ethers.getNamedSigners();
    const deployerAddress = deployer.address;
    //Ganche网络部署使用配置的账号进行部署
    // const accounts = await ethers.getSigners();
    // const deployerAddress = accounts[0].address;
    console.log("deployerAddress=",deployerAddress);

    const cap = ethers.utils.parseUnits("100000000", 18);

    await deploy("Cutaverse", {
        from: deployerAddress,
        contract: "Cutaverse",
        log: true,
        args: [cap,"Cut","CU"],
        deterministicDeployment: false
    });

    let contract = await ethers.getContract('Cutaverse');
    let info = {
        Cutaverse: {
            contractAddress: contract.address
        }
    }
    console.log(info);
}
module.exports.tags = ["Cutaverse"]