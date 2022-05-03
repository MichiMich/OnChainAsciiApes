// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //>=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Base64.sol";
import "hardhat/console.sol";

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

    address apeGeneratorContractAddress;
    address accessControlContractAddress;

    using Counters for Counters.Counter;

    bool UseSeedWithTestnet; //1=seed with hash calc, 0=seed just given with example value in program

    struct mintCombination {
        uint256 apeLeftEye;
        uint256 apeRightEye;
    }

    //dynamical array, will created by constructor and elements deleted after mint
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
    mapping(uint256 => mintCombination) id_to_mintCombination;
    //todo: is this still needed
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
    /*
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
    ];*/

    string[14] apeEyes = [
        " ",
        "&#x2588;", //█
        "&#x2665;", //♥
        "&#xac;", //¬
        "&#x2d8;", //˘
        "&#x5e;", //^
        "X", //X
        "&#x20BF;", //₿
        "&#x39E;", //Ξ -> eth symbol
        "0", //the zero ape could be a special ape with the first mint
        "&#xD2;", //Ò
        "&#xB4;", //´
        "&#x60;", //`
        "$"
        //"&#x27E0;", //⟠ -> eth symbol does not work, borders moved, no 100% fit
        //" ", "█","♥","¬","˘","^","X", ₿
        //could think about adding flowers &#x2740; ->❀ but we have already flowers
    ];

    //12 with special ape eyes would make 144 combinations + 5 special apes

    struct st_specialApes {
        uint256 tokenId;
        string name;
        string textFillColor;
        uint8 leftEyeIndex;
        uint8 rightEyeIndex;
        uint8 eyesColor; //0=red, 1=gold, 2=pink
    }

    st_specialApes[] ast_specialApes;

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

        defineMintCombinations();

        mintPriceWei = _mintPriceWei;

        //link other contract addresses
        apeGeneratorContractAddress = _apeGeneratorContractAddress;
        accessControlContractAddress = _accessControlContractAddress;

        //define tokenId start with 1, so first ape = tokenId1
        tokensAlreadyMinted.increment();
        ast_specialApes.push(
            st_specialApes(
                0,
                "Zero the first erver minted 0 eyed ape #0",
                "#c7ba00", //banana yellow
                9, //0
                9, //0
                0 //red eye color
            )
        );

        ast_specialApes.push(
            st_specialApes(
                11,
                "Harry the banana power love eyed ape #11",
                "#c7ba00", //banana yellow
                2, //♥
                2, //♥
                0 //red eye color
            )
        );

        ast_specialApes.push(
            st_specialApes(
                3,
                "Piu the golden empty eyed ape #3",
                "#ffd900", //golden
                0,
                0,
                1 //gold eye color
            )
        );

        ast_specialApes.push(
            st_specialApes(
                4,
                "ApeNorris the angry eyed rarest toughest mf ape #4",
                "#ff230a", //red
                12, //`
                11, //´ -> leads to ` ´
                0 //
            )
        );

        ast_specialApes.push(
            st_specialApes(
                6,
                "Carl the dead invisible ape #6",
                "#000000", //black->invisible
                9, //X
                9, //X
                2 //pink eye color
            )
        );

        ast_specialApes.push(
            st_specialApes(
                7,
                "Satoshi the btc eyed ape #7",
                "#ff33cc", //pink
                7, //₿
                7, //₿
                1 //gold eye color
            )
        );

        ast_specialApes.push(
            st_specialApes(
                8,
                "Vitalik the ethereum eyed ape #8",
                "#ffd900", //gold
                8, //Ξ
                8, //Ξ
                2 //pink eye color
            )
        );

        ast_specialApes.push(
            st_specialApes(
                9,
                "Dollari the inflationary dollar eyed ape #9",
                "#ff0000", //red
                13,
                13,
                0 //red eye color
            )
        );

        //Add special apes to max token supply
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

    function enablePublicMint() public onlyOwner {
        publicMintActive = true;
    }

    function totalSupply() public view override returns (uint256) {
        return maxTokenSupply;
    }

    //todo: can be cleared in the future
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
        require(_exists(_tokenId), "nonexistent token");
        // require(
        //     _tokenId <= maxTokenSupply, //Todo do we want a zero ape? if yes it can be like it is, otherwise we need to check for >0
        //     "given tokenId is invalid"
        // );
        return id_to_asciiApe[_tokenId];
    }

    function getNameOfApe(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        //require(_tokenId <= maxTokenSupply, "given tokenId is invalid");
        require(_exists(_tokenId), "nonexistent token");
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
        string memory _generatedName,
        mintCombination memory _mintCombination
    ) private {
        //todo: here this should become a struct with all data stored, maybe generatedData is not needed in there

        //add values to mapping, can be a struct mapping or single data mapping, single data will then return created data
        id_to_asciiApe[_tokenID] = _generatedData;

        //register name of this one
        id_to_apeName[_tokenID] = _generatedName;

        //register the combination of eyes
        id_to_mintCombination[_tokenID] = _mintCombination;

        //todo: add parameters like rarity, symmetry, ....
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
        require(bytes(id_to_apeName[_tokenId]).length != 0, "nonexistendtoken");
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
                                id_to_asciiApe[_tokenId],
                                '","name":"',
                                id_to_apeName[_tokenId],
                                '","attributes":[{"trait_type":"Facesymmetry","value":"',
                                //facesymmetry value
                                "100",
                                '"},{"trait_type":"EyeLeft","value":"',
                                apeEyes[
                                    id_to_mintCombination[_tokenId].apeLeftEye
                                ], //eye left value
                                '"},{"trait_type":"EyeRight","value":"',
                                apeEyes[
                                    id_to_mintCombination[_tokenId].apeRightEye
                                ], //eye right value
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
            //lefteye, righteye, specialape, textfillcolor, lefteyecolor, righteyecolor
            createdApe = apeGenerator.getGeneratedApe(
                apeEyes[
                    ast_specialApes[currentActiveSpecialApeIndex].leftEyeIndex
                ],
                apeEyes[
                    ast_specialApes[currentActiveSpecialApeIndex].rightEyeIndex
                ],
                true, //special ape generation
                ast_specialApes[currentActiveSpecialApeIndex].textFillColor,
                ast_specialApes[currentActiveSpecialApeIndex].eyesColor,
                ast_specialApes[currentActiveSpecialApeIndex].eyesColor
            );
            createdApeName = ast_specialApes[currentActiveSpecialApeIndex].name;
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
                createRandomNumberInRange(3), //a little "random" eye colors
                createRandomNumberInRange(3) //a little "random" eye colors
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
        require(
            bytes(createdApeName).length != 0,
            "ape name generation failed"
        );

        _safeMint(msg.sender, tokensAlreadyMinted.current());

        //removing only if all data generated, otherwise generated data does not fix with name and we could get access problems
        if (currentActiveSpecialApeIndex == ast_specialApes.length) {
            //ape of mint combinations wanted, currentActiveSpecialApeIndex = counter in for loop and counted to end
            registerGeneratedToken(
                tokensAlreadyMinted.current(),
                string(Base64.encode(createdSvgNft)),
                createdApeName,
                arrayOfAvailableMintCombinations[
                    randomCreatedMintCombinationIndex
                ]
            );

            //remove used mint combination from available ones
            removeMintCombinationUnordered(randomCreatedMintCombinationIndex);
        } else {
            //special ape does not need to be removed of anywhere, because one tokenId=one special ape, so tokenId decrementation and struct defination of special apes guarantee this ->human input errors possible^^ sure, its code written by me^^
            registerGeneratedToken(
                tokensAlreadyMinted.current(),
                string(Base64.encode(createdSvgNft)),
                ast_specialApes[currentActiveSpecialApeIndex].name,
                arrayOfAvailableMintCombinations[
                    randomCreatedMintCombinationIndex
                ]
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
