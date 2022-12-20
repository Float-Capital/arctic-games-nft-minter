# Arctic Games NFT Minter

Repo to mint NFT's on polygon with oz & hardhat for Float's Arctic Games

## Scripts

`yarn`

`yarn compile`

`yarn deploy`

`yarn deploy --network mumbai`

## Contract verification

[Hardhat verify](https://hardhat.org/plugins/nomiclabs-hardhat-etherscan.html)
`npx hardhat verify --network mumbai CONTRACT_ADDRESS_HERE`

Extended example:
`npx hardhat verify --network mumbai --contract contracts/NFT.sol:NFT <contract-address> "<constructor arg>"`

## Additional Resources

Tip for generating mnemonic:
`yarn add -D bip39`
` node -e 'console.log(require("bip39").generateMnemonic())'`

https://github.com/kyledewy/eth-keys <- ethersjs wrapper that can be used to convert mnemonic to pvt key & get public address of mnemonic (I reviewed the code, at time of writing no weird backdoors)
