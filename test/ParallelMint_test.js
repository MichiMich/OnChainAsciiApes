const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpfulScript = require("../scripts/helpful_script.js");
const contractDeployment = require("../scripts/contractDeployment.js");
//file logging specific
const filePathAndName = "C:/Projects/BlockChainDev/OnChainAsciiApes_Documentation/statistics/MintOutStatistics.txt";
const dataSeperator = ";";

describe("Mint and accessControl test", function () {

    let apeGenerator;
    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);


    //Deploying contract before running tests
    beforeEach(async function () {

        [apeGenerator, accessControl, nftContract] = await contractDeployment.deployMintContractsWithAccessControl(mintPrice);

        //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
        await apeGenerator.transferOwnership(nftContract.address)
        console.log("new owner of apeGenerator is now nftContract");


        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        accounts = await hre.ethers.getSigners();
    })


    async function mint(_nrOfMints, _account) {
        for (let i = 0; i < _nrOfMints; i++) {
            await nftContract.connect(_account).mint({ value: mintPrice });
            console.log("left tokens after mint", await nftContract.getNrOfLeftTokens())
        }
        console.log("balance of ", _account.address, "\n", await nftContract.balanceOf(_account.address));
    }

    async function mintAllUsers(_nrOfMints) {
        console.log("\n\nNumber of accounts: ", accounts.length);
        for (let i = 0; i < _nrOfMints; i++) {
            for (let j = 0; j < accounts.length; j++) {
                await mint(1, accounts[j]);
            }
        }
    }

    it("Mint, parallel async call", async function () {

        //this can be seen as a sequence call, so nothing done in parallel
        //Promise.all(await mint(4, accounts[1]), await mint(3, accounts[2]));
        await mintAllUsers(2);

    });






});