const { NFTFactory, NFT } = require("../hardhat.contracts.helpers");
const { expect } = require("chai");

describe(" NFT  contract", function () {
  let Factory;
  let deployer;
  let user1;
  let user2;
  let user3;
  let nft;
  let name;
  let symbol;
  let testUri;
  let maxTokenAmount;
  let defaultBps = 1000;

  beforeEach(async function () {
    const accounts = await ethers.getSigners();
    deployer = accounts[0];
    user1 = accounts[1];
    user2 = accounts[2];
    user3 = accounts[3];
    salesRecipient = accounts[4];
    network = 0;

    maxTokenAmount = 10;

    const FactoryContract = await ethers.getContractFactory(NFTFactory);

    Factory = await FactoryContract.deploy();
    name = "test";
    symbol = "TST";
    testUri = "testUri/";

    let deployTx = await Factory.connect(deployer).deployNFT(
      name,
      symbol,
      testUri,
      deployer.address,
      salesRecipient.address,
      maxTokenAmount,
      defaultBps
    );
    await new Promise((res) => setTimeout(() => res(null), 5000));

    let nftAddress = await Factory.nfts(0);

    nft = await ethers.getContractAt(NFT, nftAddress);
  });
  it("should assign fee recipients", async function () {
    let feeRecipients = await nft.connect(deployer).getFeeRecipients(0);
    expect(feeRecipients[0]).to.be.equal(salesRecipient.address);
  });
  it("should assign fee bps", async function () {
    let feeBps = await nft.connect(deployer).getFeeBps(0);
    expect(feeBps[0]).to.be.equal(defaultBps);
  });
});
