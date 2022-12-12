const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

const newbaseURI = "https://gateway.pinata.cloud/ipfs/1";
const baseURI = "https://gateway.pinata.cloud/ipfs/";
const minterRole = 1;
const managerRole = 2;
const contractName = "ObjectContract";
const contractSymbol = "W-Objects";
const objectId = 1;
const objectName = "WrldObject";
const objectType = "land";
const metadataHash = "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB";

describe("ObjectContractV1", function (accounts) {
  async function deployObjectContractV1() {
    const [firstWallet, secondWallet] = await ethers.getSigners();
    const ObjectContractV1 = await hre.ethers.getContractFactory(
      "ObjectContractV1"
    );
    const ObjectContractProxy = await upgrades.deployProxy(ObjectContractV1, {
      initializer: "initialize",
      kind: "uups",
    });
    return { ObjectContractProxy, firstWallet, secondWallet };
  }

  describe("Deployment", function () {
    it("Verifying contract - Name & symbol", async function () {
      const { ObjectContractProxy } = await loadFixture(deployObjectContractV1);
      expect(await ObjectContractProxy.name()).to.equal(contractName);
      expect(await ObjectContractProxy.symbol()).to.equal(contractSymbol);
    });

    it("Verifying contract - BaseURI.", async function () {
      const { ObjectContractProxy } = await loadFixture(deployObjectContractV1);
      expect(await ObjectContractProxy.baseURI()).to.equal(baseURI);
    });
  });

  describe("Update Functions", function () {
    it("Updating contract - updateBaseURI().", async function () {
      const { ObjectContractProxy, firstWallet } = await loadFixture(
        deployObjectContractV1
      );
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );
      await ObjectContractProxy.updateBaseURI(newbaseURI);

      expect(await ObjectContractProxy.baseURI()).to.equal(newbaseURI);
    });

    it("Updating contract - updateMintingStatus()", async function () {
      const { ObjectContractProxy, firstWallet } = await loadFixture(
        deployObjectContractV1
      );
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );
      await ObjectContractProxy.updateMintingStatus(true);
      expect(await ObjectContractProxy.isMintingEnable()).to.equal(true);
    });

    it("Updating contract - updateContractPauseStatus().", async function () {
      const { ObjectContractProxy, firstWallet } = await loadFixture(
        deployObjectContractV1
      );
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await ObjectContractProxy.updateContractPauseStatus(true);
      expect(await ObjectContractProxy.paused()).to.equal(true);
    });
  });

  describe("Mint,Add and Get Functions", function () {
    it("Minting in contract - mintObject().", async function () {
      const { ObjectContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployObjectContractV1);
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await ObjectContractProxy.updateMintingStatus(true);
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash
      );
      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address
      );

      expect(balanceOfUser.toNumber()).to.equal(balanceOfUser.toNumber());
    });

    it("Fetching in contract - getObjectByID().", async function () {
      const { ObjectContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployObjectContractV1);
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await ObjectContractProxy.updateMintingStatus(true);
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash
      );
      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address
      );

      expect(balanceOfUser.toNumber()).to.equal(balanceOfUser.toNumber());
      let objectInfoByID = await ObjectContractProxy.getObjectByID(objectId);
      expect(objectInfoByID[0]).to.equal(objectName);
      expect(objectInfoByID[1]).to.equal(objectType);
      expect(objectInfoByID[2]).to.equal(metadataHash);
    });

    it("Fetching in contract - getObjectsByAddress().", async function () {
      const { ObjectContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployObjectContractV1);
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await ObjectContractProxy.updateMintingStatus(true);
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash
      );
      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address
      );

      expect(balanceOfUser.toNumber()).to.equal(balanceOfUser.toNumber());
      let objectInfoByAddress = await ObjectContractProxy.getObjectsByAddress(
        secondWallet.address
      );

      expect(objectInfoByAddress[0].name).to.equal(objectName);
      expect(objectInfoByAddress[0].objectType).to.equal(objectType);
      expect(objectInfoByAddress[0].metadataHash).to.equal(metadataHash);
    });
  });

  describe("tokenURI Function", function () {
    it("Fetching in contract - tokenURI().", async function () {
      const { ObjectContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployObjectContractV1);
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await ObjectContractProxy.updateMintingStatus(true);
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash
      );

      let tokenURI = await ObjectContractProxy.tokenURI(objectId);
      expect(tokenURI).to.equal(
        "https://gateway.pinata.cloud/ipfs/QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB"
      );
    });
  });
});
