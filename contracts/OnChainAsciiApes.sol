// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //>=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//todo need to check if special apes have always same eye types and colors, if we dont need to transfer both eyes and adapt special ape generation
//todo need to add properties
//todo the names of the special apes must fit with their index (#1) for example needs index 1, would be possible to do this by ApeGenerator as well
//todo the eye array need to fix with the ApeGenerator name assertion
//todo check if creator fees are available
//todo add a banana score
//todo can we switch to a struct which holds all ape details like, left- and right eye, name, bananascore, svg...

contract OnChainAsciiApes is ERC721Enumerable, Ownable {
    //variable packing can put multiple variables in one slot (consists of 32byte->256bit) ->each storage slot costs gas
    // variable packing only occurs in storage

    address accessControlContractAddress;
    ApeGeneratorImpl apeGenerator;
    bool UseSeedWithTestnet; //1=seed with hash calc, 0=seed just given with example value in program
    bool publicMintActive; //0=whitelist activated, 1=whitelist deactivated->public mint

    using Counters for Counters.Counter;

    Counters.Counter private tokensAlreadyMinted;
    uint256 private lastGetRandomNumber;

    uint256 mintPriceWei;

    constructor(
        bool _useSeedWithTestnet,
        address _apeGeneratorContractAddress,
        address _accessControlContractAddress,
        uint256 _mintPriceWei
    ) ERC721("OnChainAsciiApes", "^.^") {
        //create seed on contract deploying, this is used for random generation later ToDo
        UseSeedWithTestnet = _useSeedWithTestnet;
        if (UseSeedWithTestnet) {
            lastGetRandomNumber = uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            );
        } else {
            lastGetRandomNumber = 1;
        }

        mintPriceWei = _mintPriceWei;

        //link other contracts
        linkApeGenerator(_apeGeneratorContractAddress);

        accessControlContractAddress = _accessControlContractAddress;

        //define tokenId start with 1, so first ape = tokenId1
        //tokensAlreadyMinted.increment();
    }

    function withdraw() public payable onlyOwner {
        require(address(this).balance > 0, "contract balance=0");
        payable(msg.sender).transfer(address(this).balance);
    }

    /* getters - start*/

    function getBalance() public view returns (uint256) {
        return (address(this).balance);
    }

    function checkIfWhitelisted(address _addressToBeChecked)
        public
        view
        returns (bool)
    {
        accessControlImpl accessControl = accessControlImpl(
            accessControlContractAddress
        );
        return (accessControl.isAccessGranted(_addressToBeChecked));
    }

    function enablePublicMint() public onlyOwner {
        publicMintActive = true;
    }

    function totalSupply() public view override returns (uint256) {
        return (apeGenerator.totalSupply());
    }

    function getNrOfLeftTokens() public view returns (uint256) {
        return (apeGenerator.totalSupply() - tokensAlreadyMinted.current());
    }

    /* getters - end*/

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return apeGenerator.getTokenURI(uint8(_tokenId));
    }

    function createRandomNumber() private returns (uint256) {
        //idea of creating a random number by using a value from the wallet address and mix it up with modulo
        if (UseSeedWithTestnet) {
            lastGetRandomNumber = uint256(
                (
                    keccak256(
                        abi.encodePacked(
                            msg.sender,
                            blockhash(block.number - 1),
                            block.timestamp,
                            lastGetRandomNumber
                        )
                    )
                )
            );
        } else {
            lastGetRandomNumber = lastGetRandomNumber + 7;
        }

        return lastGetRandomNumber;
    }

    function createRandomNumberInRange(uint8 _range) private returns (uint8) {
        //the range varies under 255 so we can convert to uint8 without problems
        return uint8(createRandomNumber() % _range);
    }

    //todo if this is not set as private, it could be changed during mint, so this could result in a proxy, if sth fails,
    //but on the other hand it could be changed during mint...
    function linkApeGenerator(address _apeGeneratorContractAddress)
        public
        onlyOwner
    {
        require(
            _apeGeneratorContractAddress != address(0),
            "apeGenerator contract address invalid"
        );
        apeGenerator = ApeGeneratorImpl(_apeGeneratorContractAddress);
    }

    function mint() public payable {
        require(createAssignMint(), "mint failed");
    }

    function createAssignMint() private returns (bool success) {
        //at first we should check if enough money was sent to mint nft
        //ToDo: outcomment this line and define mint price
        //require(msg.value >= 1e15, "insufficient amount for nft minting given"); //0.001 eth
        // pre work for mint - start
        require(
            getNrOfLeftTokens() > 0,
            "already minted out, check secondary market"
        );
        require(
            msg.value >= mintPriceWei,
            "given eth amount too low for minting"
        );
        if (!publicMintActive) {
            //check if access is granted
            require(checkIfWhitelisted(msg.sender), "not whitelisted");
        }

        //check if current id should lead to special ape

        uint8 randomCreatedMintCombinationIndex = createRandomNumberInRange(
            apeGenerator.nrOfAvailableMintCombinations()
        );
        uint8 currentTokenId = uint8(tokensAlreadyMinted.current());
        uint8 specialApeIndex = apeGenerator.getSpecialApeIndex(currentTokenId);

        if (specialApeIndex != totalSupply() + 1) {
            require(
                apeGenerator.generateAndRegisterApe(
                    specialApeIndex,
                    0,
                    0,
                    0,
                    currentTokenId,
                    0
                ),
                "apeGen failed"
            );
        } else {
            require(
                apeGenerator.generateAndRegisterApe(
                    0,
                    randomCreatedMintCombinationIndex,
                    createRandomNumberInRange(3),
                    createRandomNumberInRange(3),
                    currentTokenId,
                    createRandomNumberInRange(
                        apeGenerator.getLengthOfApeNamesArray()
                    )
                ),
                "apeGen failed"
            );
        }

        _safeMint(msg.sender, currentTokenId);

        //todo: should we add requirement for removing so it needs to be removed before called again
        //removing only if all data generated, otherwise generated data does not fix with name and we could get access problems
        if (specialApeIndex == totalSupply() + 1) {
            //ape of mint combinations was wanted
            //remove used mint combination from available ones
            apeGenerator.removeMintCombinationUnordered(
                randomCreatedMintCombinationIndex
            );
        }

        tokensAlreadyMinted.increment();
        return true; //if we reach this point the data was created, registered and minted succesfully
    }
}

/*other contract implemenations - start*/
abstract contract ApeGeneratorImpl {
    function getLengthOfApeNamesArray() public view virtual returns (uint8);

    function totalSupply() public view virtual returns (uint256);

    function removeMintCombinationUnordered(uint256 _indexToRemove)
        public
        virtual;

    function nrOfAvailableMintCombinations()
        public
        view
        virtual
        returns (uint8);

    function getSpecialApeIndex(uint8 _tokenId)
        public
        view
        virtual
        returns (uint8);

    function generateAndRegisterApe(
        uint8 _specialApeIndex,
        uint8 _randomNumber,
        uint8 _eyeColorIndexLeft,
        uint8 _eyeColorIndexRight,
        uint8 _tokenId,
        uint8 _apeNameIndex
    ) public virtual returns (bool);

    function getTokenURI(uint8) public view virtual returns (string memory);
}

abstract contract accessControlImpl {
    function isAccessGranted(address _adressToBeChecked)
        public
        view
        virtual
        returns (bool);
}
/*other contract implemenations - end*/
