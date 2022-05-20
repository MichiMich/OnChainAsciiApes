const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Mint and accessControl test", function () {


    let apeGenerator;
    let accessControl;
    let nftContract;

    const mintPrice = ethers.utils.parseUnits("1", 15);

    const apeGeneratorAddress = "0x6FAcC1220ef09efB21e4E3DAfFAfed16FFf1105e";
    const accessControlAddress = "0xc829D9A6a55382a514Bad36A5C46716Ee8EE555A";
    const nftContractAddress = "0x249F0Eea37f49Bf47692f67885d28c2273872e75";

    //Deploying contract before running tests
    beforeEach(async function () {
        //get available accounts from hardhat
        accounts = await hre.ethers.getSigners();

        apeGenerator = await hre.ethers.getContractAt("ApeGenerator", apeGeneratorAddress);
        accessControl = await hre.ethers.getContractAt("AccessControl", accessControlAddress);
        nftContract = await hre.ethers.getContractAt("OnChainAsciiApes", nftContractAddress);

    })



    it("RinkebyMintOut, mint out all apes", async function () {
        const totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply of nfts: ", totalSupplyOfNfts);
        let queriedTokenUri;
        console.log("total supply: ", totalSupplyOfNfts);

        console.log("balance of dev1: ", await nftContract.balanceOf(accounts[1].address));


        await nftContract.mint({ value: mintPrice });
        console.log("mint should be done");


        console.log("queried tokenURI: ", queriedTokenUri);


    });





});