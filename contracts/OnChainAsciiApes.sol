// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //>=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";
import "hardhat/console.sol";

//todo add a revert if nft create is not succesfull: if(!success) revert mintNft_Revert();
//need to define what mintNft_Revert does then, check: https://www.youtube.com/watch?v=pgh74-XulXg

contract OnChainAsciiApes is ERC721Enumerable, Ownable {
    //variable packing can put multiple variables in one slot (consists of 32byte->256bit) ->each storage slot costs gas
    // variable packing only occurs in storage

    address apeGeneratorContractAddress;
    address accessControlContractAddress;

    using Counters for Counters.Counter;

    bool UseSeedWithTestnet; //1=seed with hash calc, 0=seed just given with example value in program

    struct mintCombination {
        uint256 apeLeftEye;
        uint256 apeRightEye;
    }

    mintCombination[] arrayOfAvailableMintCombinations;

    uint256 private maxTokenSupply;
    Counters.Counter private tokensAlreadyMinted;
    uint256 private lastGetRandomNumber;

    // struct stringCreation {
    //     string value;
    //     uint256 nrUsedInSequence;
    // }

    mapping(uint256 => string) id_to_asciiApe;
    mapping(uint256 => string) id_to_apeName;

    mapping(uint256 => uint256) createdCombinationMapping; //eyebrows and eyes for example

    // mapping(uint256 => mapping(uint256 => uint256) would be with 3 values

    //only for testing, should be done in metadata then
    uint256 randomNumEyebrowLeft;
    uint256 randomNumEyebrowRight;
    uint256 randomNumEyeLeft;
    uint256 randomNumEyeRight;
    uint256 randomNumMouthUpper;
    uint256 randomNumMouthLower;
    uint256 mintPriceWei;

    string[13] apeEyes = [
        "&#x20;",
        "&#x2588;",
        "&#x2665;",
        "&#xac;",
        "&#x2d8;",
        "&#x5e;",
        "&#x58;",
        "&#x25d4;",
        "&#x25d5;",
        "&#x273f;",
        "&#xca5;",
        "&#x25c9;",
        "&#x2686;" //" ", "█","♥","¬","˘","^","X","◔","◕","✿","ಥ","◉","⚆"
        //could think about adding flowers &#x2740; ->❀ but we have already flowers
    ];

    struct st_specialApes {
        uint256 tokenId;
        string name;
        string textFillColor;
        string leftEye;
        string rightEye;
    }

    st_specialApes[] ast_specialApes;

    constructor(
        bool _useSeedWithTestnet,
        address _apeGeneratorContractAddress,
        address _accessControlContractAddress,
        uint256 _mintPriceWei
    ) ERC721("Ape", "^.^") {
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

        defineMintCombinations();

        mintPriceWei = _mintPriceWei;

        //link other contract addresses
        apeGeneratorContractAddress = _apeGeneratorContractAddress;
        accessControlContractAddress = _accessControlContractAddress;

        //define tokenId start with 1, so first ape = tokenId1
        tokensAlreadyMinted.increment();

        ast_specialApes.push(
            st_specialApes(
                11,
                "Harry the banana power love eyed ape #1",
                "hsl(56,100%,39%)",
                "&#x2665;",
                "&#x2665;"
            )
        );

        ast_specialApes.push(
            st_specialApes(
                99,
                "Groot the leaf eyed ape",
                "hsl(310,65%,22%)",
                "&#x1f340;",
                "&#x1f340;" //"&#x2740;" ->❀
            )
        );

        ast_specialApes.push(
            st_specialApes(
                3,
                "Piu the golden empty eyed ape #3",
                "gold",
                "&#x20;",
                "&#x20;"
            )
        );

        ast_specialApes.push(
            st_specialApes(
                4,
                "ApeNorris the angry eyed rarest toughest mf ape",
                "hsl(6, 100%, 52%)",
                "&#x22cb;", //⋋
                "&#x22cc;" //⋌  leads to ⋋ ⋌
            )
        );

        ast_specialApes.push(
            st_specialApes(
                5,
                "Chill ape the mariuhana eyed chilling ape",
                "hsl(6, 100%, 52%)",
                "&#1F341;", //⋋
                "&#1F341;" //⋌  leads to ⋋ ⋌
            )
        );

        ast_specialApes.push(
            st_specialApes(
                6,
                "Bruce the bat eyed ape",
                "white",
                "&#x1f987;", //🦇
                "&#x1f987;" //🦇
            )
        );

        ast_specialApes.push(
            st_specialApes(
                7,
                "Satoshi the btc eyed ape",
                "white",
                "&#x20BF;", //₿
                "&#x20BF;" //₿
            )
        );

        ast_specialApes.push(
            st_specialApes(
                7,
                "Vitalik the ethereum eyed ape",
                "white",
                "&#x39E;", //Ξ
                "&#x39E;" //Ξ
            )
        );

        //Add special apes to max token suppl
        maxTokenSupply += ast_specialApes.length;
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

    function totalSupply() public view override returns (uint256) {
        return maxTokenSupply;
    }

    function getAvailableMintCombinations()
        public
        view
        returns (mintCombination[] memory)
    {
        return (arrayOfAvailableMintCombinations);
    }

    function getNrOfLeftTokens() public view returns (uint256) {
        return (maxTokenSupply - tokensAlreadyMinted.current());
    }

    function getApe(uint256 _tokenId) public view returns (string memory) {
        require(
            _tokenId <= maxTokenSupply, //Todo do we want a zero ape? if yes it can be like it is, otherwise we need to check for >0
            "given tokenId is invalid"
        );

        return id_to_asciiApe[_tokenId];
    }

    function getNameOfApe(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        require(_tokenId <= maxTokenSupply, "given tokenId is invalid");
        return id_to_apeName[_tokenId];
    }

    /* getters - end*/

    function defineMintCombinations() private {
        for (uint256 j = 0; j < apeEyes.length; j++) {
            for (uint256 i = 0; i < apeEyes.length; i++) {
                arrayOfAvailableMintCombinations.push(mintCombination(j, i));
                maxTokenSupply += 1;
            }
        }
    }

    function registerGeneratedToken(
        uint256 _tokenID,
        string memory _generatedData,
        string memory _generatedName
    ) private {
        //add values to mapping, can be a struct mapping or single data mapping, single data will then return created data
        id_to_asciiApe[_tokenID] = _generatedData;

        //register name of this one
        id_to_apeName[_tokenID] = _generatedName;

        //add parameters like rarity, symmetry, ....
    }

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
                                '{"name": "',
                                id_to_apeName[_tokenId],
                                '", "description": "Fully onchain generated AsciiApe", "image": "data:image/svg+xml;base64,',
                                id_to_asciiApe[_tokenId],
                                '"}'
                            )
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
                            (msg.sender),
                            ast_specialApes[
                                uint256(blockhash(block.number - 1)) %
                                    ast_specialApes.length
                            ].name,
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

    function createNft() public payable returns (bool success) {
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

        //call ape generatore contract functions
        ApeGeneratorImpl apeGenerator = ApeGeneratorImpl(
            apeGeneratorContractAddress
        );

        require(
            apeGeneratorContractAddress != address(0),
            "apeGenerator contract address invalid"
        );

        //used data for mint
        string memory createdApe;
        string memory createdApeName;
        bool apeNameCreationSuccesfull;
        uint256 currentActiveSpecialApeIndex;
        uint256 randomCreatedMintCombinationIndex;

        // search if tokenId should lead to special ape

        for (
            currentActiveSpecialApeIndex = 0;
            currentActiveSpecialApeIndex < ast_specialApes.length;
            currentActiveSpecialApeIndex++
        ) {
            if (
                ast_specialApes[currentActiveSpecialApeIndex].tokenId ==
                tokensAlreadyMinted.current()
            ) {
                //we want to create an special ape now
                break;
            }
        }

        if (currentActiveSpecialApeIndex != ast_specialApes.length) {
            //we want to create special ape
            createdApe = apeGenerator.getGeneratedApe(
                ast_specialApes[currentActiveSpecialApeIndex].leftEye,
                ast_specialApes[currentActiveSpecialApeIndex].rightEye,
                true, //special ape generation
                ast_specialApes[currentActiveSpecialApeIndex].textFillColor, //text fill color not needed, default used
                0,
                0
            );
        } else {
            randomCreatedMintCombinationIndex = createRandomNumberInRange(
                arrayOfAvailableMintCombinations.length
            );

            uint256 randomCreatedApeNameIndex = createRandomNumberInRange(
                apeGenerator.getLengthOfApeNamesArray()
            );

            createdApe = apeGenerator.getGeneratedApe(
                apeEyes[
                    arrayOfAvailableMintCombinations[
                        randomCreatedMintCombinationIndex
                    ].apeLeftEye
                ],
                apeEyes[
                    arrayOfAvailableMintCombinations[
                        randomCreatedMintCombinationIndex
                    ].apeRightEye
                ],
                false, //special ape generation
                "", //text fill color not needed, default used
                createRandomNumberInRange(3),
                createRandomNumberInRange(3)
            );

            //lets require ApeNameGeneration here first, otherwise we could end up in a fallback error (happened if we define ApeGenerator function with 3 inputs here and in ApeGenerator it has 4 inputs)
            (createdApeName, apeNameCreationSuccesfull) = apeGenerator
                .generateApeName(
                    randomCreatedApeNameIndex,
                    arrayOfAvailableMintCombinations[
                        randomCreatedMintCombinationIndex
                    ].apeLeftEye,
                    arrayOfAvailableMintCombinations[
                        randomCreatedMintCombinationIndex
                    ].apeRightEye,
                    tokensAlreadyMinted.current()
                );

            require(apeNameCreationSuccesfull, "ape name creation failed");
        }

        bytes memory createdSvgNft = bytes(abi.encodePacked(createdApe));

        //empty string means ape generation failed
        require(createdSvgNft.length != 0, "ape generation failed");

        _safeMint(msg.sender, tokensAlreadyMinted.current());

        //removing only if all data generated, otherwise generated data does not fix with name and we could get access problems
        if (currentActiveSpecialApeIndex == ast_specialApes.length) {
            //ape of mint combinations created
            registerGeneratedToken(
                tokensAlreadyMinted.current(),
                string(Base64.encode(createdSvgNft)),
                createdApeName
            );

            //remove used mint combination from available ones
            removeMintCombinationUnordered(randomCreatedMintCombinationIndex);
        } else {
            //special ape does not need to be removed of anywhere, because one tokenId=one special ape, so tokenId decrementation and struct defination of special apes guarantee this ->human input errors possible^^ sure, its code written by me^^
            registerGeneratedToken(
                tokensAlreadyMinted.current(),
                string(Base64.encode(createdSvgNft)),
                ast_specialApes[currentActiveSpecialApeIndex].name
            );
        }

        tokensAlreadyMinted.increment();
        return true; //if we reach this point the data was created and minted succesfully
    }

    function removeMintCombinationUnordered(uint256 _indexToRemove) private {
        require(
            _indexToRemove <= arrayOfAvailableMintCombinations.length ||
                arrayOfAvailableMintCombinations.length > 0,
            "index out of range"
        );
        if (_indexToRemove == arrayOfAvailableMintCombinations.length - 1) {
            arrayOfAvailableMintCombinations.pop();
        } else {
            arrayOfAvailableMintCombinations[
                _indexToRemove
            ] = arrayOfAvailableMintCombinations[
                arrayOfAvailableMintCombinations.length - 1
            ];
            arrayOfAvailableMintCombinations.pop();
        }
    }
}

/*other contract implemenations - start*/
abstract contract ApeGeneratorImpl {
    function getLengthOfApeNamesArray() public view virtual returns (uint256);

    function getGeneratedApe(
        string memory leftEye,
        string memory rightEye,
        bool specialApeGeneration,
        string memory textFillColor,
        uint256 _eyeColorLeft,
        uint256 _eyeColorRight
    ) public view virtual returns (string memory);

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
