const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
const chai = require("chai");
chai.use(solidity);
const { expect } = require("chai");
const request = require('request');
const hre = require("hardhat");

describe("Default Contracts", function () {

    let ddf;
    let signers;
    let addresses = [];

    before(async function () {

        signers = await ethers.getSigners();
        for (const i in signers) {
            addresses.push(signers[i].address.toLowerCase())
        }

        const DDF = await ethers.getContractFactory("DefaultDaoFactory");
        ddf = await DDF.deploy();
        await ddf.deployed();

        const DGF = await hre.ethers.getContractFactory("DefaultGovernanceFactory");
        const dgf = await DGF.deploy(ddf.address);
        await dgf.deployed();

        let tx = await ddf.setGovernanceFactory(dgf.address);
        await tx.wait();
    })

    describe("Main", function () {

        it("Should deploy new Default Dao Controller with Governance", async function () {
            let tx = await ddf.deployDao(
                1000000,
                100,
                '0x0000000000000000000000000000000000000000',
                'OuterCircle DAO',
                100,
                'OC'
            )
            await tx.wait()

            let dao = await ddf.daos(0)
            dao = await hre.ethers.getContractAt("DefaultDaoController", dao);
            let governance = await dao.governance();
            governance = await hre.ethers.getContractAt("DefaultGovernance", governance);

            expect(await dao.governance()).to.equal(governance.address)
            expect(await governance.dao()).to.equal(dao.address)

            expect(await dao.votingPowerOf(addresses[0])).to
            .equal(await governance.balanceOf(addresses[0]))

            await (await governance.transfer(addresses[1], 30)).wait();

            expect(await dao.votingPowerOf(addresses[0])).to
            .equal(await governance.balanceOf(addresses[0]))

            expect(await dao.votingPowerOf(addresses[1])).to
            .equal(await governance.balanceOf(addresses[1]))
        });

    });
});
