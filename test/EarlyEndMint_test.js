const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpfulScript = require("../scripts/helpful_script.js");
const contractDeployment = require("../scripts/contractDeployment.js");


describe("Mint and accessControl test", function () {

    let apeGenerator;
    let accessControl;
    let nftContract;
    let accounts;
    let counterMint;
    const mintPrice = ethers.utils.parseUnits("1", 15);
    const nrRegularMints = 201;
    const nrApesLeftFortTopDonators = 3;


    //Deploying contract before running tests
    beforeEach(async function () {
        accounts = await hre.ethers.getSigners();

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



        for (counterMint = 0; counterMint < nrRegularMints; counterMint++) {
            await nftContract.mint(1, { value: mintPrice });

            queriedTokenUri = await nftContract.tokenURI(counterMint);
            console.log(helpfulScript.getNameOfTokenURI(queriedTokenUri), " with token Id ", counterMint, "\n\n");
        }

        //end mint, it was not minted out
        //let txMintEnded = await nftContract.endMint();

        console.log("\n\ninitial specialApeDistribution: ", await apeGenerator.showSpecialApesData());
        //end mint and expect event gets fired
        await expect(nftContract.endMint())
            .to.emit(apeGenerator, 'mintEndedSupplyReduced')
            .withArgs(nrRegularMints + nrApesLeftFortTopDonators);

        //show initial special ape distribution
        console.log("\n\nspecialApeDistribution after mint ended: ", await apeGenerator.showSpecialApesData());

        console.log("left tokens after mint was ended early: ", await nftContract.getNrOfLeftTokens());
        expect(await nftContract.getNrOfLeftTokens()).to.be.equal(nrApesLeftFortTopDonators); //3 left for top3Donators

        totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply after mint was ended: ", totalSupplyOfNfts);

        await expect(nftContract.mint(1, { value: mintPrice })).to.be.reverted;
        console.log("minting after mint was ended was reverted");



        //now allow only top3donators to claim the last 3 apes
        await accessControl.linkHandshakeContract(nftContract.address); //link handshake contract to nftContract
        await accessControl.addAddressToAccessAllowed(accounts[1].address, 1);
        await accessControl.addAddressToAccessAllowed(accounts[2].address, 1);
        await accessControl.addAddressToAccessAllowed(accounts[3].address, 1);

        //only donators and only one 
        for (let i = 1; i <= 3; i++) {
            console.log("going on minting for donator: ", accounts[i].address);
            await nftContract.connect(accounts[i]).mint(1, { value: mintPrice })
            await expect(nftContract.connect(accounts[i]).mint(1, { value: mintPrice })).to.be.reverted;
            console.log("tokenID: ", counterMint + i - 1);
            queriedTokenUri = await nftContract.tokenURI(counterMint + i - 1);
            console.log(helpfulScript.getNameOfTokenURI(queriedTokenUri), "\n\n");
        }

        //all minted, nothing more left
        console.log("left tokens after top3 donators have minted: ", await nftContract.getNrOfLeftTokens());
        expect(await nftContract.getNrOfLeftTokens()).to.be.equal(0);

        //ok lets say we would allow even to be minted one more, they should be able because supply was ended
        await accessControl.addAddressToAccessAllowed(accounts[1].address, 2); //update account1 to be theoretically able to mint one more
        //we should expect require firing with no more tokens available
        await expect(nftContract.connect(accounts[1]).mint(1, { value: mintPrice })).to.be.revertedWith("minted out, check secondary market");
    });

});