const helpfulScript = require("./helpful_script.js");



exports.deployMintContractsWithAccessControl = async function (_mintPrice) {

    const apeGenerator = await helpfulScript.deployApeGenerator();
    const accessControl = await helpfulScript.deployAccessControl();
    const nftContract = await helpfulScript.deployNftMintContract(apeGenerator.address, accessControl.address, _mintPrice); //mint price set to 1e15 = 1 finney = 0.001 eth

    return ([apeGenerator, accessControl, nftContract]);
}