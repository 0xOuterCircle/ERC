const hre = require("hardhat");

async function main() {
    const DDF = await hre.ethers.getContractFactory("DefaultDaoFactory");
    const ddf = await DDF.deploy();
    await ddf.deployed();
    console.log("DefaultDaoFactory contract is deployed to:", ddf.address)

    const DGF = await hre.ethers.getContractFactory("DefaultGovernanceFactory");
    const dgf = await DGF.deploy(ddf.address);
    await dgf.deployed();
    console.log("DefaultGovernanceFactory contract is deployed to:", dgf.address)

    let tx = await ddf.setGovernanceFactory(dgf.address);
    await tx.wait();

    console.log("Pipeline's completed")
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
