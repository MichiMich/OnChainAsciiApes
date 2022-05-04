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


        function utf8_to_b64(str) {
            return btoa(unescape(encodeURIComponent(str)));
        }

        function b64_to_utf8(str) {
            return decodeURIComponent(escape(atob(str)));
        }

        function tokenURI_to_JSON(tokenURI) {
            const json = atob(tokenURI.substring(29));
            return (JSON.parse(json));
        }


        let tmp;
        let base64DecodedData;

        let dataoutput = "eyJkZXNjcmlwdGlvbiI6IkZ1bGx5IG9uY2hhaW4gZ2VuZXJhdGVkIEFzY2lpQXBlIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlOVEF3SWlCb1pXbG5hSFE5SWpVd01DSWdlRzFzYm5NOUltaDBkSEE2THk5M2QzY3Vkek11YjNKbkx6SXdNREF2YzNabklqNDhjbVZqZENCb1pXbG5hSFE5SWpVd01DSWdkMmxrZEdnOUlqVXdNQ0lnWm1sc2JEMGlZbXhoWTJzaUx6NDhkR1Y0ZENCNVBTSXhNQ1VpSUdacGJHdzlJbmRvYVhSbElpQjBaWGgwTFdGdVkyaHZjajBpYzNSaGNuUWlJR1p2Ym5RdGMybDZaVDBpTVRnaUlIaHRiRHB6Y0dGalpUMGljSEpsYzJWeWRtVWlJR1p2Ym5RdFptRnRhV3g1UFNKdGIyNXZjM0JoWTJVaVBqeDBjM0JoYmlCNFBTSTBNeTQzTlNVaUlHUjVQU0l4TGpKbGJTSStKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVHUTdQQzkwYzNCaGJqNDhkSE53WVc0Z2VEMGlNemt1TnpVbElpQmtlVDBpTVM0eVpXMGlQaVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2hrT3p3dmRITndZVzQrUEhSemNHRnVJSGc5SWpNMUxqYzFKU0lnWkhrOUlqRXVNbVZ0SWo0bUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZUdRN1BDOTBjM0JoYmo0OGRITndZVzRnZUQwaU16RXVOelVsSWlCa2VUMGlNUzR5WlcwaVBpWWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2hrT3p3dmRITndZVzQrUEhSemNHRnVJSGc5SWpNeExqYzFKU0lnWkhrOUlqRXVNbVZ0SWo0bUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdQSFJ6Y0dGdUlHWnBiR3c5SWlObVpqRTBNVFFpUGlBOEwzUnpjR0Z1UGlZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU1UczhkSE53WVc0Z1ptbHNiRDBpSTJabVpEY3dNQ0krSmlONE16bEZPend2ZEhOd1lXNCtKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVHUTdQQzkwYzNCaGJqNDhkSE53WVc0Z2VEMGlNekV1TnpVbElpQmtlVDBpTVM0eVpXMGlQaVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40WkRzOEwzUnpjR0Z1UGp4MGMzQmhiaUI0UFNJek5TNDNOU1VpSUdSNVBTSXhMakpsYlNJK0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzaGtPend2ZEhOd1lXNCtQSFJ6Y0dGdUlIZzlJakV5SlNJZ1pIazlJakV1TW1WdElqNG1JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU1Ec21JM2d5TURzbUkzZ3lNRHNtSTNneU1Ec21JM2d5TURzbUkzZ3lNRHNtSTNneU1Ec21JM2d5TURzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU1Uc21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRaRHM4TDNSemNHRnVQangwYzNCaGJpQjRQU0k0SlNJZ1pIazlJakV1TW1WdElqNG1JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREl3T3lZamVESXdPeVlqZURJd095WWplREl3T3lZamVESXdPeVlqZURJd095WWplREl3T3lZamVESXdPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRaRHM4TDNSemNHRnVQangwYzNCaGJpQjRQU0kwSlNJZ1pIazlJakV1TW1WdElqNG1JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qQTdKaU40TWpBN0ppTjRNakE3SmlONE1qQTdKaU40TWpBN0ppTjRNakE3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJd095WWplREl3T3lZamVESXdPeVlqZURJd095WWplREl3T3lZamVESXdPeVlqZUdRN1BDOTBjM0JoYmo0OGRITndZVzRnZUQwaU5DVWlJR1I1UFNJeExqSmxiU0krSmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREl3T3lZamVESXdPeVlqZURJd095WWplREl3T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU1Ec21JM2d5TURzbUkzZ3lNRHNtSTNneU1Ec21JM2d5TURzbUkzZ3lNRHNtSTNneU1Ec21JM2d5TURzbUkzaGtPend2ZEhOd1lXNCtQSFJ6Y0dGdUlIZzlJalFsSWlCa2VUMGlNUzR5WlcwaVBpWWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREl3T3lZamVESXdPeVlqZURJd095WWplREl3T3lZamVESXdPeVlqZURJd095WWplREl3T3lZamVESXdPeVlqZUdRN1BDOTBjM0JoYmo0OGRITndZVzRnZUQwaU9DVWlJR1I1UFNJeExqSmxiU0krSmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qQTdKaU40TWpBN0ppTjRNakE3SmlONE1qQTdKaU40WkRzOEwzUnpjR0Z1UGp4MGMzQmhiaUI0UFNJeE1pVWlJR1I1UFNJeExqSmxiU0krSmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNU16c21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU1TXpzbUkzZ3lOVGt6T3lZamVESTFPVE03SmlONE1qVTVNenNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNU16c21JM2d5TlRrek95WWplREkxT1RNN0ppTjRNalU1TXpzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qQTdKaU40TWpBN0ppTjRNakE3SmlONE1qQTdKaU40WkRzOEwzUnpjR0Z1UGp4MGMzQmhiaUI0UFNJek1pVWlJR1I1UFNJeExqSmxiU0krSmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5Ua3pPeVlqZURJMU9UTTdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNoa096d3ZkSE53WVc0K1BIUnpjR0Z1SUhnOUlqSTRKU0lnWkhrOUlqRXVNbVZ0SWo0bUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTVNVHNtSTNneU5Ua3hPeVlqZURJMU9URTdKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTVNVHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU1TVRzbUkzZ3lOVGt4T3lZamVESTFPVEU3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9URTdKaU40TWpVNU1Uc21JM2d5TlRreE95WWplREkxT1RFN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVHUTdQQzkwYzNCaGJqNDhkSE53WVc0Z2VEMGlNamdsSWlCa2VUMGlNUzR5WlcwaVBpWWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9Ec21JM2d5TlRnNE95WWplREkxT0RnN0ppTjRNalU0T0RzbUkzZ3lOVGc0T3lZamVESTFPRGc3SmlONE1qVTRPRHNtSTNneU5UZzRPeVlqZURJMU9EZzdKaU40TWpVNE9EczhMM1J6Y0dGdVBqd3ZkR1Y0ZEQ0OEwzTjJaejQ9IiwibmFtZSI6IkJpbmdvIHRoZSBoYWxmIGRlYWQgaGFsZiBldGggZXllZCBhc2NpaSBhcGUgIzEiLCJhdHRyaWJ1dGVzIjpbeyJ0cmFpdF90eXBlIjoiRmFjZXN5bW1ldHJ5IiwidmFsdWUiOiIxMDAifV19";
        for (let i = 1; i <= 1; i++) {
            await nftContract.mint({ value: mintPrice });

            let apeName = await nftContract.getNameOfApe(i);

            console.log("\n\napeName: ", apeName);

            queriedTokenUri = await nftContract.tokenURI(i);

            console.log("\n\nfetched token: ", queriedTokenUri);

            // tmp = utf8_to_b64(queriedTokenUri);
            // base64DecodedData = b64_to_utf8(tmp);

            // console.log("\n\nbase64DecodedData: ", base64DecodedData);
            let jsonData = tokenURI_to_JSON(queriedTokenUri);
            let imageDataBase64 = jsonData.image;
            console.log(imageDataBase64);

            let svgData = imageDataBase64.substring(26);
            let decodedSvgData = atob(svgData);
            console.log("image encode data\n\n", svgData);

            console.log("decoded svg: \n\n", decodedSvgData);

            //write svg to file
            let filename = './GenApes/' + JSON.stringify(i) + '.svg';
            fs.writeFile(filename, decodedSvgData, err => {
                if (err) {
                    console.error(err);
                }
                // file written successfully
            });

        };





    });





});