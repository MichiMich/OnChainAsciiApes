// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

//ToDo: should only AsciiApes contract be able to call this?
//todo the names of the special apes must fit with their index (#1) for example needs index 1, would be possible to do this by ApeGenerator as well

contract ApeGenerator is Ownable {
    //default svg data

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

    struct st_apeCoreElements {
        uint8 tokenId;
        uint8 eyeIndexLeft;
        uint8 eyeIndexRight;
        uint8 eyeColorIndexLeft;
        uint8 eyeColorIndexRight;
    }

    struct st_apeDefiningElements {
        uint8 specialApeIndex; //in range 0-maxTokenSupply=special ape, maxTokenSupply + 1 = regular ape
        uint8 eyeIndexLeft;
        uint8 eyeIndexRight;
        uint8 eyeColorIndexLeft;
        uint8 eyeColorIndexRight;
        uint8 tokenId;
        uint8 apeNameIndex;
        uint8 bananascore; //value between 60-100 with random gen value
    }

    struct mintCombination {
        uint8 eyeIndexLeft;
        uint8 eyeIndexRight;
    }

    struct st_SpecialApe {
        st_apeCoreElements apeCoreElements;
        string name;
        string apeColor;
    }

    //holds all data which is needed to get the ape svg data
    mapping(uint256 => st_apeDefiningElements) id_to_apeDefiningElements;

    //special ape
    st_SpecialApe[] ast_specialApeDetails;

    uint8 private maxTokenSupply;
    bool mintWasReduced;

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

    //todo this needs to be adapted with the 3 left special apes for the top3 donators, could be enough to set the limit to currentvalue -3, add bool to overwrite even that as well if donators dont take them, could be
    //avoided by letting owner take them and deliver them
    function endMintReduceTotalSupply(uint8 _TokensAlreadyMinted)
        public
        onlyOwner
        returns (uint8)
    {
        require(!mintWasReduced);
        //reducing the total supply leads to 0 nfts left->fires require statement
        maxTokenSupply = _TokensAlreadyMinted + 3; //+3 = leave 3 apes for the top3 donators, they need to be delivered
        //need to set the last 3 special apes to the next 3 tokenIds because they are reserved for the top3Donators
        uint256 nrOfExistingSpecialApes = ast_specialApeDetails.length;
        for (uint8 i = 1; i <= 3; i++) {
            ast_specialApeDetails[nrOfExistingSpecialApes - i]
                .apeCoreElements
                .tokenId = maxTokenSupply - i;
        }
        emit mintEndedSupplyReduced(maxTokenSupply);
        mintWasReduced = true;
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
                "#6fd1c4" //downy colored
            )
        );

        //ice ape #00bdc7
        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    40, //todo adapt when he should appear
                    5, //^
                    5, //^
                    0, //red eye color
                    0
                ),
                "Icy the glowing happy eyed frozen ape #40",
                "#00bdc7" //ice blue
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    80,
                    2, //♥
                    2, //♥
                    0, //red eye color
                    0
                ),
                "Harry the banana power love eyed ape #80",
                "#c7ba00" //banana yellow
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    120,
                    0,
                    0,
                    1, //eye color left
                    1
                ), //eye color right
                "Piu the golden empty eyed ape #120",
                "#ffd900" //golden
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    160,
                    12, //`
                    11, //´ -> leads to ` ´
                    0, //
                    0
                ),
                "ApeNorris the angry eyed rarest toughest mf ape #160",
                "#ff230a" //red
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    201,
                    9, //X
                    9, //X
                    2, //pink left eye
                    2
                ), //pink right eye
                "Carl the dead invisible ape #201",
                "#000000" //black->invisible
            )
        );
        //last 3 special apes, mintable only from top3 donators
        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    202,
                    7, //₿
                    7, //₿
                    1, //gold left eye
                    1
                ), //gold right eye
                "Satoshi the btc eyed ape #202",
                "#ff33cc" //pink
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    203,
                    8, //Ξ
                    8, //Ξ
                    2, //pink left eye
                    2
                ), //pink right eye
                "Vitalik the eth eyed ape #203",
                "#ffd900" //gold
            )
        );

        ast_specialApeDetails.push(
            st_SpecialApe(
                st_apeCoreElements(
                    204,
                    13,
                    13,
                    0, //red left eye
                    0
                ), //red right eye
                "Dollari the inflationary dollar eyed ape #204",
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
                id_to_apeDefiningElements[_tokenId].eyeIndexLeft < 14, /*gas optimized, not apeEyes.length used */
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
            id_to_apeDefiningElements[_tokenId].eyeIndexLeft ==
            id_to_apeDefiningElements[_tokenId].eyeIndexRight
        ) {
            eyePrefix = string(
                abi.encodePacked(
                    " the full ",
                    apeEyeDescription[
                        id_to_apeDefiningElements[_tokenId].eyeIndexLeft
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
                        id_to_apeDefiningElements[_tokenId].eyeIndexLeft
                    ],
                    " half ",
                    apeEyeDescription[
                        id_to_apeDefiningElements[_tokenId].eyeIndexRight
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
                    apeEyes[id_to_apeDefiningElements[_tokenId].eyeIndexLeft],
                    '</tspan>&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#',
                    eyeColor[
                        id_to_apeDefiningElements[_tokenId].eyeColorIndexRight
                    ],
                    apeEyes[id_to_apeDefiningElements[_tokenId].eyeIndexRight],
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
        if (_specialApeIndex <= maxTokenSupply) {
            //special ape
            id_to_apeDefiningElements[tokenId] = st_apeDefiningElements(
                _specialApeIndex,
                0,
                0,
                0,
                0,
                tokenId,
                0,
                bananascore
            );
        } else {
            id_to_apeDefiningElements[tokenId] = st_apeDefiningElements(
                _specialApeIndex,
                arrayOfAvailableMintCombinations[_randomNumber].eyeIndexLeft,
                arrayOfAvailableMintCombinations[_randomNumber].eyeIndexRight,
                eyeColorIndexLeft,
                eyeColorIndexRight,
                tokenId,
                _apeNameIndex,
                bananascore
            );
        }
        return (true);
    }

    function getTokenURI(uint8 tokenId) public view returns (string memory) {
        require(
            id_to_apeDefiningElements[tokenId].bananascore != 0,
            "invalid tokenId"
        ); //ape not registered/minted or tokenId invalid
        string
            memory textFillToEye = '" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="39.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';

        string memory generatedApeSvg;
        if (
            id_to_apeDefiningElements[tokenId].specialApeIndex <= maxTokenSupply
        ) {
            //special ape
            generatedApeSvg = generateSpecialApeSvg(
                id_to_apeDefiningElements[tokenId].specialApeIndex,
                textFillToEye
            );
        } else {
            generatedApeSvg = generateApeSvg(tokenId, textFillToEye);
        }
        return (
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{"description":"Fully onchain generated AsciiApe","image":"data:image/svg+xml;base64,',
                            generatedApeSvg,
                            apeAttributes(tokenId)
                        )
                    )
                )
            )
        );
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
                apeEyes[id_to_apeDefiningElements[_tokenId].eyeIndexLeft], //eye left value
                '"},{"trait_type":"EyeRight","value":"',
                apeEyes[id_to_apeDefiningElements[_tokenId].eyeIndexRight], //eye right value
                '"},{"trait_type":"EyeColorLeft","value":"',
                eyeColor[id_to_apeDefiningElements[_tokenId].eyeColorIndexLeft], //left eye color
                '"},{"trait_type":"EyeColorRight","value":"',
                eyeColor[
                    id_to_apeDefiningElements[_tokenId].eyeColorIndexRight
                ], //left eye color
                '"},{"trait_type":"ApeColor","value":"',
                apeColor,
                '"},{"trait_type":"BananaScore","value":"',
                Strings.toString(
                    id_to_apeDefiningElements[_tokenId].bananascore
                ),
                '"}]}'
            )
        );
    }
}
