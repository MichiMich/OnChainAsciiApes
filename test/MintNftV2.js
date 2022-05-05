const { expect } = require("chai");
const { ethers } = require("hardhat");
//write gen svgs to file
const fs = require('fs');

describe("Mint and accessControl test", function () {

    let apeGenerator;
    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);

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
        console.log("AccessControl deployed to:", accessControl.address);


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
        nftContract = await NftMintContract.deploy(useSeedWithTestnet, apeGenerator.address, accessControl.address, mintPrice); //mint price set to 1e15 = 1 finney = 0.001 eth
        await nftContract.deployed();
        console.log("nftMintContract deployed to:", nftContract.address);

        //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
        await apeGenerator.transferOwnership(nftContract.address)
        console.log("new owner of apeGenerator is now nftContract");

        //deploying contracts - end
        //todo: transfer ownership of apeGenerator, so contract NftMintcontract is now owner

    })


    it("MintV2, try minting ape", async function () {
        const totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply of nfts: ", totalSupplyOfNfts);
        let queriedTokenUri;
        console.log("total supply: ", totalSupplyOfNfts);


        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        /*
        await nftContract.mint({ value: mintPrice });

        let apeName = await nftContract.getNameOfApe(1);

        console.log("apeName: ", apeName);

        queriedTokenUri = await nftContract.tokenURI(1);

        let ownerOf = await nftContract.ownerOf(1);
        console.log("ownerOf: ", ownerOf);


        console.log("queried tokenURI: ", queriedTokenUri);
*/



        function createSvgFromTokenURI(tokenURI, pathAndFilename) {
            const jsonData = tokenURI_to_JSON(tokenURI);
            const imageDataBase64 = jsonData.image;
            const svgData = imageDataBase64.substring(26);
            const decodedSvgData = atob(svgData);
            //console.log("decoded svg: \n\n", decodedSvgData);

            //write svg to file
            fs.writeFile(pathAndFilename, decodedSvgData, err => {
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


        let filename;
        for (let i = 1; i <= totalSupplyOfNfts; i++) {
            await nftContract.mint({ value: mintPrice });

            let apeName = await nftContract.getNameOfApe(i);

            console.log("\n\napeName: ", apeName);

            queriedTokenUri = await nftContract.tokenURI(i);

            //console.log("\n\nfetched token: ", queriedTokenUri);

            filename = './GenApes/' + apeName + '.svg';
            createSvgFromTokenURI(queriedTokenUri, filename);

        };





    });





});