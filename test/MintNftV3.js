const { expect } = require("chai");
const { ethers } = require("hardhat");
//write gen svgs to file
const fs = require('fs');

describe("Mint and accessControl test", function () {

    let apeGenerator;
    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);
    const dataSeperator = ";";

    const filePathForTaxLogging = "./createdData/GasOptimization.txt";

    async function getUsedTaxForLastBlock() {
        const block = await hre.ethers.provider.getBlock();
        console.log("GasUsed", parseInt(block.gasUsed._hex, 16));
        return (parseInt(block.gasUsed._hex, 16));
    }

    function addDataToFile(pathAndFilename, data) {
        fs.appendFile(pathAndFilename, data, err => {
            if (err) {
                console.error(err);
            }
            // file written successfully
        });
    }

    async function getTaxAppendToFile(pathAndFilename, data) {
        const gasData = await getUsedTaxForLastBlock();
        const fileData = data + dataSeperator + gasData;
        addDataToFile(pathAndFilename, fileData);
    }

    function getLastGithubCommit() {
        const rev = fs.readFileSync('.git/HEAD').toString().trim();
        if (rev.indexOf(':') === -1) {
            return rev;
        } else {
            return fs.readFileSync('.git/' + rev.substring(5)).toString().trim();
        }
    }

    //Deploying contract before running tests
    beforeEach(async function () {

        //get available accounts from hardhat
        accounts = await hre.ethers.getSigners();

        //file write headline
        const Headline = "\n\nDate: " + new Date().toLocaleString() + " github commit: " + getLastGithubCommit(); + "\n";
        addDataToFile(filePathForTaxLogging, Headline);


        //deploying contracts - start
        //apeGenerator
        const ApeGenerator = await hre.ethers.getContractFactory("ApeGenerator");
        apeGenerator = await ApeGenerator.deploy();
        await apeGenerator.deployed();

        getTaxAppendToFile(filePathForTaxLogging, "\nApeGenerator deployment");

        console.log("ApeGenerator deployed at: ", apeGenerator.address);


        //deploy contract
        const AccessControl = await hre.ethers.getContractFactory("AccessControl");
        accessControl = await AccessControl.deploy();
        await accessControl.deployed();
        console.log("AccessControl deployed to:", accessControl.address);
        getTaxAppendToFile(filePathForTaxLogging, "\nAccessControl deployment");

        //nft mint contract specific
        const networkName = hre.network.name
        const chainId = hre.network.config.chainId
        console.log("chainId: ", chainId);
        let useSeedWithTestnet;
        if (chainId == "4" || networkName === "rinkeby") {
            //rinkeby
            console.log("seed with testnet used");
            useSeedWithTestnet = true;
        }
        const NftMintContract = await hre.ethers.getContractFactory("OnChainAsciiApes");
        nftContract = await NftMintContract.deploy(true, apeGenerator.address, accessControl.address, mintPrice); //mint price set to 1e15 = 1 finney = 0.001 eth
        await nftContract.deployed();
        console.log("nftMintContract deployed to:", nftContract.address);
        getTaxAppendToFile(filePathForTaxLogging, "\nNftContract deployment");

        //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
        await apeGenerator.transferOwnership(nftContract.address)
        console.log("new owner of apeGenerator is now nftContract");
        getTaxAppendToFile(filePathForTaxLogging, "\nApeGenerator transfer Ownership");

        //deploying contracts - end
        //todo: transfer ownership of apeGenerator, so contract NftMintcontract is now owner

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

    it("DeployAndMint, deploy all needed contracts, mint", async function () {
        await nftContract.enablePublicMint();
        console.log("public mint enabled");
        getTaxAppendToFile(filePathForTaxLogging, "\nNftContract enablePublicMint");

        for (let i = 0; i < 4; i++) {
            await nftContract.mint({ value: mintPrice });

            getTaxAppendToFile(filePathForTaxLogging, "\nNftContract mint");

            queriedTokenUri = await nftContract.tokenURI(i);

            console.log(queriedTokenUri);
        }

    });

});