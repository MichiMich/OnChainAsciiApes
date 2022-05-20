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
    let accounts;

    //Deploying contract before running tests
    beforeEach(async function () {
        //get available accounts from hardhat
        accounts = await hre.ethers.getSigners();
        let codeChangeDescription = await helpfulScript.getUserInput("Please add a description of the code change");
        let fileHeadLine = "";
        //file write headline
        if (codeChangeDescription === "") {
            //none given
            fileHeadLine = "\n\nDate: " + new Date().toLocaleString() + " github commit: " + helpfulScript.getLastGithubCommit(); + "\n";
        }
        else {
            fileHeadLine = "\n\nDate: " + new Date().toLocaleString() + " github commit: " + helpfulScript.getLastGithubCommit() + dataSeperator + codeChangeDescription + "\n";
        }

        helpfulScript.addDataToFile(filePathAndName, fileHeadLine);


        [apeGenerator, accessControl, nftContract] = await contractDeployment.deployMintContractsWithAccessControl(mintPrice);

        //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
        await apeGenerator.transferOwnership(nftContract.address)
        console.log("new owner of apeGenerator is now nftContract");
    })



    it("Mint and withdraw", async function () {
        let contractBalance;
        let accountBalanceBeforeWithdraw;
        let accountBalanceStart;
        let nrOfDoneMints;

        accountBalanceStart = await accounts[0].getBalance();
        console.log("account1 balance start", accountBalanceStart);

        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        for (let i = 0; i < 2; i++) {
            console.log("\n\n");
            console.log("loop counter: ", i);
            console.log("left tokens before mint", await nftContract.getNrOfLeftTokens())

            await nftContract.mint({ value: mintPrice });

            contractBalance = await nftContract.getBalance();
            console.log("\nCurrent contract balance: ", contractBalance);
            nrOfDoneMints = i + 1;
        };


        accountBalanceBeforeWithdraw = await accounts[0].getBalance();
        console.log("account1 balance before withdraw: ", accountBalanceBeforeWithdraw);



        //transfer all contract balance
        await nftContract.withdraw({ value: contractBalance }); //withdraw full amount to caller, which will only succeed if caller is owner

        const usedTaxForTransfer = await helpfulScript.getUsedTaxForLastBlock();
        console.log("used tax for transfer: ", usedTaxForTransfer);


        //check if money was transferred
        console.log("sent value: ", await helpfulScript.getSentValueOfLastBlock());

        expect(await helpfulScript.getSentValueOfLastBlock()).to.be.equal(nrOfDoneMints * mintPrice);

        expect(await accounts[0].getBalance()).to.be.equal(accountBalanceBeforeWithdraw + contractBalance + usedTaxForTransfer); //need to subtract the gas fees



        contractBalance = await nftContract.getBalance();
        console.log("\nCurrent contract balance after withdraw: ", contractBalance);


    });

});