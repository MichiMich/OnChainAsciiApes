const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpfulScript = require("../scripts/helpful_script.js");
const contractDeployment = require("../scripts/contractDeployment.js");
const dataFormat = require("../scripts/dataFormat.js");
//file logging specific
const filePathAndName = "C:/Projects/BlockChainDev/OnChainAsciiApes_Documentation/statistics/MintOutStatistics.txt";
const dataSeperator = ",";
//statistical data, dynamically updated/extended
let tokenIds = ["tokenids"];
let statisticsOfFaceSymmetry = ["FaceSymmetry"];
let statisticsOfEyeLeft = ["EyeLeft"];
let statisticsOfEyeRight = ["EyeRight"];
let statisticsOfEyeColorLeft = ["EyeColorLeft"];
let statisticsOfEyeColorRight = ["EyeColorRight"];
let statisticsOfApeColor = ["ApeColor"];
let bananascore = ["Bananascore"];


describe("Mint and statistic test", function () {

    let apeGenerator;
    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);
    const apesLeftForDonators = 3;
    let accounts;

    //Deploying contract before running tests
    beforeEach(async function () {
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



    function createStatisticOfTokenURI(tokenURI, tokenId) {
        tokenIds.push(tokenId);
        const attributesOfTokenURI = helpfulScript.getAttributesOftokenURI(tokenURI);
        statisticsOfFaceSymmetry.push(attributesOfTokenURI[0].value);
        statisticsOfEyeLeft.push(attributesOfTokenURI[1].value);
        statisticsOfEyeRight.push(attributesOfTokenURI[2].value);
        statisticsOfEyeColorLeft.push(attributesOfTokenURI[3].value);
        statisticsOfEyeColorRight.push(attributesOfTokenURI[4].value);
        statisticsOfApeColor.push(attributesOfTokenURI[5].value);
        bananascore.push(attributesOfTokenURI[6].value);
    }


    it("MintAndBuildStatistic", async function () {
        let totalSupplyOfNfts = await nftContract.totalSupply();
        totalSupplyOfNfts = parseInt(totalSupplyOfNfts._hex, 16);
        console.log("total supply of nfts: ", totalSupplyOfNfts);
        let queriedTokenUri;
        console.log("total supply: ", totalSupplyOfNfts);
        //lets link accessControl to nftContract, needed for the last3 to be minted by the highest donators
        await accessControl.linkHandshakeContract(nftContract.address);
        console.log("accessControl linked to nftContract");
        await accessControl.addAddressToAccessAllowed(accounts[1].address, 3); //allowed to mint the last 3 ones

        await nftContract.enablePublicMint();
        console.log("public mint enabled");


        let filename;
        let nrOfWantedMints = await helpfulScript.getUserInput("type in wanted nr of mints (-1 = mintout, >0 = nr of mints wanted):")
        if (nrOfWantedMints === "-1") {
            nrOfWantedMints = totalSupplyOfNfts;
        }
        else if (nrOfWantedMints > totalSupplyOfNfts) {
            nrOfWantedMints = totalSupplyOfNfts;
            console.log("given nr bigger than supply, adapted to max supply");
        }

        for (let i = 0; i < nrOfWantedMints; i++) {
            console.log("\n\n");
            console.log("loop counter: ", i);
            console.log("left tokens before mint", await nftContract.getNrOfLeftTokens())

            if (i >= nrOfWantedMints - apesLeftForDonators) {
                //last 3 reserverd for top3 donators, here it would be account1 for test reasons
                await nftContract.connect(accounts[1]).mint(1, { value: mintPrice });
            }
            else {
                await nftContract.mint(1, { value: mintPrice });
            }

            console.log("left tokens after mint", await nftContract.getNrOfLeftTokens())


            queriedTokenUri = await nftContract.tokenURI(i);

            createStatisticOfTokenURI(queriedTokenUri, i);

            let apeName = helpfulScript.getNameOfApeByTokenURI(queriedTokenUri);

            filename = 'C:/Projects/BlockChainDev/OnChainAsciiApes_Documentation/GenApes/ApesWithName/' + i + '.svg';

            helpfulScript.createAndAdaptSvgFromTokenURI(queriedTokenUri, filename, apeName);

        };

        console.log("\n\n Mint done, left tokens: ", await nftContract.getNrOfLeftTokens());

        if (nrOfWantedMints == totalSupplyOfNfts) {
            await expect(nftContract.mint(1, { value: mintPrice })).to.be.reverted;
        }

        helpfulScript.addDataToFile(filePathAndName, dataFormat.arrayToCsvString([tokenIds,
            statisticsOfFaceSymmetry,
            statisticsOfEyeLeft,
            statisticsOfEyeRight,
            statisticsOfEyeColorLeft,
            statisticsOfEyeColorRight,
            statisticsOfApeColor,
            bananascore], dataSeperator));

    });

    /*
        //get some statistical data
        function getStatisticalData() {
    
            //eye colors: 
            eyeColor = ['#ff1414', '#ffd700', '#ff33cc']
            for (let i = 0; i < eyeColor.length; i++) {
                helpfulScript.addDataToFile(filePathAndName, "eyecolor: " + eyeColor[i] + " nr of occurences left:" + countInArray(statisticsOfEyeColorLeft, eyeColor[i]));
            }
            for (let i = 0; i < eyeColor.length; i++) {
                helpfulScript.addDataToFile(filePathAndName, "eyecolor: " + eyeColor[i] + " nr of occurences right:" + countInArray(statisticsOfEyeColorRight, eyeColor[i]));
            }
    
    
        }
    
        function countInArray(array, what) {
            return array.filter(item => item == what).length;
        }
    
            function countInArray(array, what) {
                console.log("search for: ", what);
                var count = 0;
                for (var i = 0; i < array.length; i++) {
                    if (array[i] === what) {
                        count++;
                        console.log("found at index: ", i);
                        leftEyeMultiplesIndices.push(i);
        
                    }
                }
                console.log("nr of found items: ", count);
                return count;
            }
            */

});

