// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

//ToDo: should only AsciiApes contract be able to call this?

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
        uint8 tokenId;
        uint8 eyeIndexLeft;
        uint8 eyeIndexRight;
        uint8 eyeColorIndexLeft;
        uint8 eyeColorIndexRight;
        uint8 bananascore;
        uint8 specialApeIndex;
    }

    struct mintCombination {
        uint8 apeLeftEyeIndex;
        uint8 apeRightEyeIndex;
    }

    struct st_apeDetails {
        string metaData;
        string name;
        string base64EncodedSvg;
    }

    struct st_ApeCoreElements {
        uint8 tokenId;
        string name;
        uint8 leftEyeIndex;
        uint8 rightEyeIndex;
        uint8 eyeColorLeft;
        uint8 eyeColorRight;
        string apeColor;
    }

    mapping(uint256 => st_apeDetails) id_to_apeDetails;

    //special ape
    st_ApeCoreElements[] ast_specialApeDetails;

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
                ast_specialApeDetails[currentActiveSpecialApeIndex].tokenId ==
                tokenId
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
            st_ApeCoreElements(
                0,
                "Zero the first ever minted 0 eyed ape #0",
                9, //0 lefteyeIndex
                9, //0 rightEyeIndex
                0, //red eye color left
                0, //red eye color right
                "#c7ba00" //banana yellow //todo: define another color?
            )
        );

        ast_specialApeDetails.push(
            st_ApeCoreElements(
                11,
                "Harry the banana power love eyed ape #11",
                2, //♥
                2, //♥
                0, //red eye color
                0,
                "#c7ba00" //banana yellow
            )
        );

        ast_specialApeDetails.push(
            st_ApeCoreElements(
                3,
                "Piu the golden empty eyed ape #3",
                0,
                0,
                1, //eye color left
                1, //eye color right
                "#ffd900" //golden
            )
        );

        ast_specialApeDetails.push(
            st_ApeCoreElements(
                4,
                "ApeNorris the angry eyed rarest toughest mf ape #4",
                12, //`
                11, //´ -> leads to ` ´
                0, //
                0,
                "#ff230a" //red
            )
        );

        ast_specialApeDetails.push(
            st_ApeCoreElements(
                6,
                "Carl the dead invisible ape #6",
                9, //X
                9, //X
                2, //pink left eye
                2, //pink right eye
                "#000000" //black->invisible
            )
        );

        ast_specialApeDetails.push(
            st_ApeCoreElements(
                7,
                "Satoshi the btc eyed ape #7",
                7, //₿
                7, //₿
                1, //gold left eye
                1, //gold right eye
                "#ff33cc" //pink
            )
        );

        ast_specialApeDetails.push(
            st_ApeCoreElements(
                8,
                "Vitalik the eth eyed ape #8",
                8, //Ξ
                8, //Ξ
                2, //pink left eye
                2, //pink right eye
                "#ffd900" //gold
            )
        );

        ast_specialApeDetails.push(
            st_ApeCoreElements(
                9,
                "Dollari the inflationary dollar eyed ape #9",
                13,
                13,
                0, //red left eye
                0, //red right eye
                "#ff0000" //red
            )
        );

        //Add special apes to max token supply
        maxTokenSupply += uint8(ast_specialApeDetails.length);
    }

    function totalSupply() public view returns (uint256) {
        return maxTokenSupply;
    }

    function generateApeName(
        uint8 _apeNameIndex,
        uint8 _leftEyeIndex,
        uint8 _rightEyeIndex,
        uint8 tokenId
    ) public pure returns (string memory generatedApeName) {
        require(
            _apeNameIndex < 13 && /*gas optimized, not apeName.length used */
                _leftEyeIndex < 14, /*gas optimized, not apeEyes.length used */
            "invalid index"
        );

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

        if (_leftEyeIndex == _rightEyeIndex) {
            eyePrefix = string(
                abi.encodePacked(
                    " the full ",
                    apeEyeDescription[_leftEyeIndex],
                    " eyed ascii ape"
                )
            );
        } else {
            eyePrefix = string(
                abi.encodePacked(
                    " the half ",
                    apeEyeDescription[_leftEyeIndex],
                    " half ",
                    apeEyeDescription[_rightEyeIndex],
                    " eyed ascii ape"
                )
            );
        }

        return (
            string(
                abi.encodePacked(
                    apeNames[_apeNameIndex],
                    eyePrefix,
                    " #",
                    Strings.toString(tokenId)
                )
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
                        ast_specialApeDetails[_specialApeIndex].eyeColorLeft
                    ],
                    apeEyes[
                        ast_specialApeDetails[_specialApeIndex].leftEyeIndex
                    ], //leftEye,
                    '</tspan>&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#',
                    eyeColor[
                        ast_specialApeDetails[_specialApeIndex].eyeColorLeft
                    ],
                    apeEyes[
                        ast_specialApeDetails[_specialApeIndex].rightEyeIndex
                    ], //rightEye,
                    svgEyeToEnd
                )
            )
        );
    }

    function generateApeSvg(
        uint8 eyeColorIndexLeft,
        uint8 eyeColorIndexRight,
        uint8 _randomNumber,
        string memory textFillToEye
    ) private view returns (string memory) {
        string[3] memory eyeColor = ['ff1414">', 'ffd700">', 'ff33cc">']; //red, gold, pink

        return (
            Base64.encode(
                abi.encodePacked(
                    '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="', //start to textFill
                    "#ffffff",
                    textFillToEye, //text fill to eye
                    eyeColor[eyeColorIndexLeft],
                    apeEyes[
                        arrayOfAvailableMintCombinations[_randomNumber]
                            .apeLeftEyeIndex
                    ],
                    '</tspan>&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#',
                    eyeColor[eyeColorIndexRight],
                    apeEyes[
                        arrayOfAvailableMintCombinations[_randomNumber]
                            .apeRightEyeIndex
                    ],
                    svgEyeToEnd
                )
            )
        );
    }

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
                tokenId,
                ast_specialApeDetails[_specialApeIndex].leftEyeIndex,
                ast_specialApeDetails[_specialApeIndex].rightEyeIndex,
                ast_specialApeDetails[_specialApeIndex].eyeColorLeft,
                ast_specialApeDetails[_specialApeIndex].eyeColorRight,
                bananascore,
                _specialApeIndex
            );

            newApe.name = ast_specialApeDetails[_specialApeIndex].name;
            //metadata todo: 1. reduce code by tmp var with indexes?
            id_to_apeDetails[tokenId] = newApe; //store it because metdata accesses it
            id_to_apeDetails[tokenId].metaData = buildTokenURI(
                _apeGenAndRegisterDetails
            );
        } else {
            newApe.base64EncodedSvg = generateApeSvg(
                eyeColorIndexLeft,
                eyeColorIndexRight,
                _randomNumber,
                textFillToEye
            );

            _apeGenAndRegisterDetails = st_apeGenAndRegisterDetails(
                tokenId,
                arrayOfAvailableMintCombinations[_randomNumber].apeLeftEyeIndex,
                arrayOfAvailableMintCombinations[_randomNumber]
                    .apeRightEyeIndex,
                eyeColorIndexLeft,
                eyeColorIndexRight,
                bananascore,
                255
            );
            newApe.name = generateApeName(
                _apeNameIndex,
                arrayOfAvailableMintCombinations[_randomNumber].apeLeftEyeIndex,
                arrayOfAvailableMintCombinations[_randomNumber]
                    .apeRightEyeIndex,
                tokenId
            );
            //metadata
            id_to_apeDetails[tokenId] = newApe;
            id_to_apeDetails[tokenId].metaData = buildTokenURI(
                _apeGenAndRegisterDetails
            );
        }

        require(
            bytes(id_to_apeDetails[tokenId].metaData).length > 0,
            "metadata gen fail"
        );
        //register new ape
        return (true);
    }

    //lets register it first
    function registerToken(uint8 tokenId) public onlyOwner returns (bool) {}

    function buildTokenURI(
        st_apeGenAndRegisterDetails memory _apeGenAndRegisterDetails
    ) public view returns (string memory) {
        //build, register token
        string memory faceSymmetry;
        if (
            _apeGenAndRegisterDetails.eyeIndexLeft ==
            _apeGenAndRegisterDetails.eyeIndexRight
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
                                    _apeGenAndRegisterDetails.tokenId
                                ].base64EncodedSvg,
                                '","name":"',
                                id_to_apeDetails[
                                    _apeGenAndRegisterDetails.tokenId
                                ].name,
                                '","attributes":[{"trait_type":"Facesymmetry","value":"',
                                faceSymmetry,
                                '"},{"trait_type":"EyeLeft","value":"',
                                apeEyes[_apeGenAndRegisterDetails.eyeIndexLeft], //eye left value
                                '"},{"trait_type":"EyeRight","value":"',
                                apeEyes[
                                    _apeGenAndRegisterDetails.eyeIndexRight
                                ], //eye right value
                                //todo: add bananascore value
                                '"},{"trait_type":"EyeColorLeft","value":"',
                                eyeColor[
                                    _apeGenAndRegisterDetails.eyeColorIndexLeft
                                ], //left eye color
                                '"},{"trait_type":"EyeColorRight","value":"',
                                eyeColor[
                                    _apeGenAndRegisterDetails.eyeColorIndexRight
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

    function getTokenURI(uint8 tokenId) public view returns (string memory) {
        return id_to_apeDetails[tokenId].metaData;
    }
}
