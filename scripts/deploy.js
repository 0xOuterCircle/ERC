const hre = require("hardhat");

async function main() {
    const SD = await hre.ethers.getContractFactory("DefaultDaoFactory");
    const sd = await SD.deploy();
    await sd.deployed();

    console.log("DefaultDaoFactory contract is deployed to:", sd.address)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
