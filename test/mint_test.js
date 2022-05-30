const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpfulScript = require("../scripts/helpful_script.js");


const fs = require('fs');
const { exec } = require("child_process");
//file logging specific
const filePathForTaxLogging = "./createdData/GasOptimization.txt";
const dataSeperator = ";";

const apesLeftForDonators = 3; //todo: set to 3 if works

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



    it("try multiple mints per mint call", async function () {
        await nftContract.enablePublicMint();
        console.log("public mint enabled");
        getTaxAppendToFile(filePathForTaxLogging, "\nNftContract enablePublicMint");
        let wantedTokenId;
        let i = 0;
        let maxNrOfAllowedMints = 8;
        let nrOfWantedMints = 3;


        //trying to mint multiple apes
        if (nrOfWantedMints > 1) {
            await expect(nftContract.connect(accounts[1]).mint(nrOfWantedMints, { value: mintPrice })).to.be.reverted; //too less eth for too much wanted mints
        }
        if (nrOfWantedMints > maxNrOfAllowedMints) {
            await expect(nftContract.connect(accounts[1]).mint(nrOfWantedMints, { value: nrOfWantedMints * mintPrice })).to.be.reverted; //too less eth for too much wanted mints
        }
        else {
            await nftContract.connect(accounts[1]).mint(nrOfWantedMints, { value: nrOfWantedMints * mintPrice });

            for (i = 0; i < nrOfWantedMints; i++) {
                queriedTokenUri = await nftContract.tokenURI(i);
                console.log("queriedTokenUri: ", queriedTokenUri, "\n\n");
            }
        }


        console.log("nr of nfts of ", accounts[1].address, ": ", await nftContract.balanceOf(accounts[1].address));

        console.log("eth balance of contract: ", await nftContract.getBalance());


    });


    it("test mint, accessControl active", async function () {

        getTaxAppendToFile(filePathForTaxLogging, "\nNftContract enablePublicMint");
        let wantedTokenId;
        let i = 0;
        let maxNrOfAllowedMints = 8;
        let nrOfWantedMints = 3;

        await accessControl.linkHandshakeContract(nftContract.address);
        await accessControl.addAddressToAccessAllowed(accounts[1].address, nrOfWantedMints);
        console.log(accounts[1].address, "for ", nrOfWantedMints, " nfts allowed to mint");

        //trying to mint multiple apes
        if (nrOfWantedMints > 1) {
            await expect(nftContract.connect(accounts[1]).mint(nrOfWantedMints, { value: mintPrice })).to.be.reverted; //too less eth for too much wanted mints
        }
        if (nrOfWantedMints > maxNrOfAllowedMints) {
            await expect(nftContract.connect(accounts[1]).mint(nrOfWantedMints, { value: nrOfWantedMints * mintPrice })).to.be.reverted; //too less eth for too much wanted mints
        }
        else {
            await nftContract.connect(accounts[1]).mint(nrOfWantedMints, { value: nrOfWantedMints * mintPrice });

            for (i = 0; i < nrOfWantedMints; i++) {
                queriedTokenUri = await nftContract.tokenURI(i);
                console.log("queriedTokenUri: ", queriedTokenUri, "\n\n");
            }
        }


        console.log("nr of nfts of ", accounts[1].address, ": ", await nftContract.balanceOf(accounts[1].address));

        console.log("eth balance of contract: ", await nftContract.getBalance());


    });




});