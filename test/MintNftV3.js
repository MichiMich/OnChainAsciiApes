const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Mint and accessControl test", function () {

    let apeGenerator;
    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);
    const dataSeperator = ";";

    const filePathForTaxLogging = "./createdData/GasOptimization.txt";


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
        console.log("AccessControl deployed at:", accessControl.address);


        //nft mint contract specific
        const networkName = hre.network.name
        const chainId = hre.network.config.chainId
        console.log("chainId: ", chainId, "network name: ", networkName);

        const NftMintContract = await hre.ethers.getContractFactory("OnChainAsciiApes");
        nftContract = await NftMintContract.deploy(apeGenerator.address, accessControl.address, mintPrice); //mint price set to 1e15 = 1 finney = 0.001 eth
        await nftContract.deployed();
        console.log("nftMintContract deployed at:", nftContract.address);


        //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
        await apeGenerator.transferOwnership(nftContract.address)
        console.log("new owner of apeGenerator is now nftContract");

        //deploying contracts - end

    })


    function createAndAdaptSvgFromTokenURI(tokenURI, pathAndFilename, apeName) {
        const jsonData = tokenURI_to_JSON(tokenURI);
        const imageDataBase64 = jsonData.image;
        const svgData = imageDataBase64.substring(26);
        const decodedSvgData = atob(svgData);

        const SvgDataPart1 = decodedSvgData.substring(0, decodedSvgData.indexOf("</text>"));
        const AddedSvgNamePart = '<tspan x="0%" y="92%">' + apeName + '</tspan>';
        const SvgWithName = SvgDataPart1 + AddedSvgNamePart + '</text></svg>'

        //write svg to file
        fs.writeFile(pathAndFilename, SvgWithName, err => {
            if (err) {
                console.error(err);
            }
            // file written successfully
        });

    }


    function tokenURI_to_JSON(tokenURI) {
        const json = atob(tokenURI.substring(29));
        return (JSON.parse(json));
    }

    function seperateMetadata(tokenURI) {
        return (tokenURI_to_JSON(tokenURI));
    }

    function getAttributesOftokenURI(tokenURI) {
        const attributesOfTokenURI = seperateMetadata(tokenURI).attributes;
        //console.log(attributesOfTokenURI);
        return (attributesOfTokenURI);
    }

    function getNameOfTokenURI(tokenURI) {
        const nameOfTokenURI = seperateMetadata(tokenURI).name;
        console.log(nameOfTokenURI);
    }



    function createStatisticOfTokenURI(tokenURI) {

        const FaceSymmetry = getAttributesOftokenURI(tokenURI)[0].value;
        const eyeLeft = getAttributesOftokenURI(tokenURI)[1].value;
        const eyeRight = getAttributesOftokenURI(tokenURI)[2].value;
        const EyeColorLeft = getAttributesOftokenURI(tokenURI)[3].value;
        const EyeColorRight = getAttributesOftokenURI(tokenURI)[4].value;
        const ApeColor = getAttributesOftokenURI(tokenURI)[5].value;

        statisticsOfFaceSymmetry.push(FaceSymmetry);
        statisticsOfEyeLeft.push(eyeLeft);
        statisticsOfEyeRight.push(eyeRight);
        statisticsOfEyeColorLeft.push(EyeColorLeft);
        statisticsOfEyeColorRight.push(EyeColorRight);
        statisticsOfApeColor.push(ApeColor);


        /*
        console.log("FaceSymmetry: ", FaceSymmetry);
        console.log("eyeLeft: ", eyeLeft);
        console.log("eyeRight: ", eyeRight);
        console.log("EyeColorLeft: ", EyeColorLeft);
        console.log("EyeColorRight: ", EyeColorRight);
        console.log("ApeColor: ", ApeColor);
        */

    }


    let statisticsOfFaceSymmetry = [];
    let statisticsOfEyeLeft = [];
    let statisticsOfEyeRight = [];
    let statisticsOfEyeColorLeft = [];
    let statisticsOfEyeColorRight = [];
    let statisticsOfApeColor = [];

    it("MintAndSeperateMetadata, deploy all needed contracts, mint, seperate metadata", async function () {
        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        for (let i = 0; i < 10; i++) {
            await nftContract.mint({ value: mintPrice });

            queriedTokenUri = await nftContract.tokenURI(i);
            // getNameOfTokenURI(queriedTokenUri);
            // getAttributesOftokenURI(queriedTokenUri);
            createStatisticOfTokenURI(queriedTokenUri);
        }


        console.log(statisticsOfFaceSymmetry);
        console.log(statisticsOfEyeLeft);
        console.log(statisticsOfEyeRight);
        console.log(statisticsOfEyeColorLeft);
        console.log(statisticsOfEyeColorRight);
        console.log(statisticsOfApeColor);

    });

});