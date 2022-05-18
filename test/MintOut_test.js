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



    function createStatisticOfTokenURI(tokenURI) {
        const attributesOfTokenURI = helpfulScript.getAttributesOftokenURI(tokenURI);
        statisticsOfFaceSymmetry.push(attributesOfTokenURI[0].value);
        statisticsOfEyeLeft.push(attributesOfTokenURI[1].value);
        statisticsOfEyeRight.push(attributesOfTokenURI[2].value);
        statisticsOfEyeColorLeft.push(attributesOfTokenURI[3].value);
        statisticsOfEyeColorRight.push(attributesOfTokenURI[4].value);
        statisticsOfApeColor.push(attributesOfTokenURI[5].value);
    }

    //statistical data
    let statisticsOfFaceSymmetry = [];
    let statisticsOfEyeLeft = [];
    let statisticsOfEyeRight = [];
    let statisticsOfEyeColorLeft = [];
    let statisticsOfEyeColorRight = [];
    let statisticsOfApeColor = [];


    it("Mintout", async function () {
        const totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply of nfts: ", totalSupplyOfNfts);
        let queriedTokenUri;
        console.log("total supply: ", totalSupplyOfNfts);


        await nftContract.enablePublicMint();
        console.log("public mint enabled");


        let filename;
        for (let i = 0; i < totalSupplyOfNfts; i++) {
            console.log("\n\n");
            console.log("loop counter: ", i);
            console.log("left tokens before mint", await nftContract.getNrOfLeftTokens())

            await nftContract.mint({ value: mintPrice });

            console.log("left tokens after mint", await nftContract.getNrOfLeftTokens())


            queriedTokenUri = await nftContract.tokenURI(i);

            createStatisticOfTokenURI(queriedTokenUri);

            let apeName = helpfulScript.getNameOfApeByTokenURI(queriedTokenUri);

            //console.log("\n\nfetched token: ", queriedTokenUri);

            //filename = 'C:/Projects/BlockChainDev/OnChainAsciiApes_Documentation/GenApes' + apeName + '.svg';

            filename = 'C:/Projects/BlockChainDev/OnChainAsciiApes_Documentation/GenApes/ApesWithName/' + apeName + '.svg';

            //createSvgFromTokenURI(queriedTokenUri, filename);
            helpfulScript.createAndAdaptSvgFromTokenURI(queriedTokenUri, filename, apeName);

        };

        console.log("\n\n Mint done, left tokens: ", await nftContract.getNrOfLeftTokens());



        const totalStatisticData = JSON.stringify(statisticsOfFaceSymmetry) + dataSeperator + JSON.stringify(statisticsOfEyeLeft) + dataSeperator + JSON.stringify(statisticsOfEyeRight) + dataSeperator + JSON.stringify(statisticsOfEyeColorLeft) + dataSeperator + JSON.stringify(statisticsOfEyeColorRight) + dataSeperator + JSON.stringify(statisticsOfApeColor);

        helpfulScript.addDataToFile(filePathAndName, totalStatisticData, err => {
            if (err) {
                console.error(err);
            }
            // file written successfully
        });

        console.log(statisticsOfFaceSymmetry);
        console.log(statisticsOfEyeLeft);
        console.log(statisticsOfEyeRight);
        console.log(statisticsOfEyeColorLeft);
        console.log(statisticsOfEyeColorRight);
        console.log(statisticsOfApeColor);
    });


});