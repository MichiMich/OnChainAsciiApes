// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //>=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";

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

    using Counters for Counters.Counter;

    bool UseSeedWithTestnet; //1=seed with hash calc, 0=seed just given with example value in program

    Counters.Counter private tokensAlreadyMinted;
    uint256 private lastGetRandomNumber;

    // struct stringCreation {
    //     string value;
    //     uint256 nrUsedInSequence;
    // }

    //todo: is this still needed?
    mapping(uint256 => uint256) createdCombinationMapping; //eyebrows and eyes for example

    mapping(uint256 => st_apeDetails) id_to_apeDetails;
    // mapping(uint256 => mapping(uint256 => uint256) would be with 3 values
    //todo in apeGenerator already, could we get rid of this here?
    struct st_ApeCoreElements {
        uint256 tokenId;
        string name;
        uint8 leftEyeIndex;
        uint8 rightEyeIndex;
        uint8 eyeColorLeft;
        uint8 eyeColorRight;
        string apeColor;
    }

    struct st_apeDetails {
        st_ApeCoreElements apeCoreElements;
        //string svg; //not needed, base64 encoded svg holds data
        bytes base64EncodedSvg;
        string symmetry;
        string[3] bananascore;
    }

    //only for testing, should be done in metadata then
    uint256 randomNumEyebrowLeft;
    uint256 randomNumEyebrowRight;
    uint256 randomNumEyeLeft;
    uint256 randomNumEyeRight;
    uint256 randomNumMouthUpper;
    uint256 randomNumMouthLower;
    uint256 mintPriceWei;

    bool publicMintActive; //0=whitelist activated, 1=whitelist deactivated->public mint

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
        tokensAlreadyMinted.increment();
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

    /*
    function getApe(uint256 _tokenId) public view returns (string memory) {
        require(_exists(_tokenId), "nonexistent token");
        // require(
        //     _tokenId <= maxTokenSupply, //Todo do we want a zero ape? if yes it can be like it is, otherwise we need to check for >0
        //     "given tokenId is invalid"
        // );
        return id_to_apeDetails[_tokenId].base64EncodedSvg;
    }
*/

    function getNameOfApe(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        //require(_tokenId <= maxTokenSupply, "given tokenId is invalid");
        require(_exists(_tokenId), "nonexistent token");
        return id_to_apeDetails[_tokenId].apeCoreElements.name;
    }

    /* getters - end*/

    //toDo: register should have st_apeDetails, non other needed
    function registerGeneratedToken(
        uint256 _tokenID,
        st_apeDetails memory _apeDetails
    ) private {
        //todo: here this should become a struct with all data stored, maybe generatedData is not needed in there
        if (
            _apeDetails.apeCoreElements.leftEyeIndex ==
            _apeDetails.apeCoreElements.rightEyeIndex
        ) {
            _apeDetails.symmetry = "100";
        } else {
            _apeDetails.symmetry = "50";
        }
        //todo: add banana score with random number

        id_to_apeDetails[_tokenID] = _apeDetails;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        // require(
        //     _exists(_tokenId),
        //     "ERC721Metadata: URI query for nonexistent token"
        // );
        require(
            bytes(id_to_apeDetails[_tokenId].apeCoreElements.name).length != 0,
            "nonexistendtoken"
        );
        return buildMetadata(_tokenId);
    }

    function buildMetadata(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        require(_exists(_tokenId), "Nonexistent token"); //ToDo: this is already checked by tokenURI call, we could leave this out
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"description":"Fully onchain generated AsciiApe","image":"data:image/svg+xml;base64,',
                                id_to_apeDetails[_tokenId].base64EncodedSvg,
                                '","name":"',
                                id_to_apeDetails[_tokenId].apeCoreElements.name,
                                '","attributes":[{"trait_type":"Facesymmetry","value":"',
                                //facesymmetry value
                                id_to_apeDetails[_tokenId].symmetry,
                                /*
                                '"},{"trait_type":"EyeLeft","value":"',
                                
                                apeEyes[
                                    id_to_apeDetails[_tokenId].leftEyeIndex
                                ], //eye left value
                                '"},{"trait_type":"EyeRight","value":"',
                                apeEyes[
                                    id_to_apeDetails[_tokenId]
                                        .leftEyeIndex
                                        .rightEyeindex
                                ], //eye right value
                                */
                                //todo: add bananascore value
                                '"}]}'
                            )

                            /*
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                id_to_apeName[_tokenId],
                                '", "description": "Fully onchain generated AsciiApe", "image": "data:image/svg+xml;base64,',
                                id_to_asciiApe[_tokenId],
                                '"}'
                            )*/
                        )
                    )
                )
            );
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

    function createRandomNumberInRange(uint256 _range)
        private
        returns (uint256)
    {
        return createRandomNumber() % _range;
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

    function mint() public payable returns (bool success) {
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

        uint256 randomCreatedMintCombinationIndex;

        st_apeDetails memory currentUsedApeDetails;
        uint256 currentTokenId = tokensAlreadyMinted.current();
        uint256 specialApeIndex = apeGenerator.getSpecialApeIndex(
            currentTokenId
        );

        if (specialApeIndex != 0) {
            //special ape wanted, no random number needed
            //currentUsedApeDetails.svg = apeGenerator.generateApe(currentTokenId, 0);
            (
                currentUsedApeDetails.base64EncodedSvg,
                currentUsedApeDetails.apeCoreElements.name
            ) = apeGenerator.generateApe(specialApeIndex, 0, 0, 0, 0, 0);
        } else {
            //create and call with random number in available range
            (
                currentUsedApeDetails.base64EncodedSvg,
                currentUsedApeDetails.apeCoreElements.name
            ) = apeGenerator.generateApe(
                0,
                createRandomNumberInRange(
                    apeGenerator.nrOfAvailableMintCombinations()
                ),
                createRandomNumberInRange(3),
                createRandomNumberInRange(3),
                currentTokenId,
                createRandomNumberInRange(
                    apeGenerator.getLengthOfApeNamesArray()
                )
            );
        }

        currentUsedApeDetails.base64EncodedSvg = bytes(
            Base64.encode(currentUsedApeDetails.base64EncodedSvg)
        );

        require(
            bytes(currentUsedApeDetails.base64EncodedSvg).length != 0,
            "ape creation failed"
        );
        require(
            bytes(currentUsedApeDetails.apeCoreElements.name).length != 0,
            "name creation failed"
        );

        _safeMint(msg.sender, currentTokenId);

        registerGeneratedToken(currentTokenId, currentUsedApeDetails);

        //todo: should we add requirement for removing so it needs to be removed before called again
        //removing only if all data generated, otherwise generated data does not fix with name and we could get access problems
        if (specialApeIndex == 0) {
            //ape of mint combinations was wanted, currentActiveSpecialApeIndex = counter in for loop and counted to end
            //remove used mint combination from available ones
            apeGenerator.removeMintCombinationUnordered(
                randomCreatedMintCombinationIndex
            );
        }

        tokensAlreadyMinted.increment();
        return true; //if we reach this point the data was created and minted succesfully
    }
}

