const { expect } = require("chai");
const hre = require("hardhat");

async function localTest(){
    const lenderMasterAddress = '0x62d36a245c35c2c6ccb6b72a5c83d7DeB436E2e4';
    const [main] = await hre.ethers.getSigners();
    console.log('main:', main.address);
    const MQuery = await hre.ethers.getContractFactory("MQuery");
    const que = await MQuery.deploy(lenderMasterAddress);
    await que.deployed();
    console.log('MQuery deployed:', que.address);
    const marketAddress = '0x41d73395D9ac9E3AFbCbE5303658d1A64BEDfe71';
    let out = await que.cnft(marketAddress);
    console.log('out:',out);
}
describe("MQuery", function () {
    it("Test MQuery", async function () {
        const lenderMasterAddress = '0x62d36a245c35c2c6ccb6b72a5c83d7DeB436E2e4';
        const [main] = await hre.ethers.getSigners();
        console.log('main:', main.address);
        const MQuery = await hre.ethers.getContractFactory("MQuery");
        const que = await MQuery.deploy(lenderMasterAddress);
        await que.deployed();
        console.log('MQuery deployed:', que.address);
        const marketAddress = '0x41d73395D9ac9E3AFbCbE5303658d1A64BEDfe71';
        let out = await que.cnft(marketAddress);
        console.log('out:',out);

        // 0x536990D0f1844fcbC06168BB018d862782588fA6
    })
});