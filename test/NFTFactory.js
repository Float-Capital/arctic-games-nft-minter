const { NFTFactory, NFT } = require("../hardhat.contracts.helpers");
const { expect } = require("chai");

describe(" NFT Factory contract", function () {
  let Factory;
  let deployer;
  let user1;
  let user2;
  let user3;
  let defaultBps = 1000;

  beforeEach(async function () {
    const accounts = await ethers.getSigners();
    deployer = accounts[0];
    user1 = accounts[1];
    user2 = accounts[2];
    user3 = accounts[3];

    const FactoryContract = await ethers.getContractFactory(NFTFactory);

    Factory = await FactoryContract.deploy();
  });

  it("Should deploy a new token", async function () {
    let name = "test";
    let symbol = "TST";
    let testUri = "testUri";
    let maxTokenAmount = 4000;

    let deployTx = await Factory.connect(deployer).deployNFT(
      name,
      symbol,
      testUri,
      deployer.address,
      user3.address,
      maxTokenAmount,
      defaultBps
    );

    await new Promise((res) => setTimeout(() => res(null), 5000));

    let nftAddress = await Factory.nfts(0);

    let nft = await ethers.getContractAt(NFT, nftAddress);

    let baseUri = await nft.baseURI();

    await expect(baseUri).to.be.equal(testUri);
  });

  it("Should emit NFTDeployed event", async function () {
    let name = "test";
    let symbol = "TST";
    let testUri = "testUri";
    let maxTokenAmount = 4000;

    await expect(
      await Factory.connect(deployer).deployNFT(
        name,
        symbol,
        testUri,
        deployer.address,
        deployer.address,
        maxTokenAmount,
        defaultBps
      )
    ).to.emit(Factory, "NFTDeployed");
  });

  it("Should fail when anyone but owner tries to create an nft", async function () {
    let name = "test";
    let symbol = "TST";
    let testUri = "testUri";
    let maxTokenAmount = 4000;

    await expect(
      Factory.connect(user1).deployNFT(
        name,
        symbol,
        testUri,
        deployer.address,
        deployer.address,
        maxTokenAmount,
        defaultBps
      )
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });
});