/*other contract implemenations - start*/
abstract contract ApeGeneratorImpl {
    function getLengthOfApeNamesArray() public view virtual returns (uint256);

    function totalSupply() public view virtual returns (uint256);

    function removeMintCombinationUnordered(uint256 _indexToRemove)
        public
        virtual;

    function nrOfAvailableMintCombinations()
        public
        view
        virtual
        returns (uint256);

    function getSpecialApeIndex(uint256 _tokenId)
        public
        view
        virtual
        returns (uint256);

    function generateApe(
        uint256 _specialApeIndex,
        uint256 _randomNumber,
        uint256 _eyeColorIndexLeft,
        uint256 _eyeColorIndexRight,
        uint256 _tokenId,
        uint256 _apeNameIndex
    ) public view virtual returns (bytes memory, string memory);

    /*
    function getGeneratedApe(
        string memory leftEye,
        string memory rightEye,
        bool specialApeGeneration,
        string memory textFillColor,
        uint256 _eyeColorLeft,
        uint256 _eyeColorRight
    ) public view virtual returns (string memory);
*/
    function generateApeName(
        uint256 _apeNameIndex,
        uint256 _leftEyeIndex,
        uint256 _rightEyeIndex,
        uint256 _tokenId
    )
        public
        view
        virtual
        returns (string memory generatedApeName, bool success);
}

abstract contract accessControlImpl {
    function isAccessGranted(address _adressToBeChecked)
        public
        view
        virtual
        returns (bool);
}
/*other contract implemenations - end*/
