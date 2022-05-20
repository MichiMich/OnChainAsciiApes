//write gen svgs to file
const { ethers } = require("hardhat");
const fs = require('fs');

//user input
const readline = require('readline');

exports.deployApeGenerator = async function () {
    const ApeGenerator = await hre.ethers.getContractFactory("ApeGenerator");
    const apeGenerator = await ApeGenerator.deploy();
    await apeGenerator.deployed();
    console.log("ApeGenerator deployed at: ", apeGenerator.address);
    return (apeGenerator);
}

exports.deployAccessControl = async function () {
    const AccessControl = await hre.ethers.getContractFactory("AccessControl");
    const accessControl = await AccessControl.deploy();
    await accessControl.deployed();
    console.log("AccessControl deployed to:", accessControl.address);
    return (accessControl);
}

exports.deployNftMintContract = async function (_apeGeneratorAddress, _accessControlAddress, _mintPrice) {
    const networkName = hre.network.name;
    const chainId = hre.network.config.chainId
    console.log("chainId: ", chainId);
    /*let useSeedWithTestnet;
    if (chainId == "4" || networkName === "rinkeby" || networkName === "hardhat") {
        //rinkeby
        console.log("seed with testnet used");
        useSeedWithTestnet = true;
    }*/
    const NftMintContract = await hre.ethers.getContractFactory("OnChainAsciiApes");
    const nftContract = await NftMintContract.deploy(_apeGeneratorAddress, _accessControlAddress, _mintPrice); //mint price set to 1e15 = 1 finney = 0.001 eth
    await nftContract.deployed();

    console.log("nftMintContract deployed to:", nftContract.address);
    return (nftContract);
}

exports.createSvgFromTokenURI = function (tokenURI, pathAndFilename) {
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


exports.createAndAdaptSvgFromTokenURI = function (tokenURI, pathAndFilename, apeName) {
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

exports.getNameOfTokenURI = function (tokenURI) {
    const nameOfTokenURI = seperateMetadata(tokenURI).name;
    return (nameOfTokenURI);
}


exports.getAttributesOftokenURI = function (tokenURI) {
    const attributesOfTokenURI = seperateMetadata(tokenURI).attributes;
    //console.log(attributesOfTokenURI);
    return (attributesOfTokenURI);
}

exports.getNameOfApeByTokenURI = function (tokenURI) {
    const nameByMetadata = seperateMetadata(tokenURI).name;
    return (nameByMetadata);
}

tokenURI_to_JSON = function (tokenURI) {
    const json = atob(tokenURI.substring(29));
    return (JSON.parse(json));
}

seperateMetadata = function (tokenURI) {
    return (tokenURI_to_JSON(tokenURI));
}


exports.getUserInput = function (query) {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    });

    return new Promise(resolve => rl.question(query, ans => {
        rl.close();
        resolve(ans);
    }))
}

exports.addDataToFile = function (pathAndFilename, data) {
    fs.appendFile(pathAndFilename, data, err => {
        if (err) {
            console.error(err);
        }
        // file written successfully
    });
}

exports.getLastGithubCommit = function () {
    const rev = fs.readFileSync('.git/HEAD').toString().trim();
    if (rev.indexOf(':') === -1) {
        return rev;
    } else {
        return fs.readFileSync('.git/' + rev.substring(5)).toString().trim();
    }
}


exports.getLastGithubCommit = function () {
    const rev = fs.readFileSync('.git/HEAD').toString().trim();
    if (rev.indexOf(':') === -1) {
        return rev;
    } else {
        return fs.readFileSync('.git/' + rev.substring(5)).toString().trim();
    }
}


exports.getUsedTaxForLastBlock = async function () {
    const block = await hre.ethers.provider.getBlock();
    const gasUsed = parseInt(block.gasUsed._hex, 16);
    return (gasUsed);
}

exports.getSentValueOfLastBlock = async function () {
    const block = await hre.ethers.provider.getBlockWithTransactions();
    const valueTransmitted = parseInt(block.transactions[0].value._hex, 16);
    return (valueTransmitted);
}