const { expect } = require("chai");
const { ethers } = require("hardhat");

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
        const genApe = await apeGenerator.getGeneratedApe("&#x60;", "&#xB4;", true, "#ff230a", 1, 1);  //lefteye, righteye, special ape generation, textfillcolor, eyecolorleft, eyecolorright
        //console.log("genApe: ", genApe);
        //we want some string getting back
        expect(genApe).to.not.equal("");
        //write data to file
        fs.writeFile('./GenApes/genape.svg', genApe, err => {
            if (err) {
                console.error(err);
            }
            // file written successfully
        });
    });

    it("ApeGeneratorGenApeStandard ape, getGenApe", async function () {
        const genApe = await apeGenerator.getGeneratedApe("&#x3C;", "&#x3E;", false, "", 0, 0);  //lefteye, righteye, special ape generation, textfillcolor, eyecolorleft, eyecolorright
        //console.log("genApe: ", genApe);
        //we want some string getting back
        expect(genApe).to.not.equal("");
        //write data to file
        fs.writeFile('./GenApes/genape.svg', genApe, err => {
            if (err) {
                console.error(err);
            }
            // file written successfully
        });
    });

    it("ApeGenerator, check specific ape names", async function () {
        let randomApeNameIndex = Math.floor(Math.random() * nrOfApeNames);
        let randomeApeId = Math.floor(Math.random() * tokenIdLimit);
        let randomApeLeftEyeIndex = Math.floor(Math.random() * eyeIndexLimit);
        let randomApeRightEyeIndex = Math.floor(Math.random() * eyeIndexLimit);

        const genApeName = await apeGenerator.generateApeName(6, randomApeLeftEyeIndex, randomApeRightEyeIndex, randomeApeId); //uint256 _apeNameIndex currently in range to 4,uint256 _leftEyeIndex,uint256 _rightEyeIndex,uint256 _tokenId
        console.log("genApeName: ", genApeName);
    });


    it("ApeGenerator, check random ape names", async function () {
        const nrOfRandomGenerations = 20;
        for (let i = 0; i < nrOfRandomGenerations; i++) {
            let randomApeNameIndex = Math.floor(Math.random() * nrOfApeNames);
            let randomApeLeftEyeIndex = Math.floor(Math.random() * eyeIndexLimit);
            let randomApeRightEyeIndex = Math.floor(Math.random() * eyeIndexLimit);
            let randomeApeId = Math.floor(Math.random() * tokenIdLimit);
            //console.log("randomApeNameIndex: ", randomApeNameIndex);

            const genApe = await apeGenerator.getGeneratedApe("&#x2665;", "&#xac;", false, "", 1, 2);  //lefteye, righteye, special ape generation, textfillcolor, eyecolorleft, eyecolorright
            //console.log("genApe: ", genApe);
            const genApeName = await apeGenerator.generateApeName(randomApeNameIndex, randomApeLeftEyeIndex, randomApeRightEyeIndex, randomeApeId); //uint256 _apeNameIndex currently in range to 4,uint256 _leftEyeIndex,uint256 _rightEyeIndex,uint256 _tokenId
            console.log("genApeName: ", genApeName);
            //we want some string getting back
            expect(genApe).to.not.equal("");

            //identical eyes need to lead to a full argument in the name
            if (randomApeLeftEyeIndex == randomApeRightEyeIndex) {
                expect(JSON.stringify(genApeName).search("full")).to.not.equal(-1);
            }


        }
        /*
        fs.writeFile('./GenApes/genape.svg', genApe, err => {
            if (err) {
                console.error(err);
            }
            // file written successfully
        });*/

    });




});