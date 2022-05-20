const { expect } = require("chai");
const { ethers } = require("hardhat");

const helpfulScript = require("../scripts/helpful_script.js");
const fs = require('fs');

describe("ApeGenerator test", function () {
    let apeGenerator;
    const nrOfSpecialApes = 7;
    const eyeIndexLimit = 13; //number of eyes see apeEyes array OnChainAsciiApe.sol
    const nrOfApeNames = 7;
    const tokenIdLimit = eyeIndexLimit * eyeIndexLimit + nrOfSpecialApes;

    beforeEach(async function () {
        //get available accounts from hardhat
        accounts = await hre.ethers.getSigners();

        //deploying contracts - start
        //apeGenerator
        const ApeGenerator = await hre.ethers.getContractFactory("ApeGenerator");
        apeGenerator = await ApeGenerator.deploy();
        await apeGenerator.deployed();
        console.log("ApeGenerator deployed at: ", apeGenerator.address);

    });


    it("ApeGenerator, getApeName", async function () {
        const genApeName = await apeGenerator.generateApeName(0, 0, 0, 0); //uint256 _apeNameIndex,uint256 _leftEyeIndex,uint256 _rightEyeIndex,uint256 _tokenId
        console.log("genApeName: ", genApeName);
        //we want some string getting back
        expect(genApeName).to.not.equal("");
    });


    it("ApeGeneratorGenApeSpecial ape, getGenApe", async function () {
        const usedTokenID = 0;
        const specialApeIndex = await apeGenerator.getSpecialApeIndex(usedTokenID); //0 is a special ape
        const randomBananaScore = 60 + Math.floor(Math.random() * 40);
        const genApe = await apeGenerator.generateAndRegisterApe(
            specialApeIndex,
            0,
            0,
            0,
            usedTokenID,
            0,
            randomBananaScore //banana score
        );
        console.log("genApe: ", genApe);
        //true return means contract function call was successful
        //expect(genApe).to.be.true;

        const tokenURI = await apeGenerator.getTokenURI(usedTokenID);
        const apeName = helpfulScript.getNameOfTokenURI(tokenURI);

        const pathAndFilename = './GenApes/' + apeName + '.svg';
        expect(tokenURI).to.not.equal("");

        //create svg of file and save it to
        helpfulScript.createAndAdaptSvgFromTokenURI(tokenURI, pathAndFilename, apeName);

    });

    function numberInRange(_range) {
        return Math.floor(Math.random() * _range);
    };

    it("ApeGeneratorGenApeStandard ape, getGenApe", async function () {

        //Bingo the half dollar half btc eyec ape #1: dollar = index 13, btc = index 7->mint combination 176?
        /*
        generateAndRegisterApe(
            0,
            189,
            eyecolorleft,
            eyecolorright,
            1,
            3, //bingo
        )
        */

        const usedTokenID = 1;
        const randomBananaScore = 60 + Math.floor(Math.random() * 40);
        const randomCreatedMintCombinationIndex = numberInRange(await apeGenerator.nrOfAvailableMintCombinations());

        //log values to be able to track if sth goes wrong
        const eyecolorleft = numberInRange(3);
        const eyecolorright = numberInRange(3);
        const apeNameIndex = numberInRange(13);
        console.log("\nUsedValuesForGeneration: \n", "eyecolorleft: ", eyecolorleft, "\neyecolorright: ", eyecolorright, "\napeNameIndex: ", apeNameIndex, "\nrandomBananaScore: ", randomBananaScore, "\nrandomCreatedMintCombinationIndex: ", randomCreatedMintCombinationIndex);

        const genApe = await apeGenerator.generateAndRegisterApe(
            0,
            randomCreatedMintCombinationIndex, //mint combination number
            eyecolorleft, //eyecolor left
            eyecolorright, //eyecolor right
            usedTokenID,
            apeNameIndex, //apeNameIndex
            randomBananaScore //bananascore
        );


        console.log("genApe: ", genApe);
        //true return means contract function call was successful
        //expect(genApe).to.be.true;

        const tokenURI = await apeGenerator.getTokenURI(usedTokenID);
        const apeName = helpfulScript.getNameOfTokenURI(tokenURI);

        const pathAndFilename = './GenApes/' + apeName + '.svg';
        expect(tokenURI).to.not.equal("");

        //create svg of file and save it to
        helpfulScript.createAndAdaptSvgFromTokenURI(tokenURI, pathAndFilename, apeName);

    });



});