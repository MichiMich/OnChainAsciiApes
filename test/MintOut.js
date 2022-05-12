const { expect } = require("chai");
const { ethers } = require("hardhat");


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


    function disableNetworkLogging() {
        hre.config.networks.hardhat.loggingEnabled = false;
        console.log("network logging of hardhat chain disabled");
    }

    it("MintOut, deploy all needed contracts, mint", async function () {
        const totalSupplyOfNfts = await nftContract.totalSupply();

        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        for (let i = 0; i < totalSupplyOfNfts; i++) {
            await nftContract.mint({ value: mintPrice });

            queriedTokenUri = await nftContract.tokenURI(i);
        }
    });

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

    it("EndMintBeforeMintOut, deploy all needed contracts, mint", async function () {


        let totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply of nfts at mint start: ", totalSupplyOfNfts);
        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        for (let i = 0; i < 1; i++) {
            await nftContract.mint({ value: mintPrice });

            queriedTokenUri = await nftContract.tokenURI(i);
            getNameOfTokenURI(queriedTokenUri);
        }

        //end mint, it was not minted out
        //let txMintEnded = await nftContract.endMint();

        //end mint and expect event gets fired
        await expect(nftContract.endMint())
            .to.emit(apeGenerator, 'mintEndedSupplyReduced')
            .withArgs(1);

        totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply after mint was ended: ", totalSupplyOfNfts);

        await expect(nftContract.mint({ value: mintPrice })).to.be.reverted;

    });

});