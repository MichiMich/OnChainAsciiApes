const hre = require("hardhat");
const { ethers } = require("hardhat");


async function main() {

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
    const apeGenerator = await ApeGenerator.deploy();
    await apeGenerator.deployed();
    console.log("ApeGenerator deployed at: ", apeGenerator.address);

    //accessControl
    const AccessControl = await hre.ethers.getContractFactory("AccessControl");
    const accessControl = await AccessControl.deploy();
    await accessControl.deployed();
    console.log("AccessControl deployed at: ", accessControl.address);

    //nftContract
    const OnChainAsciiApes = await hre.ethers.getContractFactory("OnChainAsciiApes"); //ChainApes
    const onChainAsciiApes = await OnChainAsciiApes.deploy(false, apeGenerator.address, accessControl.address, 1e15);
    await onChainAsciiApes.deployed();
    console.log("OnChainAsciiApes deployed at: ", onChainAsciiApes.address);

    //deploying contracts - end

    //contract linking - start
    accessControl_contract.linkNftContractAddress(onChainAsciiApes.address);
    //contract linking - end


}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });