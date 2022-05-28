const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpfulScript = require("../scripts/helpful_script.js");

const fs = require('fs');
//file logging specific
const filePathForTaxLogging = "./createdData/GasOptimization.txt";
const dataSeperator = ";";

describe("Mint and accessControl test", function () {
    let apeGenerator;
    let accessControl;
    let nftContract;
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

    })



    it("DeployAndMint, deploy all needed contracts, mint", async function () {
        await nftContract.enablePublicMint();
        console.log("public mint enabled");
        getTaxAppendToFile(filePathForTaxLogging, "\nNftContract enablePublicMint");

        for (let i = 0; i < 2; i++) {
            await nftContract.mint({ value: mintPrice });

            getTaxAppendToFile(filePathForTaxLogging, "\nNftContract mint");

            queriedTokenUri = await nftContract.tokenURI(i);

            console.log("tokenURI: ", queriedTokenUri);
        }

    });

});