const { expect } = require("chai");
const { ethers } = require("hardhat");
//write gen svgs to file
const fs = require('fs');

describe("Mint and accessControl test", function () {

    let apeGenerator;
    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);

    //Deploying contract before running tests
    beforeEach(async function () {
        //get available accounts from hardhat
        accounts = await hre.ethers.getSigners();

        //deploying contracts - start
        //apeGenerator
        const ApeGenerator = await hre.ethers.getContractFactory("ApeGenerator");
        apeGenerator = await ApeGenerator.deploy();
        await apeGenerator.deployed();
        console.log("ApeGenerator deployed at: ", apeGenerator.address);


        //deploy contract
        const AccessControl = await hre.ethers.getContractFactory("AccessControl");
        accessControl = await AccessControl.deploy();
        await accessControl.deployed();
        console.log("AccessControl deployed to:", accessControl.address);


        //nft mint contract specific
        const networkName = hre.network.name
        const chainId = hre.network.config.chainId
        console.log("chainId: ", chainId);
        let useSeedWithTestnet;
        if (chainId == "4" || networkName === "rinkeby") {
            //rinkeby
            console.log("seed with testnet used");
            useSeedWithTestnet = true;
        }
        const NftMintContract = await hre.ethers.getContractFactory("OnChainAsciiApesRevert");
        nftContract = await NftMintContract.deploy(useSeedWithTestnet, apeGenerator.address, accessControl.address, mintPrice); //mint price set to 1e15 = 1 finney = 0.001 eth
        await nftContract.deployed();
        console.log("nftMintContract deployed to:", nftContract.address);

        //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
        await apeGenerator.transferOwnership(nftContract.address)
        console.log("new owner of apeGenerator is now nftContract");

        //deploying contracts - end
        //todo: transfer ownership of apeGenerator, so contract NftMintcontract is now owner

    })


    it("RevertMintTest, try minting with revert", async function () {
        const totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply of nfts: ", totalSupplyOfNfts);


        await nftContract.enablePublicMint();
        console.log("public mint enabled");



        //lets mint a token, we expect it to be reverted because the function returns false
        console.log("\n\nleft tokens on start: ", await nftContract.getNrOfLeftTokens());
        expect(await nftContract.getNrOfLeftTokens()).to.be.equal(totalSupplyOfNfts); //nothing minted so far
        await expect(nftContract.mint({ value: mintPrice })).to.be.reverted; //this will do all steps of a mint except be successfull, which should trigger the require state
        console.log("\n\nleft tokens after revert: ", await nftContract.getNrOfLeftTokens());

        //check if states remained as before
        expect(await nftContract.getNrOfLeftTokens()).to.be.equal(totalSupplyOfNfts); //reverted, so nothing minted as well
        await expect(nftContract.tokenURI(0)).to.be.reverted;


        //change mint function to return true
        await nftContract.allowMintToBeSuccessfull();

        //mint token
        await nftContract.mint({ value: mintPrice });



        //check states now
        console.log("\n\nleft tokens after mint: ", await nftContract.getNrOfLeftTokens());
        await nftContract.tokenURI(0); //should be fetchable now
        expect(await nftContract.getNrOfLeftTokens()).to.be.equal(totalSupplyOfNfts - 1); //one minted

    });





});