const { expect } = require("chai");
const { ethers } = require("hardhat");
const contractDeployment = require("../scripts/contractDeployment.js");
const helpfulScript = require("../scripts/helpful_script.js");

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


        await nftContract.enablePublicMint();
        console.log("public mint enabled");

        accounts = await hre.ethers.getSigners();

    })


    it("RevertNotAllowed, try adding address while not the owner", async function () {
        //add address, not by owner
        await expect(accessControl.connect(accounts[1]).addAddressToAccessAllowed(accounts[3].address, 1)).to.be.reverted;
        await expect(accessControl.connect(accounts[2]).addAddressToAccessAllowed(accounts[3].address, 1)).to.be.reverted;
    });

    it("AllowOne, link, add address, check access", async function () {
        await accessControl.linkHandshakeContract(nftContract.address);
        //add address, by owner
        await accessControl.addAddressToAccessAllowed(accounts[1].address, 1);
        //check if address is allowed to access
        expect(await accessControl.isAccessGranted(accounts[1].address)).to.be.true;

        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[1].address)).to.be.equal(1);

    });

    it("MintAndAccess, add multiple, mint, check nr and access again", async function () {
        const allowedNrOfMints = 3;

        await accessControl.linkHandshakeContract(nftContract.address);
        //add address, by owner
        await accessControl.addAddressToAccessAllowed(accounts[2].address, allowedNrOfMints);
        //check if address is allowed to access
        expect(await accessControl.isAccessGranted(accounts[2].address)).to.be.true;

        expect(await accessControl.getNrOfAllowedElementsPerAddress(accounts[2].address)).to.be.equal(allowedNrOfMints);

        //mint two more
        for (let i = 1; i <= allowedNrOfMints; i++) {
            //mint one, pay needed amount
            await (nftContract.connect(accounts[2]).mint({ value: mintPrice }));

            console.log("nft balance of account2", await nftContract.balanceOf(accounts[2].address))
            if (i != allowedNrOfMints) {
                //max allowed not reached yet
                expect(await accessControl.isAccessGranted(accounts[2].address)).to.be.true;
            }
            else {
                //zero left, not allowed anymore
                expect(await accessControl.isAccessGranted(accounts[2].address)).to.be.false;
            }
            //check if nr of left is correct
            console.log("nr of remaining nfts: ", await accessControl.getRemainingNrOfElementsPerAddress(accounts[2].address));
            //nr of left ones
            expect(await accessControl.getRemainingNrOfElementsPerAddress(accounts[2].address)).to.be.equal(allowedNrOfMints - i);
        }

    });

    it("MintOut, mint out all apes", async function () {
        const totalSupplyOfNfts = await nftContract.totalSupply();
        console.log("total supply of nfts: ", totalSupplyOfNfts);
        let queriedTokenUri;
        console.log("total supply: ", totalSupplyOfNfts);


        await nftContract.enablePublicMint();


        await nftContract.mint({ value: mintPrice });


        queriedTokenUri = await nftContract.tokenURI(1);
        let apeName = helpfulScript.getNameOfApeByTokenURI(queriedTokenUri);

        console.log("apeName: ", apeName);


        let ownerOf = await nftContract.ownerOf(1);
        console.log("ownerOf: ", ownerOf);



        console.log("queried tokenURI: ", queriedTokenUri);
        /*
        for (let i = 0; i < 1; i++) {
            await nftContract.mint({ value: mintPrice });

            //queriedTokenUri = await nftContract.tokenURI(i);

            //console.log("fetched token: ", queriedTokenUri);


        };
        */



    });





});