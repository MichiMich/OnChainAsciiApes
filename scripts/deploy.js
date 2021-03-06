const hre = require("hardhat");
const { ethers } = require("hardhat");


async function main() {

    const mintPrice = ethers.utils.parseUnits("5", 15);

    //get available accounts from hardhat
    accounts = await hre.ethers.getSigners();

    //nft mint contract specific
    const networkName = hre.network.name
    const chainId = hre.network.config.chainId
    console.log("chainId: ", chainId);


    //deploying contracts - start
    //apeGenerator
    const ApeGenerator = await hre.ethers.getContractFactory("ApeGenerator");
    const apeGenerator = await ApeGenerator.deploy();
    await apeGenerator.deployed();
    console.log("ApeGenerator deployed at: ", apeGenerator.address);

    //accessControl
    const AccessControl = await hre.ethers.getContractFactory("AccessUnitControl");
    const accessControl = await AccessControl.deploy();
    await accessControl.deployed();
    console.log("AccessControl deployed at: ", accessControl.address);

    //nftContract
    const NftContract = await hre.ethers.getContractFactory("OnChainAsciiApes"); //ChainApes
    const nftContract = await NftContract.deploy(apeGenerator.address, accessControl.address, 5e15);
    await nftContract.deployed();
    console.log("OnChainAsciiApes deployed at: ", nftContract.address);

    //deploying contracts - end

    //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
    await apeGenerator.transferOwnership(nftContract.address)
    console.log("new owner of apeGenerator is now onChainAsciiApes");

    //enable public mint
    //await nftContract.enablePublicMint();
    //console.log("public mint enabled");

    //link accessUnitControl
    await accessControl.linkHandshakeContract(nftContract.address);
    console.log("accessControl linked to nftContract");

    //allow owner to mint
    //await accessControl.addAddressToAccessAllowed(accounts[0].address, 200);
    //console.log("owner allowed to mint 200 pieces for test");

    //try minting one
    //await nftContract.mint(1, { value: mintPrice });
    //queriedTokenUri = await nftContract.tokenURI(0);
    //console.log(queriedTokenUri);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });