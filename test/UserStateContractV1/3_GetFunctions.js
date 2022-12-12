const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { constants } = require('ethers')
require('dotenv').config()
require('@nomicfoundation/hardhat-chai-matchers/withArgs')
require('@nomicfoundation/hardhat-chai-matchers')

const managerRole = 2
const userID1 = 1
const incorrectUserID = 2
const userIDZero = 0
const incorrectWalletAddress = '0x4a1F61b785E710451A6c11eB236285735e2Bb75a'
const incorrectStateMetadataHash =
  'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB'
const incorrectGameMetadataHash =
  'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAVVV'
const incorrectGameID = 2
const gameID1 = 1
const incorrectEmail = 'Ali'
const incorrectWalletAddress2 = '0x025Add8324e11fE364661fD08267133c631F56AF'
const incorrectStateMetadataHash2 =
  'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMMM'
const incorrectGameMetadataHash2 =
  'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmABBB'

describe('UserStateContractV1', function (accounts) {
  async function deployUserStateContractV1() {
    const [owner, secondWallet] = await ethers.getSigners()
    const UserStateContractV1 = await hre.ethers.getContractFactory(
      'UserStateContractV1',
    )
    const UserStateContractProxy = await upgrades.deployProxy(
      UserStateContractV1,
      { initializer: 'initialize', kind: 'uups' },
    )
    return { UserStateContractProxy, owner, secondWallet }
  }

  describe('Get Functions', function () {
    it('Fetching in contract - getWalletAddressesByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )

      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, address)'],
        [[1, '0x025Add8324e11fE364661fD08267133c631F56AF']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addUserNewWalletAddress(
        [1, '0x025Add8324e11fE364661fD08267133c631F56AF'],
        signature2,
      )
      const newWalletAddress = await UserStateContractProxy.getWalletAddressesByUserID(
        userID1,
      )
      expect(newWalletAddress[1]).to.equal(
        '0x025Add8324e11fE364661fD08267133c631F56AF',
      )
    })

    it('Fetching in contract [Negative Case] - getWalletAddressesByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )

      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, address)'],
        [[1, '0x025Add8324e11fE364661fD08267133c631F56AF']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addUserNewWalletAddress(
        [1, '0x025Add8324e11fE364661fD08267133c631F56AF'],
        signature2,
      )

      await expect(
        UserStateContractProxy.getWalletAddressesByUserID(incorrectUserID),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')
      await expect(
        UserStateContractProxy.getWalletAddressesByUserID(userIDZero),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const newWalletAddress = await UserStateContractProxy.getWalletAddressesByUserID(
        userID1,
      )

      expect(newWalletAddress[1]).not.equal(incorrectWalletAddress)
    })

    it('Fetching in contract - getUserStateMetadataHashByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )

      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string)'],
        [[1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addStateMetadataHash(
        [1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
        signature2,
      )
      const newStateMetadataHash = await UserStateContractProxy.getUserStateMetadataHashByUserID(
        userID1,
      )
      expect(newStateMetadataHash[1]).to.equal(
        'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy',
      )
    })

    it('Fetching in contract [Negative Case] - getUserStateMetadataHashByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )

      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string)'],
        [[1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addStateMetadataHash(
        [1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
        signature2,
      )

      await expect(
        UserStateContractProxy.getUserStateMetadataHashByUserID(userIDZero),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')
      await expect(
        UserStateContractProxy.getUserStateMetadataHashByUserID(
          incorrectUserID,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')
      const newStateMetadataHash = await UserStateContractProxy.getUserStateMetadataHashByUserID(
        userID1,
      )
      expect(newStateMetadataHash[1]).not.equal(incorrectStateMetadataHash)
    })

    it('Fetching in contract - getGameStateMetadataHashByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )
      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature2,
      )
      const newGameStateMetadataHash = await UserStateContractProxy.getGameStateMetadataHashByUserID(
        userID1,
        gameID1,
      )
      expect(newGameStateMetadataHash).to.equal(
        'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy',
      )
    })

    it('Fetching in contract [Negative Case] - getGameStateMetadataHashByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )
      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature2,
      )

      await expect(
        UserStateContractProxy.getGameStateMetadataHashByUserID(
          userIDZero,
          gameID1,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')
      await expect(
        UserStateContractProxy.getGameStateMetadataHashByUserID(
          incorrectUserID,
          gameID1,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')
      await expect(
        UserStateContractProxy.getGameStateMetadataHashByUserID(
          userID1,
          incorrectGameID,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'GameIdNotExists')

      const newGameStateMetadataHash = await UserStateContractProxy.getGameStateMetadataHashByUserID(
        userID1,
        gameID1,
      )
      expect(newGameStateMetadataHash).not.equal(incorrectGameMetadataHash)
    })

    it('Fetching in contract -  getGameIDsByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )
      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature2,
      )
      const gameIDs = await UserStateContractProxy.getGameIDsByUserID(userID1)
      expect(gameIDs[0].toNumber()).to.equal(1)
    })

    it('Fetching in contract [Negative Case] -  getGameIDsByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )
      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature2,
      )

      await expect(UserStateContractProxy.getGameIDsByUserID(userIDZero))
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')
      await expect(
        UserStateContractProxy.getGameIDsByUserID(incorrectUserID),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const gameIDs = await UserStateContractProxy.getGameIDsByUserID(userID1)
      expect(gameIDs[0].toNumber()).not.equal(incorrectGameID)
    })

    it('Fetching in contract - getAllUsers()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )
      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature2,
      )
      const Users = await UserStateContractProxy.getAllUsers()

      expect(Users[0].email).to.equal('moiz')
      expect(Users[0].walletAddresses[0]).to.equal(
        '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
      )
      expect(Users[0].stateMetadataHash[0]).to.equal(
        'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
      )
      expect(Users[0].gameMetadataHash[0]).to.equal(
        'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy',
      )
      expect(Users[0].gameIDs[0].toNumber()).to.equal(1)
    })

    it('Fetching in contract [Negative Case] - getAllUsers()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )
      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature2,
      )
      const Users = await UserStateContractProxy.getAllUsers()

      expect(Users[0].email).not.equal(incorrectEmail)
      expect(Users[0].walletAddresses[0]).not.equal(incorrectWalletAddress2)
      expect(Users[0].stateMetadataHash[0]).not.equal(
        incorrectStateMetadataHash2,
      )
      expect(Users[0].gameMetadataHash[0]).not.equal(incorrectGameMetadataHash2)
      expect(Users[0].gameIDs[0].toNumber()).not.equal(incorrectGameID)
    })

    it('Fetching in contract - getStatesByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )
      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature2,
      )

      const updatedUserStates = await UserStateContractProxy.getStatesByUserID(
        userID1,
      )

      expect(updatedUserStates.email).to.equal('moiz')
      expect(updatedUserStates.walletAddresses[0]).to.equal(
        '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
      )
      expect(updatedUserStates.stateMetadataHash[0]).to.equal(
        'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
      )
      expect(updatedUserStates.gameIDs[0].toNumber()).to.equal(1)
      expect(updatedUserStates.gameMetadataHash[0]).to.equal(
        'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy',
      )
    })

    it('Fetching in contract [Negative Case] - getStatesByUserID()', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )
      const privateKey = process.env.PRIVATEKEY
      const signer = new ethers.Wallet(privateKey)
      const abiCoder = ethers.utils.defaultAbiCoder

      const encodeUserParameters = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )

      const hashParameters = ethers.utils.keccak256(encodeUserParameters)
      const arrayifyParameters = ethers.utils.arrayify(hashParameters)
      const signature = await signer.signMessage(arrayifyParameters)

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature2,
      )

      await expect(UserStateContractProxy.getStatesByUserID(userIDZero))
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')
      await expect(
        UserStateContractProxy.getStatesByUserID(incorrectUserID),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const updatedUserStates = await UserStateContractProxy.getStatesByUserID(
        userID1,
      )

      expect(updatedUserStates.email).not.equal(incorrectEmail)
      expect(updatedUserStates.walletAddresses[0]).not.equal(
        incorrectWalletAddress2,
      )
      expect(updatedUserStates.stateMetadataHash[0]).not.equal(
        incorrectStateMetadataHash2,
      )
      expect(updatedUserStates.gameIDs[0].toNumber()).not.equal(incorrectGameID)
      expect(updatedUserStates.gameMetadataHash[0]).not.equal(
        incorrectGameMetadataHash2,
      )
    })
  })
})
