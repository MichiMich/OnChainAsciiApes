// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

//ToDo: should only AsciiApes contract be able to call this?
//todo the names of the special apes must fit with their index (#1) for example needs index 1, would be possible to do this by ApeGenerator as well

contract ApeGenerator is Ownable {
    //default svg data

    // string private constant svgStartToEye =
    //     '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="white" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="39.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';
    // //'<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="white" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">                    &#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">                  &#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">                &#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">              &#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">              &#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';

    string private constant svgEyeToEnd =
        '</tspan>&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="12%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;        &#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="8%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;        &#x2588;&#x2588;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;      &#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;      &#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;    &#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;        &#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;        &#xd;</tspan><tspan x="8%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;    &#xd;</tspan><tspan x="12%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;    &#xd;</tspan><tspan x="32%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="28%" dy="1.2em">&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="28%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;</tspan></text></svg>';

    string[14] apeEyes = [
        "&#x20;", //space
        "&#x2588;", //█
        "&#x2665;", //♥
        "&#xac;", //¬
        "&#x2d8;", //˘
        "&#x5e;", //^ , &#x5e;
        "&#x58;", //X
        "&#x20BF;", //₿
        "&#x39E;", //Ξ -> eth symbol
        "&#x30;", //0
        "&#xD2;", //Ò
        "&#xB4;", //´
        "&#x60;", //` , &#x60;
        "&#x24;" //$
    ];

    struct st_apeGenAndRegisterDetails {
        st_apeCoreElements apeCoreElements;
        uint8 bananascore;
        uint8 specialApeIndex;
    }

    struct st_apeCoreElements {
        uint8 tokenId;
        uint8 eyeIndexLeft;
        uint8 eyeIndexRight;
        uint8 eyeColorIndexLeft;
        uint8 eyeColorIndexRight;
    }

    struct st_apeDefiningElements {
        uint8 specialApeIndex; //in range 0-maxTokenSupply=special ape, maxTokenSupply + 1 = regular ape
        uint8 apeLeftEyeIndex;
        uint8 apeRightEyeIndex;
        uint8 eyeColorIndexLeft;
        uint8 eyeColorIndexRight;
        uint8 tokenId;
        uint8 apeNameIndex;
        uint8 bananascore;
        bool isRegistered;
        /*
        todo: maybe remove, currently needed for checking if getTokenUri is called with registered ape
        we could as well check if it is forbidden to call all with 0 value?
        */
    }

    struct mintCombination {
        uint8 apeLeftEyeIndex;
        uint8 apeRightEyeIndex;
    }

    struct st_apeDetails {
        string metaData;
        string base64EncodedSvg;
    }

    struct st_SpecialApe {
        st_apeCoreElements apeCoreElements;
        string name;
        string apeColor;
    }

    mapping(uint256 => st_apeDetails) id_to_apeDetails;

    //holds all data which is needed to get the ape svg data
    mapping(uint256 => st_apeDefiningElements) id_to_apeDefiningElements;

    //special ape
    st_SpecialApe[] ast_specialApeDetails;

    uint8 private maxTokenSupply;

    //dynamical array, will created by constructor and elements deleted after mint
    mintCombination[] arrayOfAvailableMintCombinations;

    event mintEndedSupplyReduced(uint8 newTotalSupply);

    constructor() {
        defineMintCombinations();
        addSpecialApes();
    }

    function nrOfSpecialApes() public view returns (uint256) {
        return ast_specialApeDetails.length;
    }

    //this will cost gas, because of our counter
    function getSpecialApeIndex(uint8 tokenId) public view returns (uint8) {
        for (
            uint8 currentActiveSpecialApeIndex = 0;
            currentActiveSpecialApeIndex < ast_specialApeDetails.length;
            currentActiveSpecialApeIndex++
        ) {
            if (
                ast_specialApeDetails[currentActiveSpecialApeIndex]
                    .apeCoreElements
                    .tokenId == tokenId
            ) {
                //we want to create an special ape now, we return the index of the ape
                return (currentActiveSpecialApeIndex);
            }
        }
        return (maxTokenSupply + 1);
    }

    function defineMintCombinations() private {
        for (uint8 j = 0; j < apeEyes.length; j++) {
            for (uint8 i = 0; i < apeEyes.length; i++) {
                arrayOfAvailableMintCombinations.push(mintCombination(j, i));
                maxTokenSupply += 1;
            }
        }
    }

    function nrOfAvailableMintCombinations() public view returns (uint8) {
        return uint8(arrayOfAvailableMintCombinations.length);
    }

    function endMintReduceTotalSupply(uint8 _TokensAlreadyMinted)
        public
        onlyOwner
        returns (uint8)
    {
        //reducing the total supply leads to 0 nfts left->fires require statement
        maxTokenSupply = _TokensAlreadyMinted;
        //todo should we fire event here?
        emit mintEndedSupplyReduced(maxTokenSupply);
        return (maxTokenSupply);
    }

    function removeMintCombinationUnordered(uint256 _indexToRemove)
        public
        onlyOwner
    {
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

    function addSpecialApes() private {
        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    0,
                    9, //0 lefteyeIndex
                    9, //0 rightEyeIndex
                    0, //red eye color left
                    0
                ), //red eye color right
                "Zero the first ever minted 0 eyed ape #0",
                "#c7ba00" //banana yellow //todo: define another color?
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    11,
                    2, //♥
                    2, //♥
                    0, //red eye color
                    0
                ),
                "Harry the banana power love eyed ape #11",
                "#c7ba00" //banana yellow
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    3,
                    0,
                    0,
                    1, //eye color left
                    1
                ), //eye color right
                "Piu the golden empty eyed ape #3",
                "#ffd900" //golden
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    4,
                    12, //`
                    11, //´ -> leads to ` ´
                    0, //
                    0
                ),
                "ApeNorris the angry eyed rarest toughest mf ape #4",
                "#ff230a" //red
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    6,
                    9, //X
                    9, //X
                    2, //pink left eye
                    2
                ), //pink right eye
                "Carl the dead invisible ape #6",
                "#000000" //black->invisible
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    7,
                    7, //₿
                    7, //₿
                    1, //gold left eye
                    1
                ), //gold right eye
                "Satoshi the btc eyed ape #7",
                "#ff33cc" //pink
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    8,
                    8, //Ξ
                    8, //Ξ
                    2, //pink left eye
                    2
                ), //pink right eye
                "Vitalik the eth eyed ape #8",
                "#ffd900" //gold
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    9,
                    13,
                    13,
                    0, //red left eye
                    0
                ), //red right eye
                "Dollari the inflationary dollar eyed ape #9",
                "#ff0000" //red
            )
        );

        //Add special apes to max token supply
        maxTokenSupply += uint8(ast_specialApeDetails.length);
    }

    function totalSupply() public view returns (uint256) {
        return maxTokenSupply;
    }

    function genNameAndSymmetry(uint8 _tokenId)
        public
        view
        returns (bytes memory)
    {
        require(
            id_to_apeDefiningElements[_tokenId].apeNameIndex < 13 && /*gas optimized, not apeName.length used */
                id_to_apeDefiningElements[_tokenId].apeLeftEyeIndex < 14, /*gas optimized, not apeEyes.length used */
            "invalid index"
        );

        if (
            id_to_apeDefiningElements[_tokenId].specialApeIndex <=
            maxTokenSupply
        ) {
            //special ape
            return (
                abi.encodePacked(
                    ast_specialApeDetails[
                        id_to_apeDefiningElements[_tokenId].specialApeIndex
                    ].name,
                    '","attributes":[{"trait_type":"Facesymmetry","value":"',
                    "100"
                )
            );
        }

        string[13] memory apeNames = [
            "Arti",
            "Abu",
            "Aldo",
            "Bingo",
            "Krabs",
            "DC",
            "Groot",
            "Phaedrus",
            "D-Sasta",
            "Doxed",
            "Kinay",
            "Kodiak",
            "Cophi"
        ];

        string[14] memory apeEyeDescription = [
            "dead", //
            "blind", //█
            "heart", //♥
            "peek", //¬
            "wink", //˘
            "grin", //^
            "cross", //X
            "btc", //₿
            "eth", //Ξ
            "zero", //0
            "brow", //Ò
            "small", //´
            "small", //`
            "dollar" //$
        ];

        string memory eyePrefix;
        string memory faceSymmetry;
        if (
            id_to_apeDefiningElements[_tokenId].apeLeftEyeIndex ==
            id_to_apeDefiningElements[_tokenId].apeRightEyeIndex
        ) {
            eyePrefix = string(
                abi.encodePacked(
                    " the full ",
                    apeEyeDescription[
                        id_to_apeDefiningElements[_tokenId].apeLeftEyeIndex
                    ],
                    " eyed ascii ape"
                )
            );
            faceSymmetry = "100";
        } else {
            eyePrefix = string(
                abi.encodePacked(
                    " the half ",
                    apeEyeDescription[
                        id_to_apeDefiningElements[_tokenId].apeLeftEyeIndex
                    ],
                    " half ",
                    apeEyeDescription[
                        id_to_apeDefiningElements[_tokenId].apeRightEyeIndex
                    ],
                    " eyed ascii ape"
                )
            );
            faceSymmetry = "50";
        }

        return (
            abi.encodePacked(
                apeNames[id_to_apeDefiningElements[_tokenId].apeNameIndex],
                eyePrefix,
                " #",
                Strings.toString(_tokenId),
                '","attributes":[{"trait_type":"Facesymmetry","value":"',
                faceSymmetry
            )
        );
    }

    function generateSpecialApeSvg(
        uint8 _specialApeIndex,
        string memory textFillToEye
    ) private view returns (string memory) {
        string[3] memory eyeColor = ['ff1414">', 'ffd700">', 'ff33cc">']; //red, gold, pink

        //gen special ape, plain string
        return (
            Base64.encode(
                abi.encodePacked(
                    '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="',
                    ast_specialApeDetails[_specialApeIndex].apeColor, //use color of special ape
                    textFillToEye,
                    eyeColor[
                        ast_specialApeDetails[_specialApeIndex]
                            .apeCoreElements
                            .eyeColorIndexLeft
                    ],
                    apeEyes[
                        ast_specialApeDetails[_specialApeIndex]
                            .apeCoreElements
                            .eyeIndexLeft
                    ], //leftEye,
                    '</tspan>&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#',
                    eyeColor[
                        ast_specialApeDetails[_specialApeIndex]
                            .apeCoreElements
                            .eyeColorIndexRight
                    ],
                    apeEyes[
                        ast_specialApeDetails[_specialApeIndex]
                            .apeCoreElements
                            .eyeIndexRight
                    ], //rightEye,
                    svgEyeToEnd
                )
            )
        );
    }

    function generateApeSvg(uint8 _tokenId, string memory textFillToEye)
        private
        view
        returns (string memory)
    {
        string[3] memory eyeColor = ['ff1414">', 'ffd700">', 'ff33cc">']; //red, gold, pink

        return (
            Base64.encode(
                abi.encodePacked(
                    '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="', //start to textFill
                    "#ffffff",
                    textFillToEye, //text fill to eye
                    eyeColor[
                        id_to_apeDefiningElements[_tokenId].eyeColorIndexLeft
                    ],
                    apeEyes[
                        id_to_apeDefiningElements[_tokenId].apeLeftEyeIndex
                    ],
                    '</tspan>&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#',
                    eyeColor[
                        id_to_apeDefiningElements[_tokenId].eyeColorIndexRight
                    ],
                    apeEyes[
                        id_to_apeDefiningElements[_tokenId].apeRightEyeIndex
                    ],
                    svgEyeToEnd
                )
            )
        );
    }

    function registerApe(
        uint8 _specialApeIndex,
        uint8 _randomNumber,
        uint8 eyeColorIndexLeft,
        uint8 eyeColorIndexRight,
        uint8 tokenId,
        uint8 _apeNameIndex,
        uint8 bananascore
    ) public onlyOwner returns (bool) {
        //todo check if needed for gas optimizations, if fetched from nft contract, we wont need it here
        require(tokenId >= 0 && tokenId < maxTokenSupply, "invalid tokenId");
        id_to_apeDefiningElements[tokenId] = st_apeDefiningElements(
            _specialApeIndex,
            arrayOfAvailableMintCombinations[_randomNumber].apeLeftEyeIndex,
            arrayOfAvailableMintCombinations[_randomNumber].apeRightEyeIndex,
            eyeColorIndexLeft,
            eyeColorIndexRight,
            tokenId,
            _apeNameIndex,
            bananascore,
            true
        );
        return (true);
    }

    function getTokenURI(uint8 tokenId) public view returns (string memory) {
        //todo: no saving of any data at storage variables, simple string combining and returning
        //add functionality here, need to differ if we have special ape
        require(
            id_to_apeDefiningElements[tokenId].isRegistered,
            "invalid tokenId"
        ); //ape not registered/minted or tokenId invalid
        string
            memory textFillToEye = '" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="39.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';

        if (
            id_to_apeDefiningElements[tokenId].specialApeIndex <= maxTokenSupply
        ) {
            //special ape

            return (
                string(
                    abi.encodePacked(
                        "data:application/json;base64,",
                        Base64.encode(
                            abi.encodePacked(
                                '{"description":"Fully onchain generated AsciiApe","image":"data:image/svg+xml;base64,',
                                generateSpecialApeSvg(
                                    id_to_apeDefiningElements[tokenId]
                                        .specialApeIndex,
                                    textFillToEye
                                ),
                                apeAttributes(tokenId) //todo need to differ between standard and special ape
                            )
                        )
                    )
                )
            );
        } else {
            return (
                string(
                    abi.encodePacked(
                        "data:application/json;base64,",
                        Base64.encode(
                            abi.encodePacked(
                                '{"description":"Fully onchain generated AsciiApe","image":"data:image/svg+xml;base64,',
                                generateApeSvg(tokenId, textFillToEye),
                                apeAttributes(tokenId) //todo need to differ between standard and special ape
                            )
                        )
                    )
                )
            );
        }
    }

    function apeAttributes(uint8 _tokenId) public view returns (bytes memory) {
        bytes memory nameAndSymmetry; //todo check if bytes is better or string, cause name of special ape is converted to bytes 7 lines under this
        string memory apeColor;
        if (
            id_to_apeDefiningElements[_tokenId].specialApeIndex <=
            maxTokenSupply
        ) {
            //special ape
            apeColor = ast_specialApeDetails[
                id_to_apeDefiningElements[_tokenId].specialApeIndex
            ].apeColor;
        } else {
            apeColor = "#ffffff";
        }
        nameAndSymmetry = genNameAndSymmetry(_tokenId);

        string[3] memory eyeColor = ["#ff1414", "#ffd700", "#ff33cc"]; //red, gold, pink
        return (
            abi.encodePacked(
                '","name":"',
                nameAndSymmetry,
                '"},{"trait_type":"EyeLeft","value":"',
                apeEyes[id_to_apeDefiningElements[_tokenId].apeLeftEyeIndex], //eye left value
                '"},{"trait_type":"EyeRight","value":"',
                apeEyes[id_to_apeDefiningElements[_tokenId].apeRightEyeIndex], //eye right value
                //todo: add bananascore value
                '"},{"trait_type":"EyeColorLeft","value":"',
                eyeColor[id_to_apeDefiningElements[_tokenId].eyeColorIndexLeft], //left eye color
                '"},{"trait_type":"EyeColorRight","value":"',
                eyeColor[
                    id_to_apeDefiningElements[_tokenId].eyeColorIndexRight
                ], //left eye color
                '"},{"trait_type":"ApeColor","value":"',
                apeColor,
                '"},{"trait_type":"BananaScore","value":"',
                Strings.toString(22), //todo: add bananascore value by random generation
                '"}]}'
            )
        );
    }

    /*
    function generateAndRegisterApe(
        uint8 _specialApeIndex,
        uint8 _randomNumber,
        uint8 eyeColorIndexLeft,
        uint8 eyeColorIndexRight,
        uint8 tokenId,
        uint8 _apeNameIndex,
        uint8 bananascore
    ) public onlyOwner returns (bool) {
        st_apeDetails memory newApe;

        string
            memory textFillToEye = '" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="39.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';

        st_apeGenAndRegisterDetails memory _apeGenAndRegisterDetails;
        //svg creation + name
        if (_randomNumber == 0) {
            newApe.base64EncodedSvg = generateSpecialApeSvg(
                _specialApeIndex,
                textFillToEye
            );

            _apeGenAndRegisterDetails = st_apeGenAndRegisterDetails(
                ast_specialApeDetails[_specialApeIndex].apeCoreElements,
                bananascore,
                _specialApeIndex
            );

            //metadata todo: 1. reduce code by tmp var with indexes?
            id_to_apeDetails[tokenId] = newApe; //store it because metdata accesses it
            id_to_apeDetails[tokenId].metaData = buildTokenURI(
                _apeGenAndRegisterDetails,
                ast_specialApeDetails[_specialApeIndex].name
            );
        } else {
            newApe.base64EncodedSvg = generateApeSvg(
                eyeColorIndexLeft,
                eyeColorIndexRight,
                _randomNumber,
                textFillToEye
            );

            _apeGenAndRegisterDetails = st_apeGenAndRegisterDetails(
                st_apeCoreElements(
                    tokenId,
                    arrayOfAvailableMintCombinations[_randomNumber]
                        .apeLeftEyeIndex,
                    arrayOfAvailableMintCombinations[_randomNumber]
                        .apeRightEyeIndex,
                    eyeColorIndexLeft,
                    eyeColorIndexRight
                ),
                bananascore,
                255
            );

            //metadata
            id_to_apeDetails[tokenId] = newApe;
            id_to_apeDetails[tokenId].metaData = buildTokenURI(
                _apeGenAndRegisterDetails,
                generateApeName(
                    _apeNameIndex,
                    arrayOfAvailableMintCombinations[_randomNumber]
                        .apeLeftEyeIndex,
                    arrayOfAvailableMintCombinations[_randomNumber]
                        .apeRightEyeIndex,
                    tokenId
                )
            );
        }

        require(
            bytes(id_to_apeDetails[tokenId].metaData).length > 0,
            "metadata gen fail"
        );
        //generated and registered
        return (true);
    }*/

    //lets register it first
    function registerToken(uint8 tokenId) public onlyOwner returns (bool) {}

    function buildTokenURI(
        st_apeGenAndRegisterDetails memory _apeGenAndRegisterDetails,
        string memory _apeName
    ) public view returns (string memory) {
        //build, register token
        string memory faceSymmetry;
        if (
            _apeGenAndRegisterDetails.apeCoreElements.eyeIndexLeft ==
            _apeGenAndRegisterDetails.apeCoreElements.eyeIndexRight
        ) {
            faceSymmetry = "100";
        } else {
            faceSymmetry = "50";
        }

        string[3] memory eyeColor = ["#ff1414", "#ffd700", "#ff33cc"]; //red, gold, pink
        string memory apeColor;

        if (_apeGenAndRegisterDetails.specialApeIndex == 255) {
            apeColor = "#ffffff";
        } else {
            apeColor = ast_specialApeDetails[
                _apeGenAndRegisterDetails.specialApeIndex
            ].apeColor;
        }

        return (
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"description":"Fully onchain generated AsciiApe","image":"data:image/svg+xml;base64,',
                                id_to_apeDetails[
                                    _apeGenAndRegisterDetails
                                        .apeCoreElements
                                        .tokenId
                                ].base64EncodedSvg,
                                '","name":"',
                                _apeName,
                                '","attributes":[{"trait_type":"Facesymmetry","value":"',
                                faceSymmetry,
                                '"},{"trait_type":"EyeLeft","value":"',
                                apeEyes[
                                    _apeGenAndRegisterDetails
                                        .apeCoreElements
                                        .eyeIndexLeft
                                ], //eye left value
                                '"},{"trait_type":"EyeRight","value":"',
                                apeEyes[
                                    _apeGenAndRegisterDetails
                                        .apeCoreElements
                                        .eyeIndexRight
                                ], //eye right value
                                //todo: add bananascore value
                                '"},{"trait_type":"EyeColorLeft","value":"',
                                eyeColor[
                                    _apeGenAndRegisterDetails
                                        .apeCoreElements
                                        .eyeColorIndexLeft
                                ], //left eye color
                                '"},{"trait_type":"EyeColorRight","value":"',
                                eyeColor[
                                    _apeGenAndRegisterDetails
                                        .apeCoreElements
                                        .eyeColorIndexRight
                                ], //left eye color
                                '"},{"trait_type":"ApeColor","value":"',
                                apeColor,
                                '"},{"trait_type":"BananaScore","value":"',
                                Strings.toString(
                                    _apeGenAndRegisterDetails.bananascore
                                ),
                                '"}]}'
                            )
                        )
                    )
                )
            )
        );
    }
    /*
    function getTokenURI(uint8 tokenId) public view returns (string memory) {
        return id_to_apeDetails[tokenId].metaData;
    }
    */
}
