const { network } = require("hardhat");
const { NFTFactory, NFT } = require("../hardhat.contracts.helpers");

let networkToUse = network.name;

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const feeRecipient = accounts[1];

  let config;
  let networkConfirmations;

  if (
    networkToUse != "mumbai" &&
    networkToUse != "polygon" &&
    networkToUse != "fuji"
  ) {
    console.log(networkToUse);
    networkConfirmations = 0;
    config = require("../nfts/config/local");
  } else if (networkToUse === "polygon") {
    console.log(networkToUse);
    networkConfirmations = 2;
    config = require("../nfts/config/polygon");
  } else if (networkToUse === "mumbai") {
    console.log(networkToUse);
    networkConfirmations = 2;
    config = require("../nfts/config/mumbai");
  } else if (networkToUse === "fuji") {
    console.log(networkToUse);
    networkConfirmations = 2;
    config = require("../nfts/config/fuji");
  } else {
    throw new Error(`network ${networkToUse} un-accounted for`);
  }

  let { nfts } = config;

  for (var i = 0; i < nfts.length; i++) {
    let nft = nfts[i];
    let bps = 0;
    // deploy nft
    let nftAddress = await deployNFT(
      deployer,
      feeRecipient,
      networkConfirmations,
      nft.name,
      nft.symbol,
      nft.baseURI,
      nft.receiverAddresses.length,
      bps
    );
    console.log(nftAddress);

    // mint tokens
    await mintCollection(deployer, nftAddress, nft.receiverAddresses);
  }
};

async function deployNFT(
  deployer,
  feeRecipient,
  networkConfirmations,
  name,
  symbol,
  baseURI,
  numTokens,
  feeBps
) {
  console.log("Deploying NFTs with the account:", deployer.address);

  const Erc721Factory = await deployments.get(NFTFactory);
  const erc721Factory = await ethers.getContractAt(
    NFTFactory,
    Erc721Factory.address
  );
  console.log(numTokens);

  let tx = await erc721Factory
    .connect(deployer)
    .deployNFT(
      name,
      symbol,
      baseURI,
      deployer.address,
      feeRecipient.address,
      numTokens,
      feeBps
    );

  let receipt = await tx.wait(networkConfirmations);

  let nftAddress;
  for (var x = 0; x < receipt.events.length; x++) {
    let event = receipt.events[x];
    if (event["event"] == "NFTDeployed") {
      nftAddress = event["args"][0];
      console.log(event["event"]);
    }
  }

  console.log("NFT deployed to: ", nftAddress);

  console.log("");
  console.log("");
  console.log("Contract verification command");
  console.log("----------------------------------");
  console.log(
    `npx hardhat verify --network ${networkToUse} --contract contracts/NFT.sol:NFT ${nftAddress} "${name}" "${symbol}" "${baseURI}" "${deployer.address}" "${feeRecipient.address}" "${numTokens}" "${feeBps}"`
  );
  console.log("");
  console.log("");

  return nftAddress;
}

async function mintCollection(admin, nftAddress, receiverAddresses) {
  console.log("Minting tokens with the account:", admin.address);

  const erc721 = await ethers.getContractAt(NFT, nftAddress);

  for (var i = 0; i < receiverAddresses.length; i++) {
    console.log("------------------------------------------------------------");

    let tokenId = i + 1;

    console.log("Minting tokenId: ", tokenId);
    console.log("Minting to: ", receiverAddresses[i]);

    let mintTx = await erc721.connect(admin).mint(receiverAddresses[i]);

    console.log("Mint transaction: ");
    console.log(mintTx);
  }
  console.log("Minting complete");
}

module.exports.tags = ["deployAndMintNfts"];
