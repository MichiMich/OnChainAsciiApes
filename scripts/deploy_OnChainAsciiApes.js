const hre = require("hardhat");
const { ethers } = require("hardhat");


async function main() {

    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);

    //get available accounts from hardhat
    accounts = await hre.ethers.getSigners();

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

    //deploying contracts - start
    //apeGenerator
    const ApeGenerator = await hre.ethers.getContractFactory("ApeGenerator");
    const apeGenerator_contract = await ApeGenerator.deploy();

    //accessControl
    const AccessControl = await hre.ethers.getContractFactory("AccessControl");
    const AccessControl_contract = await AccessControl.deploy();

    //nftContract
    const OnChainAsciiApes = await hre.ethers.getContractFactory("OnChainAsciiApes"); //ChainApes
    const onChainAsciiApes_contract = await OnChainAsciiApes.deploy(false, apeGenerator_contract.address, AccessControl_contract.address, 1e15);

    //deploying contracts - end

    //contract linking - start
    AccessControl_contract.linkNftContractAddress(onChainAsciiApes_contract.address);
    //contract linking - end


}