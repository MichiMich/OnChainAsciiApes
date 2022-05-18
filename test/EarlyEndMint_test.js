const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpfulScript = require("../scripts/helpful_script.js");
const contractDeployment = require("../scripts/contractDeployment.js");


describe("Mint and accessControl test", function () {

    let apeGenerator;
    let accessControl;
    let nftContract;
    const mintPrice = ethers.utils.parseUnits("1", 15);


    //Deploying contract before running tests
    beforeEach(async function () {

        [apeGenerator, accessControl, nftContract] = await contractDeployment.deployMintContractsWithAccessControl(mintPrice);


        //transfer ownership of apeGenerator to nftContract, so he can remove MintCombinations
        await apeGenerator.transferOwnership(nftContract.address)
        console.log("new owner of apeGenerator is now nftContract");


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


    it("EndMintBeforeMintOut, deploy all needed contracts, mint", async function () {


        let totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply of nfts at mint start: ", totalSupplyOfNfts);
        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        for (let i = 0; i < 1; i++) {
            await nftContract.mint({ value: mintPrice });

            queriedTokenUri = await nftContract.tokenURI(i);
            helpfulScript.getNameOfTokenURI(queriedTokenUri);
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