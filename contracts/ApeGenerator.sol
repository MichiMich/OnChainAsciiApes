// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

//ToDo: should only AsciiApes contract be able to call this?

contract ApeGenerator is Ownable {
    //default svg data
    string private constant svgStartToTextFill =
        '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="';

    string private constant svgTextFillToEye =
        '" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="39.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';
    //'" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;</tspan><tspan x="39.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;</tspan><tspan x="35.75" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';

    // string private constant svgStartToEye =
    //     '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="white" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="39.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';
    // //'<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect height="500" width="500" fill="black"/><text y="10%" fill="white" text-anchor="start" font-size="18" xml:space="preserve" font-family="monospace"><tspan x="43.75%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';

    string private constant svgEyeToEye =
        '</tspan>&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;<tspan fill="#';

    string private constant svgEyeToEnd =
        '</tspan>&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="31.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="35.75%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="12%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="8%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#xd;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#xd;</tspan><tspan x="8%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#xd;</tspan><tspan x="12%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#xd;</tspan><tspan x="32%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="28%" dy="1.2em">&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#xd;</tspan><tspan x="28%" dy="1.2em">&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;</tspan></text></svg>';
    //'</tspan>&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="31.75%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="35.75%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="12%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="8%" dy="1.2em">&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;</tspan><tspan x="4%" dy="1.2em">&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;</tspan><tspan x="8%" dy="1.2em">&#x20;&#x20;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;</tspan><tspan x="12" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x2593;&#x2593;&#x2593;&#x2593;&#x2588;&#x2588;&#x20;&#x20;&#x20;&#x20;</tspan><tspan x="32%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2593;&#x2593;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="28%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;&#x2591;&#x2591;&#x2591;&#x2591;&#x2588;&#x2588;</tspan><tspan x="28%" dy="1.2em">&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x20;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;&#x2588;</tspan></text></svg>';

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

    //todo need to update eye description
    string[14] apeEyeDescription = [
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

    string[] eyeColor = ['ff1414">', 'ffd700">', 'ff33cc">']; //red, gold, pink

    //fully onchain generated AsciiApes
    //available names for random linking during mint
    string[13] apeNames = [
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

    struct mintCombination {
        uint8 apeLeftEye;
        uint8 apeRightEye;
    }
    //dynamical array, will created by constructor and elements deleted after mint
    mintCombination[] arrayOfAvailableMintCombinations;

    mapping(uint256 => st_apeDetails) id_to_apeDetails;

    struct st_apeDetails {
        string metaData;
        string name;
        /*
                //metadataElements
        uint8 EyeIndexLeft;
        uint8 EyeIndexRight;
        uint8 EyeColorIndexLeft;
        uint8 EyeColorIndexRight;
        uint8 ApeColorIndex;
        */
        //string svg; //not needed, base64 encoded svg holds data
        string base64EncodedSvg;
        /*string leftEye;
        string rightEye;
        string symmetry;
        string[3] bananascore;
        */
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

    //special ape
    st_ApeCoreElements[] ast_specialApeDetails;

    uint8 private maxTokenSupply;

    constructor() {
        defineMintCombinations();
        addSpecialApes();
    }

    function nrOfSpecialApes() public view returns (uint256) {
        return ast_specialApeDetails.length;
    }

    //this will cost gas, because of our counter
    function getSpecialApeIndex(uint8 _tokenId) public view returns (uint8) {
        for (
            uint8 currentActiveSpecialApeIndex = 0;
            currentActiveSpecialApeIndex < ast_specialApeDetails.length;
            currentActiveSpecialApeIndex++
        ) {
            if (
                ast_specialApeDetails[currentActiveSpecialApeIndex].tokenId ==
                _tokenId
            ) {
                //we want to create an special ape now, we return the index of the ape
                return (currentActiveSpecialApeIndex);
            }
        }
        return (maxTokenSupply + 1);

        //this avoids gas, because we dont need to change a value of a counter
        //on a programmatic point of view it should be done with for loop
        //the deployment would cost more gas if a lot of special apes
        /*
        if (
            ast_specialApeDetails[0].tokenId == givenTokenID ||
            ast_specialApeDetails[1].tokenId == givenTokenID ||
            putotherIndizesHereAsWell
        ) {
            return true;
        }
        */
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

    function removeMintCombinationUnordered(uint256 _indexToRemove)
        public
        onlyOwner
    {
        console.log("wanted index to remove", _indexToRemove);
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
        console.log(
            "left mint combionations",
            arrayOfAvailableMintCombinations.length
        );
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
                "Vitalik the ethereum eyed ape #8",
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
        uint8 _tokenId
    ) private returns (string memory generatedApeName) {
        require(_apeNameIndex < apeNames.length, "name index out of range");
        require(
            _leftEyeIndex < apeEyeDescription.length,
            "eye index out of range"
        );
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
                    Strings.toString(_tokenId)
                )
            )
        );
    }

    function getLengthOfApeNamesArray() public view returns (uint8) {
        return uint8(apeNames.length);
    }

    function generateSpecialApeSvg(uint8 _specialApeIndex)
        private
        view
        returns (string memory)
    {
        //gen special ape, plain string
        return (
            Base64.encode(
                abi.encodePacked(
                    svgStartToTextFill,
                    ast_specialApeDetails[_specialApeIndex].apeColor, //use color of special ape
                    svgTextFillToEye,
                    eyeColor[
                        ast_specialApeDetails[_specialApeIndex].eyeColorLeft
                    ],
                    apeEyes[
                        ast_specialApeDetails[_specialApeIndex].leftEyeIndex
                    ], //leftEye,
                    svgEyeToEye,
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
        uint8 _eyeColorIndexLeft,
        uint8 _eyeColorIndexRight,
        uint8 _randomNumber
    ) private view returns (string memory) {
        return (
            Base64.encode(
                abi.encodePacked(
                    svgStartToTextFill,
                    "white",
                    svgTextFillToEye,
                    eyeColor[_eyeColorIndexLeft],
                    apeEyes[
                        arrayOfAvailableMintCombinations[_randomNumber]
                            .apeLeftEye
                    ],
                    svgEyeToEye,
                    eyeColor[_eyeColorIndexRight],
                    apeEyes[
                        arrayOfAvailableMintCombinations[_randomNumber]
                            .apeRightEye
                    ],
                    svgEyeToEnd
                )
            )
        );
    }

    function generateAndRegisterApe(
        uint8 _specialApeIndex,
        uint8 _randomNumber,
        uint8 _eyeColorIndexLeft,
        uint8 _eyeColorIndexRight,
        uint8 _tokenId,
        uint8 _apeNameIndex
    ) public onlyOwner returns (bool) {
        st_apeDetails memory newApe;
        console.log("\n###generateAndRegisterApe for tokenID: ", _tokenId);
        //svg creation + name
        if (_randomNumber == 0) {
            console.log(
                "\nspecial ape wanted, name: ",
                ast_specialApeDetails[_specialApeIndex].name
            );
            newApe.base64EncodedSvg = generateSpecialApeSvg(_specialApeIndex);
            newApe.name = ast_specialApeDetails[_specialApeIndex].name;
            //metadata todo: 1. reduce code by tmp var with indexes?
            id_to_apeDetails[_tokenId] = newApe; //store it because metdata accesses it
            id_to_apeDetails[_tokenId].metaData = buildTokenURI(
                _tokenId,
                ast_specialApeDetails[_specialApeIndex].leftEyeIndex,
                ast_specialApeDetails[_specialApeIndex].rightEyeIndex,
                ast_specialApeDetails[_specialApeIndex].eyeColorLeft,
                ast_specialApeDetails[_specialApeIndex].eyeColorRight,
                substring(
                    ast_specialApeDetails[_specialApeIndex].apeColor,
                    1,
                    7
                )
            );
        } else {
            newApe.base64EncodedSvg = generateApeSvg(
                _eyeColorIndexLeft,
                _eyeColorIndexRight,
                _randomNumber
            );
            newApe.name = generateApeName(
                _apeNameIndex,
                arrayOfAvailableMintCombinations[_randomNumber].apeLeftEye,
                arrayOfAvailableMintCombinations[_randomNumber].apeRightEye,
                _tokenId
            );
            //metadata
            id_to_apeDetails[_tokenId] = newApe;
            id_to_apeDetails[_tokenId].metaData = buildTokenURI(
                _tokenId,
                arrayOfAvailableMintCombinations[_randomNumber].apeLeftEye,
                arrayOfAvailableMintCombinations[_randomNumber].apeRightEye,
                _eyeColorIndexLeft,
                _eyeColorIndexRight,
                "white"
            );
        }

        require(
            bytes(id_to_apeDetails[_tokenId].metaData).length > 0,
            "metadata gen failed"
        );
        //register new ape
        return (true);
    }

    //lets register it first
    function registerToken(uint8 _tokenId) public onlyOwner returns (bool) {}

    function buildTokenURI(
        uint8 _tokenId, /*fro svg and generated name*/
        uint8 _leftEyeIndex,
        uint8 _rightEyeIndex,
        uint8 _eyeColorIndexLeft,
        uint8 _eyeColorIndexRight,
        string memory _apeColor
    ) private returns (string memory) {
        //build, register token
        console.log("\n\nbuildTokenUri triggered");
        string memory faceSymmetry;
        if (_leftEyeIndex == _rightEyeIndex) {
            faceSymmetry = "100";
        } else {
            faceSymmetry = "50";
        }

        return (
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"description":"Fully onchain generated AsciiApe","image":"data:image/svg+xml;base64,',
                                id_to_apeDetails[_tokenId].base64EncodedSvg,
                                '","name":"',
                                id_to_apeDetails[_tokenId].name,
                                '","attributes":[{"trait_type":"Facesymmetry","value":"',
                                faceSymmetry,
                                '"},{"trait_type":"EyeLeft","value":"',
                                apeEyes[_leftEyeIndex], //eye left value
                                '"},{"trait_type":"EyeRight","value":"',
                                apeEyes[_rightEyeIndex], //eye right value
                                //todo: add bananascore value
                                '"},{"trait_type":"EyeColorLeft","value":"',
                                substring(eyeColor[_eyeColorIndexLeft], 0, 6), //left eye color
                                '"},{"trait_type":"EyeColorRight","value":"',
                                substring(eyeColor[_eyeColorIndexRight], 0, 6), //left eye color
                                '"},{"trait_type":"ApeColor","value":"',
                                _apeColor,
                                '"}]}'
                            )
                        )
                    )
                )
            )
        );
    }

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function getTokenURI(uint8 _tokenId) public view returns (string memory) {
        return id_to_apeDetails[_tokenId].metaData;
    }
}
