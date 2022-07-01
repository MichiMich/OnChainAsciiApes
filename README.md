# OnChainAscii Apes
Fully onchain generated nft project, deployed on the eth chain.
![OnChainAsciiApes](https://github.com/MichiMich/FilesForInstructions/blob/main/OCAA/OnChainAsciiApesFullyOnChainGenerated.gif)

## Project properties:
- 204 Apes in total, 9 special apes
- onchain svg generation during mint
- "random" nft assigment during mint
- "random" nft name assigment during mint

The "random" factor is created by combining the wallet address of the minter with the last block number, the timestamp and the previous generated "random" number. 
In addition, the created "random" number for the nft generation is the index at an unorganized array. This array carries the nft properties like left and right eye and will be removed after mint to secure a once only occuring nft generation (every nft combination is unique).

This is not a truly random generated number, which could be archieved by using chainlink vrf for example.
This servers as an approach of various, not incremental assignments during mint, which is sufficient.


## Additional contracts
The main contract "OnChainAsciiApes" is linked to 2 additional contracts

### ApeGenerator
The ApeGenerator contract holds all nft generation specific values like generel svg data, mint combinations, hex unicode data for the ape eyes, ape eye colors and general ape color. It is used for creating and registering an ape by storing the data in a nft attributes - tokenId mapping. 
Furthermore it holds all data for querying the tokenURI of a given tokenId.

### AccessUnitControl
Basically the function of the AccessUnitControl contract could be found [here](https://github.com/MichiMich/AccessUnitControl).

In this case the AccessUnitcontrol contract is used to secure the last 3 nfts (which are special apes) for certain wallet addresses only.

The wallet addresses allowed for minting them are given by the top 3 donators at the [donation contract](https://etherscan.io/address/0x71a8d10EF43A5B10E2Be2c30e379D155F904a6a3#code).
(At this state the wallet addresses and number of allowed nfts are written manually after the snapshot is announced)


## NFT attributes
![Nft attributes](https://github.com/MichiMich/FilesForInstructions/blob/main/OCAA/ZeroApeRarible.PNG)
- Apecolor (value in hex color)
- Bananascore (value between 60-100)
- Eyecolor left (value in hex color)
- Eyecolor right (value in hex color)
- Eye left (in unicode hex character)
- Eye right (in unicode hex character)
- Facesymmetry (left and right eye dependend)
- Name (generated during mint, combined with tokenId)

## Fetch NFT data
![Fetch nft data](https://github.com/MichiMich/FilesForInstructions/blob/main/OCAA/HowToFetchSvg_OnChainAsciiApes.gif)

Fully onchain generated means no secondary services/providers like ipfs needed. The nft data can be fetched by going to the etherscan address of the [contract](https://etherscan.io/address/0xAf6344bC7bC538DCf7179C36fc57cCaE302c1bbb#readContract) and query the tokenURI of your nft.


## Prerequisites
<ul  dir="auto">
<li><a  href="https://nodejs.org/en/download/"  rel="nofollow">Nodejs and npm</a>
You'll know you've installed nodejs right if you can run:


```
node --version
```
 and get an ouput like: <code>vx.x.x</code>
</ul>
<ul  dir="auto">
<li><a  href="https://hardhat.org/getting-started/"  rel="nofollow">hardhat</a>
You'll know you've installed hardhat right if you can run:

```
npx hardhat --version
```
and get an ouput like: <code>2.9.3</code>
</ul>

Yarn instead of npm. You'll know you've installed yarn right if you can run:
```
yarn --version And get an output like x.x.x
```
You might need to install it with npm


<ul  dir="auto">
A webbrowser, since you can read this here I should not have to  mention it^^
</ul>
<ul  dir="auto">
Basic understand of js, hardhat and solidity. If you want to get basic understanding up to expert I highly recommend
the man, the myth, the legend: <a href="https://www.youtube.com/watch?v=M576WGiDBdQ&t=10s">Patrick Collins</a>
</ul>
<ul  dir="auto">
Some rinkeby eth if you deploying to rinkeby testnet, you could grap some <a href="https://faucets.chain.link/rinkeby">here</a>
</ul>


## clone repository
fire up the git clone command: 
```
git clone https://github.com/MichiMich/OnChainAsciiApes
```

## cd into it
```
cd OnChainAsciiApes
```

## install dependencies
```
yarn
```

## deploy contracts on local hardhat chain
```
npx hardhat run /scripts/deploy.js --network localhost
```

If you wan tot deploy on other networks, create a secrets.json file and paste in the values like given in the secrets-example.json

# Important never push your private keys on github