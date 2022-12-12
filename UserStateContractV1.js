const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { constants } = require("ethers");
require("dotenv").config();

const newbaseURI = "https://gateway.pinata.cloud/ipfs/1";

describe("UserStateContractV1", function (accounts) {
  async function deployUserStateContractV1() {
    const [owner, addr1] = await ethers.getSigners();
    const UserStateContractV1 = await hre.ethers.getContractFactory(
      "UserStateContractV1"
    );
    const UserStateContractProxy = await upgrades.deployProxy(
      UserStateContractV1,
      { initializer: "initialize", kind: "uups" }
    );
    return { UserStateContractProxy, owner, addr1 };
  }

  describe("Deployment", function () {
    it("Verifying contract - BaseURI.", async function () {
      const { UserStateContractProxy } = await loadFixture(
        deployUserStateContractV1
      );
      expect(await UserStateContractProxy.baseURI()).to.equal(
        "https://gateway.pinata.cloud/ipfs/"
      );
    });
  });

  describe("Add & Get Functions", function () {
    it("Adding in contract -  addUser() & addWhitelistAdmin()", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );

      const privateKey = process.env.PRIVATEKEY;
      const signer = new ethers.Wallet(privateKey);
      const abiCoder = ethers.utils.defaultAbiCoder;

      const encodeUserParameters = abiCoder.encode(
        ["tuple(uint256, string, address, string, string, uint256)"],
        [
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
        ]
      );

      async function generateSignature() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.addUser(
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
          signature
        );
        let UserCount = await UserStateContractProxy.userCount();
        expect(UserCount.toNumber()).to.equal(1);
      }

      generateSignature();
    }); //end of it block

    it("Adding in contract - addUserNewWalletAddress & getWalletAddressesByUserID()", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );

      const privateKey = process.env.PRIVATEKEY;
      const signer = new ethers.Wallet(privateKey);
      const abiCoder = ethers.utils.defaultAbiCoder;

      const encodeUserParameters = abiCoder.encode(
        ["tuple(uint256, string, address, string, string, uint256)"],
        [
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
        ]
      );

      async function generateSignature() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.addUser(
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
          signature
        );
      }
      generateSignature();

      const encodeUserParameters2 = abiCoder.encode(
        ["tuple(uint256, address)"],
        [[1, "0x025Add8324e11fE364661fD08267133c631F56AF"]]
      );

      async function generateSignature2() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters2);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addUserNewWalletAddress(
          [1, "0x025Add8324e11fE364661fD08267133c631F56AF"],
          signature
        );
        const newWalletAddress =
          await UserStateContractProxy.getWalletAddressesByUserID(1);
        expect(newWalletAddress[1]).to.equal(
          "0x025Add8324e11fE364661fD08267133c631F56AF"
        );
      }

      generateSignature2();
    });

    it("Adding in contract - addStateMetadataHash() & getUserStateMetadataHashByUserID()", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );

      const privateKey = process.env.PRIVATEKEY;
      const signer = new ethers.Wallet(privateKey);
      const abiCoder = ethers.utils.defaultAbiCoder;

      const encodeUserParameters = abiCoder.encode(
        ["tuple(uint256, string, address, string, string, uint256)"],
        [
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
        ]
      );

      async function generateSignature() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.addUser(
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
          signature
        );
      }
      generateSignature();

      const encodeUserParameters2 = abiCoder.encode(
        ["tuple(uint256, string)"],
        [[1, "QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy"]]
      );

      async function generateSignature2() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters2);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addStateMetadataHash(
          [1, "QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy"],
          signature
        );
        const newStateMetadataHash =
          await UserStateContractProxy.getUserStateMetadataHashByUserID(1);
        expect(newStateMetadataHash[1]).to.equal(
          "QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy"
        );
      }

      generateSignature2();
    });

    it("Adding in contract - addNewGameState() and getGameStateMetadataHashByUserID()", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );
      const privateKey = process.env.PRIVATEKEY;
      const signer = new ethers.Wallet(privateKey);
      const abiCoder = ethers.utils.defaultAbiCoder;

      const encodeUserParameters = abiCoder.encode(
        ["tuple(uint256, string, address, string, string, uint256)"],
        [
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
        ]
      );

      async function generateSignature() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.addUser(
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
          signature
        );
      }
      generateSignature();

      const encodeUserParameters2 = abiCoder.encode(
        ["tuple(uint256, string, uint256)"],
        [[1, "Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy", 13]]
      );

      async function generateSignature2() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters2);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addNewGameState(
          [1, "Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy", 13],
          signature
        );
        const newGameStateMetadataHash =
          await UserStateContractProxy.getGameStateMetadataHashByUserID(1, 13);
        expect(newGameStateMetadataHash).to.equal(
          "Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy"
        );
      }

      generateSignature2();
    });
  });

  describe("Update Functions", function () {
    it("Updating contract - updateBaseURI().", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );

      async function Update() {
        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.updateBaseURI(newbaseURI);
        expect(await UserStateContractProxy.baseURI()).to.equal(newbaseURI);
      }
      Update();
    });

    it("Updating contract - updateWalletAddress() & getWalletAddressesByUserID()", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );

      const privateKey = process.env.PRIVATEKEY;
      const signer = new ethers.Wallet(privateKey);
      const abiCoder = ethers.utils.defaultAbiCoder;

      const encodeUserParameters = abiCoder.encode(
        ["tuple(uint256, string, address, string, string, uint256)"],
        [
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
        ]
      );

      async function generateSignature() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.addUser(
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
          signature
        );
      }
      generateSignature();

      const encodeUserParameters2 = abiCoder.encode(
        ["tuple(uint256, uint256, address)"],
        [[1, 0, "0xe2b5a5b611643c7e0e4D705315bf580B75472d7b"]]
      );

      async function generateSignature2() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters2);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.updateWalletAddress(
          [1, 0, "0xe2b5a5b611643c7e0e4D705315bf580B75472d7b"],
          signature
        );
        const updatedWalletAddress =
          await UserStateContractProxy.getWalletAddressesByUserID(1);
        expect(updatedWalletAddress[0]).to.equal(
          "0xe2b5a5b611643c7e0e4D705315bf580B75472d7b"
        );
      }

      generateSignature2();
    });

    it("Updating contract - updateStateMetadataHash() & getUserStateMetadataHashByUserID()", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );
      const privateKey = process.env.PRIVATEKEY;
      const signer = new ethers.Wallet(privateKey);
      const abiCoder = ethers.utils.defaultAbiCoder;

      const encodeUserParameters = abiCoder.encode(
        ["tuple(uint256, string, address, string, string, uint256)"],
        [
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
        ]
      );

      async function generateSignature() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.addUser(
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
          signature
        );
      }
      generateSignature();

      const encodeUserParameters2 = abiCoder.encode(
        ["tuple(uint256, uint256, string)"],
        [[1, 0, "Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy"]]
      );

      async function generateSignature2() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters2);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.updateStateMetadataHash(
          [1, 0, "Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy"],
          signature
        );
        const updatedStateMetadataHash =
          await UserStateContractProxy.getUserStateMetadataHashByUserID(1);
        expect(updatedStateMetadataHash[0]).to.equal(
          "Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy"
        );
      }

      generateSignature2();
    });

    it("Updating contract - updateGameStateMetadataHash() & getGameStateMetadataHashByUserID()", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );
      const privateKey = process.env.PRIVATEKEY;
      const signer = new ethers.Wallet(privateKey);
      const abiCoder = ethers.utils.defaultAbiCoder;

      const encodeUserParameters = abiCoder.encode(
        ["tuple(uint256, string, address, string, string, uint256)"],
        [
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
        ]
      );

      async function generateSignature() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.addUser(
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
          signature
        );
      }
      generateSignature();

      const encodeUserParameters2 = abiCoder.encode(
        ["tuple(uint256, string, uint256)"],
        [[1, "Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy", 0]]
      );

      async function generateSignature2() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters2);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.updateGameStateMetadataHash(
          [1, "Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy", 0],
          signature
        );
        const updatedGameStateMetadataHash =
          await UserStateContractProxy.getGameStateMetadataHashByUserID(1, 1);
        expect(updatedGameStateMetadataHash).to.equal(
          "Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy"
        );
      }

      generateSignature2();
    });

    it("Updating contract - updateAllStates() & getStatesByUserID()", async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1
      );
      const privateKey = process.env.PRIVATEKEY;
      const signer = new ethers.Wallet(privateKey);
      const abiCoder = ethers.utils.defaultAbiCoder;

      const encodeUserParameters = abiCoder.encode(
        ["tuple(uint256, string, address, string, string, uint256)"],
        [
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
        ]
      );

      async function generateSignature() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
        await UserStateContractProxy.addUser(
          [
            1,
            "moiz",
            "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
            1,
          ],
          signature
        );
      }
      generateSignature();

      const encodeUserParameters2 = abiCoder.encode(
        ["tuple(uint256, address, string, string, uint256, uint256, uint256)"],
        [
          [
            1,
            "0xa864f883E78F67a005a94B1B32Bf3375dfd121E6",
            "CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV",
            "CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV",
            0,
            0,
            0,
          ],
        ]
      );

      async function generateSignature2() {
        const hashParameters = ethers.utils.keccak256(encodeUserParameters2);
        const arrayifyParameters = ethers.utils.arrayify(hashParameters);
        const signature = await signer.signMessage(arrayifyParameters);

        await UserStateContractProxy.updateAllStates(
          [
            1,
            "0xa864f883E78F67a005a94B1B32Bf3375dfd121E6",
            "CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV",
            "CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV",
            0,
            0,
            0,
          ],
          signature
        );
        const updatedUserStates =
          await UserStateContractProxy.getStatesByUserID(1);
        expect(updatedUserStates.email).to.equal("moiz");
        expect(updatedUserStates.walletAddresses[0]).to.equal(
          "0xa864f883E78F67a005a94B1B32Bf3375dfd121E6"
        );
        expect(updatedUserStates.stateMetadataHash[0]).to.equal(
          "CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV"
        );
        expect(updatedUserStates.gameIDs[0].toNumber()).to.equal(1);
        expect(updatedUserStates.gameMetadataHash[0]).to.equal(
          "CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV"
        );
      }

      generateSignature2();
    });
  });
});
