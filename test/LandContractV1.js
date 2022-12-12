const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const ethUtil = require("ethereumjs-util");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const minterRole = 1;
const managerRole = 2;
const landId = 1;
const longitude = "10";
const limtPerAddress = 3;
const globalMintLimit = 15;
const latitude = "10";
const polygonCoordinates = "[{'longitude': '10', 'latitude':'10'}]";
const newbaseURI = "https://gateway.TTTTTT.cloud/ipfs/";
const remainingWhitelistSupply = 14;
const remainingPublicSupply = 81;
const whitelistRootHash =
  "0xb38540218109b86482322426ad7fb1c83ed332400113b41517b41acdccb470b4";

describe("LandContractV3", function (accounts) {
  async function deployLandContractV3() {
    const [firstWallet, secondWallet] = await ethers.getSigners();
    const LandContract = await hre.ethers.getContractFactory("LandContractV1");
    const LandContractProxy = await upgrades.deployProxy(
      LandContract,
      [100, 10],
      { initializer: "initialize", kind: "uups" }
    );
    return { LandContractProxy, firstWallet, secondWallet };
  }

  describe("Deployment", function () {
    it("Verifying contract - Name & symbol.", async function () {
      const { LandContractProxy } = await loadFixture(deployLandContractV1);
      expect(await LandContractProxy.name()).to.equal("LandContract");
      expect(await LandContractProxy.symbol()).to.equal("W-Land");
    });

    it("Verifying contract - BaseURI.", async function () {
      const { LandContractProxy } = await loadFixture(deployLandContractV3);
      expect(await LandContractProxy.baseURI()).to.equal(
        "https://dev-services.wrld.xyz/assets/getLandMetadataById/"
      );
    });
  });

  describe("Update Functions", function () {
    it("Updating contract - updateBaseURI().", async function () {
      const { LandContractProxy, firstWallet } = await loadFixture(
        deployLandContractV3
      );

      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );
      await LandContractProxy.updateBaseURI(newbaseURI);

      expect(await LandContractProxy.baseURI()).to.equal(newbaseURI);
    });

    it("Updating contract - updateMintingStatus()", async function () {
      const { LandContractProxy, firstWallet } = await loadFixture(
        deployLandContractV3
      );
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );
      await LandContractProxy.updateMintingStatus(true);

      expect(await LandContractProxy.isMintingEnabled()).to.equal(true);
    });

    it("Updating contract - updateMintingStatus().", async function () {
      const { LandContractProxy, firstWallet } = await loadFixture(
        deployLandContractV3
      );
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );
      await LandContractProxy.updateContractPauseStatus(true);

      expect(await LandContractProxy.paused()).to.equal(true);
    });

    it("Updating contract - updatePremiumStatus().", async function () {
      const { LandContractProxy, firstWallet } = await loadFixture(
        deployLandContractV3
      );
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );
      await LandContractProxy.updatePremiumStatus(true);

      expect(await LandContractProxy.isPremiumEnabled()).to.equal(true);
    });

    it("Updating contract - updateGlobalMintingLimit().", async function () {
      const { LandContractProxy, firstWallet } = await loadFixture(
        deployLandContractV3
      );

      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );
      await LandContractProxy.updateGlobalMintingLimit(globalMintLimit);
      let globalMintingLimit = await LandContractProxy.globalMintingLimit();
      expect(globalMintingLimit.toNumber()).to.equal(globalMintLimit);
    });
  });

  describe("Add Phase Functions", function () {
    it("Add-Phase in contract - addNewPhase()", async function () {
      const { LandContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployLandContractV3);

      await LandContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await LandContractProxy.updateMintingStatus(true);
      await LandContractProxy.connect(secondWallet).mintLandWhitelistAdmin(
        secondWallet.address,
        landId,
        longitude,
        latitude,
        polygonCoordinates
      );

      let balanceOfAdmin = await LandContractProxy.balanceOf(
        secondWallet.address
      );

      let PlatformMintingCount = await LandContractProxy.platformMintingCount();

      expect(balanceOfAdmin.toNumber()).to.equal(balanceOfAdmin.toNumber());
      expect(PlatformMintingCount.toNumber()).to.equal(
        PlatformMintingCount.toNumber()
      );
    });
  });

  describe("Mint,Add and Get Functions", function () {
    it("Minting in contract - mintLandWhitelistAdmin()", async function () {
      const { LandContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployLandContractV3);

      await LandContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await LandContractProxy.updateMintingStatus(true);
      await LandContractProxy.connect(secondWallet).mintLandWhitelistAdmin(
        secondWallet.address,
        landId,
        longitude,
        latitude,
        polygonCoordinates
      );

      let balanceOfAdmin = await LandContractProxy.balanceOf(
        secondWallet.address
      );

      let PlatformMintingCount = await LandContractProxy.platformMintingCount();

      expect(balanceOfAdmin.toNumber()).to.equal(balanceOfAdmin.toNumber());
      expect(PlatformMintingCount.toNumber()).to.equal(
        PlatformMintingCount.toNumber()
      );
    });

    it("Minting in contract - mintLandPublic().", async function () {
      const { LandContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployLandContractV3);

      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );
      await LandContractProxy.updateMintingStatus(true);
      await LandContractProxy.updatePublicSaleStatus(true);

      await LandContractProxy.connect(secondWallet).mintLandPublic(
        secondWallet.address,
        landId,
        longitude,
        latitude,
        polygonCoordinates
      );
      let balanceOfUser = await LandContractProxy.balanceOf(
        secondWallet.address
      );

      let PublicUsersMintingCount =
        await LandContractProxy.publicUsersMintingCount();

      expect(balanceOfUser.toNumber()).to.equal(balanceOfUser.toNumber());
      expect(PublicUsersMintingCount.toNumber()).to.equal(
        PublicUsersMintingCount.toNumber()
      );
    });

    it("Minting in contract - mintLandWhitelistUsers().", async function () {
      const { LandContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployLandContractV3);
      await LandContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await LandContractProxy.connect(firstWallet).updateMintingStatus(true);

      let whitelistAddresses = [
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
        "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
        "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65",
        "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc",
        "0x976EA74026E726554dB657fA54763abd0C3a0aa9",
      ];
      const leafNodes = whitelistAddresses.map((addr) => keccak256(addr));
      const merkleTree = new MerkleTree(leafNodes, keccak256, {
        sortPairs: true,
      });
      const rootHash = merkleTree.getRoot();
      const hexProof = merkleTree.getHexProof(keccak256(secondWallet.address));
      await LandContractProxy.connect(firstWallet).updateWhitelistUsers(
        whitelistAddresses.length,
        rootHash
      );

      await LandContractProxy.connect(secondWallet).mintLandWhitelistUsers(
        secondWallet.address,
        landId,
        longitude,
        latitude,
        polygonCoordinates,
        hexProof
      );
      let balanceOfUser = await LandContractProxy.balanceOf(
        secondWallet.address
      );

      let whitelistUsersMintingCount =
        await LandContractProxy.whitelistUsersMintingCount();
      expect(balanceOfUser.toNumber()).to.equal(balanceOfUser.toNumber());
      expect(whitelistUsersMintingCount.toNumber()).to.equal(
        whitelistUsersMintingCount.toNumber()
      );
    });

    it("Fetching in contract - getLandByID().", async function () {
      const { LandContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployLandContractV3);
      await LandContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await LandContractProxy.updateMintingStatus(true);
      await LandContractProxy.connect(secondWallet).mintLandWhitelistAdmin(
        secondWallet.address,
        landId,
        longitude,
        latitude,
        polygonCoordinates
      );

      let landInfoByID = await LandContractProxy.getLandById(landId);
      expect(landInfoByID[0]).to.equal(longitude);
      expect(landInfoByID[1]).to.equal(latitude);
      expect(landInfoByID[2]).to.equal(polygonCoordinates);
    });

    it("Fetching in contract - getLandsByAddress().", async function () {
      const { LandContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployLandContractV3);
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await LandContractProxy.updateMintingStatus(true);
      await LandContractProxy.updatePublicSaleStatus(true);

      await LandContractProxy.connect(secondWallet).mintLandPublic(
        secondWallet.address,
        landId,
        longitude,
        latitude,
        polygonCoordinates
      );

      let landInfoByAddress = await LandContractProxy.getLandsByAddress(
        secondWallet.address
      );
      expect(landInfoByAddress[0].longitude).to.equal(longitude);
      expect(landInfoByAddress[0].latitude).to.equal(latitude);
      expect(landInfoByAddress[0].polygonCoordinates).to.equal(
        polygonCoordinates
      );
    });
  });

  describe("tokenURI Function", function () {
    it("Fetching in contract - tokenURI().", async function () {
      const { LandContractProxy, firstWallet, secondWallet } =
        await loadFixture(deployLandContractV3);
      await LandContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole
      );
      await LandContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole
      );

      await LandContractProxy.updateMintingStatus(true);
      await LandContractProxy.connect(secondWallet).mintLandWhitelistAdmin(
        secondWallet.address,
        landId,
        longitude,
        latitude,
        polygonCoordinates
      );
      let tokenURI = await LandContractProxy.tokenURI(landId);
      expect(tokenURI).to.equal(
        "https://dev-services.wrld.xyz/assets/getLandMetadataById/1"
      );
    });
  });
});
