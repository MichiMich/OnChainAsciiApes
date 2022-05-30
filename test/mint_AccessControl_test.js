const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpfulScript = require("../scripts/helpful_script.js");

const fs = require('fs');
//file logging specific
const filePathForTaxLogging = "./createdData/GasOptimization.txt";
const dataSeperator = ";";

const apesLeftForDonators = 3;

describe("Mint and accessControl test", function () {
    let apeGenerator;
    let accessControl;
    let nftContract;
    let totalSupply;
    const mintPrice = ethers.utils.parseUnits("1", 15);

    async function getTaxAppendToFile(pathAndFilename, data) {
        const gasData = await helpfulScript.getUsedTaxForLastBlock();
        const fileData = data + dataSeperator + gasData;
        helpfulScript.addDataToFile(pathAndFilename, fileData);
    }

    //Deploying contract before running tests
    beforeEach(async function () {
        //get available accounts from hardhat
        accounts = await hre.ethers.getSigners();

        let codeChangeDescription = await helpfulScript.getUserInput("Please add a description of the code change");
        let gasOptHeadline = "";
        //file write headline
        if (codeChangeDescription === "") {
            //none given
            gasOptHeadline = "\n\nDate: " + new Date().toLocaleString() + " github commit: " + helpfulScript.getLastGithubCommit(); + "\n";
        }
        else {
            gasOptHeadline = "\n\nDate: " + new Date().toLocaleString() + " github commit: " + helpfulScript.getLastGithubCommit() + dataSeperator + codeChangeDescription + "\n";
        }

        helpfulScript.addDataToFile(filePathForTaxLogging, gasOptHeadline);

        //deploying contracts - start
        //apeGenerator
        const ApeGenerator = await hre.ethers.getContractFactory("ApeGenerator");
        apeGenerator = await ApeGenerator.deploy();
        await apeGenerator.deployed();

        console.log("ApeGenerator deployed at: ", apeGenerator.address);
        getTaxAppendToFile(filePathForTaxLogging, "\nApeGenerator deployment");

        //deploy contract
        const AccessControl = await hre.ethers.getContractFactory("AccessUnitControl");
        accessControl = await AccessControl.deploy();
        await accessControl.deployed();
        console.log("AccessControl deployed at:", accessControl.address);
        getTaxAppendToFile(filePathForTaxLogging, "\nAccessControl deployment");

        //nft mint contract specific
        const networkName = hre.network.name
        const chainId = hre.network.config.chainId
        console.log("chainId: ", chainId, "network name: ", networkName);

        const NftMintContract = await hre.ethers.getContractFactory("OnChainAsciiApes");
        nftContract = await NftMintContract.deploy(apeGenerator.address, accessControl.address, mintPrice); //mint price set to 1e15 = 1 finney = 0.001 eth
        await nftContract.deployed();
        console.log("nftMintContract deployed at:", nftContract.address);
        getTaxAppendToFile(filePathForTaxLogging, "\nNftContract deployment");

        //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
        await apeGenerator.transferOwnership(nftContract.address)
        console.log("new owner of apeGenerator is now nftContract");
        getTaxAppendToFile(filePathForTaxLogging, "\nApeGenerator transfer Ownership");

        //deploying contracts - end
        totalSupply = await nftContract.totalSupply();
        console.log("totalSupply: ", totalSupply);

        //link handshake contract
        await accessControl.linkHandshakeContract(nftContract.address);

    })



    it("mint and accessControl, mint first apes, require access then", async function () {
        await nftContract.enablePublicMint();
        console.log("public mint enabled");
        getTaxAppendToFile(filePathForTaxLogging, "\nNftContract enablePublicMint");
        let wantedTokenId;
        let i = 0;
        for (i = 0; i < totalSupply - apesLeftForDonators; i++) {
            //anyone is able to mint first apes
            await nftContract.connect(accounts[1]).mint(1, { value: mintPrice });

            getTaxAppendToFile(filePathForTaxLogging, "\nNftContract mint");



            console.log("nr of left tokens: ", await nftContract.getNrOfLeftTokens())
            // queriedTokenUri = await nftContract.tokenURI(i);
            //console.log("tokenURI: ", queriedTokenUri);
        }
        console.log("\n\n minted elements: ", i)


        //now only certain addresses are allowed to mint the last existing apes
        await expect(nftContract.mint(1, { value: mintPrice })).to.be.reverted;

        console.log("\n\nnr of left tokens where allowed addresses where set: ", await nftContract.getNrOfLeftTokens());
        //add the allowed addresses to the AccessUnitControl, this should be the addresses of the highest donators
        await accessControl.addAddressToAccessAllowed(accounts[2].address, 1);
        await accessControl.addAddressToAccessAllowed(accounts[3].address, 1);
        await accessControl.addAddressToAccessAllowed(accounts[4].address, 1);

        //no one except 2,3,4 are allowed, not even the owner
        await expect(nftContract.mint(1, { value: mintPrice })).to.be.reverted;
        await expect(nftContract.connect(accounts[1]).mint(1, { value: mintPrice })).to.be.reverted;

        //get tokenId of last minted one
        await nftContract.connect(accounts[2]).mint(1, { value: mintPrice }); //allowed

        wantedTokenId = i;
        console.log("\n\nleft tokens: ", await nftContract.getNrOfLeftTokens(), "query token of ", wantedTokenId);
        queriedTokenUri = await nftContract.tokenURI(wantedTokenId);
        console.log("tokenURI of id: ", wantedTokenId, queriedTokenUri);

        await expect(nftContract.connect(accounts[2]).mint(1, { value: mintPrice })).to.be.reverted; //only 1 nft was allowed

        await nftContract.connect(accounts[3]).mint(1, { value: mintPrice }); //allowed
        wantedTokenId += 1;
        console.log("\n\nleft tokens: ", await nftContract.getNrOfLeftTokens(), "query token of ", wantedTokenId);
        queriedTokenUri = await nftContract.tokenURI(wantedTokenId);
        console.log("tokenURI of id: ", wantedTokenId, queriedTokenUri);


        await expect(nftContract.connect(accounts[3]).mint(1, { value: mintPrice })).to.be.reverted; //only 1 nft was allowed

        await nftContract.connect(accounts[4]).mint(1, { value: mintPrice }); //allowed
        wantedTokenId += 1;
        console.log("\n\nleft tokens: ", await nftContract.getNrOfLeftTokens(), "query token of ", wantedTokenId);
        queriedTokenUri = await nftContract.tokenURI(wantedTokenId);
        console.log("tokenURI of id: ", wantedTokenId, queriedTokenUri);

        await expect(nftContract.connect(accounts[4]).mint(1, { value: mintPrice })).to.be.reverted; //only 1 nft was allowed


        console.log("\n\nnr of left tokens where", (totalSupply - await nftContract.getNrOfLeftTokens()), " have been minted: ", await nftContract.getNrOfLeftTokens());
        //minted out if apesLeftForDonators=3
        if (apesLeftForDonators == 3) {
            //Check if we get statement minted out back
            await expect(nftContract.mint(1, { value: mintPrice })).to.be.revertedWith("minted out, check secondary market");
        }
        else {
            await expect(nftContract.mint(1, { value: mintPrice })).to.be.reverted;
        }




    });

});