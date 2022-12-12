const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { constants } = require('ethers')
require('dotenv').config()

const newbaseURI = 'https://gateway.pinata.cloud/ipfs/1'
const incorrectNewbaseURI = 'https://gateway.pinata.cloud/ipfs/2'
const managerRole = 2
const userID1 = 1
const incorrectWalletAddress = '0x4a1F61b785E710451A6c11eB236285735e2Bb75a'
const incorrectStateMetadataHash =
  'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB'
const incorrectGameMetadataHash =
  'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVY'
const incorrectGameID = 2
const gameID1 = 1
const incorrectEmail = 'Ali'

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

  describe('Update Functions', function () {
    it('Updating contract - updateBaseURI().', async function () {
      const { UserStateContractProxy, owner } = await loadFixture(
        deployUserStateContractV1,
      )

      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)
      await UserStateContractProxy.updateBaseURI(newbaseURI)
      expect(await UserStateContractProxy.baseURI()).to.equal(newbaseURI)
    })

    it('Updating contract [Negative Case] - updateBaseURI().', async function () {
      const { UserStateContractProxy, owner, secondWallet } = await loadFixture(
        deployUserStateContractV1,
      )
      await UserStateContractProxy.addWhitelistAdmin(owner.address, managerRole)

      await expect(
        UserStateContractProxy.connect(secondWallet).updateBaseURI(newbaseURI),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )

      await UserStateContractProxy.updateBaseURI(newbaseURI)
      expect(await UserStateContractProxy.baseURI()).not.equal(
        incorrectNewbaseURI,
      )
    })

    it('Updating contract - updateWalletAddress()', async function () {
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
        ['tuple(uint256, uint256, address)'],
        [[1, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.updateWalletAddress(
        [1, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b'],
        signature2,
      )
      const updatedWalletAddress = await UserStateContractProxy.getWalletAddressesByUserID(
        userID1,
      )
      expect(updatedWalletAddress[0]).to.equal(
        '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b',
      )
    })

    it('Updating contract [Negative Case] - updateWalletAddress()', async function () {
      const { UserStateContractProxy, owner, secondWallet } = await loadFixture(
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
        ['tuple(uint256, uint256, address)'],
        [[1, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await expect(
        UserStateContractProxy.connect(secondWallet).updateWalletAddress(
          [1, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b'],
          signature2,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )
      await expect(
        UserStateContractProxy.updateWalletAddress(
          [2, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b'],
          signature2,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Signature')

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, uint256, address)'],
        [[2, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b']],
      )
      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)
      await expect(
        UserStateContractProxy.updateWalletAddress(
          [2, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b'],
          signature3,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const encodeUserParameters4 = abiCoder.encode(
        ['tuple(uint256, uint256, address)'],
        [[0, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b']],
      )
      const hashParameters4 = ethers.utils.keccak256(encodeUserParameters4)
      const arrayifyParameters4 = ethers.utils.arrayify(hashParameters4)
      const signature4 = await signer.signMessage(arrayifyParameters4)
      await expect(
        UserStateContractProxy.updateWalletAddress(
          [0, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b'],
          signature4,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const encodeUserParameters5 = abiCoder.encode(
        ['tuple(uint256, uint256, address)'],
        [[1, 0, '0x4a1F61b785E710451A6c11eB236285735e2Bb75a']],
      )
      const hashParameters5 = ethers.utils.keccak256(encodeUserParameters5)
      const arrayifyParameters5 = ethers.utils.arrayify(hashParameters5)
      const signature5 = await signer.signMessage(arrayifyParameters5)
      await expect(
        UserStateContractProxy.updateWalletAddress(
          [1, 0, '0x4a1F61b785E710451A6c11eB236285735e2Bb75a'],
          signature5,
        ),
      )
        .to.be.revertedWithCustomError(UserStateContractProxy, 'AlreadyExists')
        .withArgs('User Wallet Address')

      const encodeUserParameters6 = abiCoder.encode(
        ['tuple(uint256, uint256, address)'],
        [[1, 3, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b']],
      )
      const hashParameters6 = ethers.utils.keccak256(encodeUserParameters6)
      const arrayifyParameters6 = ethers.utils.arrayify(hashParameters6)
      const signature6 = await signer.signMessage(arrayifyParameters6)

      await expect(
        UserStateContractProxy.updateWalletAddress(
          [1, 3, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b'],
          signature6,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('State index')

      await UserStateContractProxy.updateWalletAddress(
        [1, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b'],
        signature2,
      )
      const updatedWalletAddress = await UserStateContractProxy.getWalletAddressesByUserID(
        userID1,
      )
      expect(updatedWalletAddress[0]).not.equal(incorrectWalletAddress)
    })

    it('Updating contract - updateStateMetadataHash()', async function () {
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
        ['tuple(uint256, uint256, string)'],
        [[1, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await UserStateContractProxy.updateStateMetadataHash(
        [1, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
        signature2,
      )
      const updatedStateMetadataHash = await UserStateContractProxy.getUserStateMetadataHashByUserID(
        1,
      )
      expect(updatedStateMetadataHash[0]).to.equal(
        'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy',
      )
    })

    it('Updating contract [Negative Case] - updateStateMetadataHash()', async function () {
      const { UserStateContractProxy, owner, secondWallet } = await loadFixture(
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
        ['tuple(uint256, uint256, string)'],
        [[1, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await expect(
        UserStateContractProxy.connect(secondWallet).updateStateMetadataHash(
          [1, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
          signature2,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )
      await expect(
        UserStateContractProxy.updateStateMetadataHash(
          [0, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
          signature2,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Signature')

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, uint256, string)'],
        [[2, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )
      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)

      await expect(
        UserStateContractProxy.updateStateMetadataHash(
          [2, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
          signature3,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const encodeUserParameters4 = abiCoder.encode(
        ['tuple(uint256, uint256, string)'],
        [[0, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )
      const hashParameters4 = ethers.utils.keccak256(encodeUserParameters4)
      const arrayifyParameters4 = ethers.utils.arrayify(hashParameters4)
      const signature4 = await signer.signMessage(arrayifyParameters4)

      await expect(
        UserStateContractProxy.updateStateMetadataHash(
          [0, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
          signature4,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const encodeUserParameters5 = abiCoder.encode(
        ['tuple(uint256, uint256, string)'],
        [[1, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV']],
      )
      const hashParameters5 = ethers.utils.keccak256(encodeUserParameters5)
      const arrayifyParameters5 = ethers.utils.arrayify(hashParameters5)
      const signature5 = await signer.signMessage(arrayifyParameters5)

      await expect(
        UserStateContractProxy.updateStateMetadataHash(
          [1, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV'],
          signature5,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('User state metadata hash')

      const encodeUserParameters6 = abiCoder.encode(
        ['tuple(uint256, uint256, string)'],
        [[1, 3, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )
      const hashParameters6 = ethers.utils.keccak256(encodeUserParameters6)
      const arrayifyParameters6 = ethers.utils.arrayify(hashParameters6)
      const signature6 = await signer.signMessage(arrayifyParameters6)

      await expect(
        UserStateContractProxy.updateStateMetadataHash(
          [1, 3, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
          signature6,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('State index')

      await UserStateContractProxy.updateStateMetadataHash(
        [1, 0, 'Q1cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
        signature2,
      )

      const updatedStateMetadataHash = await UserStateContractProxy.getUserStateMetadataHashByUserID(
        1,
      )
      expect(updatedStateMetadataHash[0]).not.equal(incorrectStateMetadataHash)
    })

    it('Updating contract -  updateGameStateMetadataHash()', async function () {
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
      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVV', 0]],
      )

      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)

      await UserStateContractProxy.updateGameStateMetadataHash(
        [1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVV', 0],
        signature3,
      )
      const updatedGameStateMetadataHash = await UserStateContractProxy.getGameStateMetadataHashByUserID(
        userID1,
        gameID1,
      )
      expect(updatedGameStateMetadataHash).to.equal(
        'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVV',
      )
    })

    it('Updating contract [Negative Case] - updateGameStateMetadataHash()', async function () {
      const { UserStateContractProxy, owner, secondWallet } = await loadFixture(
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

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 0]],
      )

      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)

      await expect(
        UserStateContractProxy.connect(
          secondWallet,
        ).updateGameStateMetadataHash(
          [1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 0],
          signature3,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )
      await expect(
        UserStateContractProxy.updateGameStateMetadataHash(
          [2, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 0],
          signature3,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Signature')

      const encodeUserParameters4 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[2, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 0]],
      )
      const hashParameters4 = ethers.utils.keccak256(encodeUserParameters4)
      const arrayifyParameters4 = ethers.utils.arrayify(hashParameters4)
      const signature4 = await signer.signMessage(arrayifyParameters4)
      await expect(
        UserStateContractProxy.updateGameStateMetadataHash(
          [2, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 0],
          signature4,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const encodeUserParameters5 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[0, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 0]],
      )
      const hashParameters5 = ethers.utils.keccak256(encodeUserParameters5)
      const arrayifyParameters5 = ethers.utils.arrayify(hashParameters5)
      const signature5 = await signer.signMessage(arrayifyParameters5)
      await expect(
        UserStateContractProxy.updateGameStateMetadataHash(
          [0, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 0],
          signature5,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const encodeUserParameters6 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV', 0]],
      )
      const hashParameters6 = ethers.utils.keccak256(encodeUserParameters6)
      const arrayifyParameters6 = ethers.utils.arrayify(hashParameters6)
      const signature6 = await signer.signMessage(arrayifyParameters6)
      await expect(
        UserStateContractProxy.updateGameStateMetadataHash(
          [1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV', 0],
          signature6,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Game state metadata hash')

      const encodeUserParameters7 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 3]],
      )
      const hashParameters7 = ethers.utils.keccak256(encodeUserParameters7)
      const arrayifyParameters7 = ethers.utils.arrayify(hashParameters7)
      const signature7 = await signer.signMessage(arrayifyParameters7)
      await expect(
        UserStateContractProxy.updateGameStateMetadataHash(
          [1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 3],
          signature7,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('State index')

      await UserStateContractProxy.updateGameStateMetadataHash(
        [1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 0],
        signature3,
      )
      const updatedGameStateMetadataHash = await UserStateContractProxy.getGameStateMetadataHashByUserID(
        userID1,
        gameID1,
      )
      expect(updatedGameStateMetadataHash).not.equal(incorrectGameMetadataHash)
    })

    it('Updating contract - updateAllStates()', async function () {
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

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
        ],
      )

      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)

      await UserStateContractProxy.updateAllStates(
        [
          1,
          '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
          'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
          'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
          0,
          0,
          0,
        ],
        signature3,
      )
      const updatedUserStates = await UserStateContractProxy.getStatesByUserID(
        userID1,
      )
      expect(updatedUserStates.email).to.equal('moiz')
      expect(updatedUserStates.walletAddresses[0]).to.equal(
        '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
      )
      expect(updatedUserStates.stateMetadataHash[0]).to.equal(
        'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
      )
      expect(updatedUserStates.gameIDs[0].toNumber()).to.equal(1)
      expect(updatedUserStates.gameMetadataHash[0]).to.equal(
        'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
      )
    })

    it('Updating contract [Negative Case] - updateAllStates()', async function () {
      const { UserStateContractProxy, owner, secondWallet } = await loadFixture(
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

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
        ],
      )

      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)

      await expect(
        UserStateContractProxy.connect(secondWallet).updateAllStates(
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
          signature3,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )

      await expect(
        UserStateContractProxy.updateAllStates(
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            1,
            0,
            0,
          ],
          signature3,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Signature')

      const encodeUserParameters4 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            2,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
        ],
      )
      const hashParameters4 = ethers.utils.keccak256(encodeUserParameters4)
      const arrayifyParameters4 = ethers.utils.arrayify(hashParameters4)
      const signature4 = await signer.signMessage(arrayifyParameters4)
      await expect(
        UserStateContractProxy.updateAllStates(
          [
            2,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
          signature4,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const encodeUserParameters5 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            0,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
        ],
      )
      const hashParameters5 = ethers.utils.keccak256(encodeUserParameters5)
      const arrayifyParameters5 = ethers.utils.arrayify(hashParameters5)
      const signature5 = await signer.signMessage(arrayifyParameters5)
      await expect(
        UserStateContractProxy.updateAllStates(
          [
            0,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
          signature5,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const encodeUserParameters6 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            1,
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
        ],
      )
      const hashParameters6 = ethers.utils.keccak256(encodeUserParameters6)
      const arrayifyParameters6 = ethers.utils.arrayify(hashParameters6)
      const signature6 = await signer.signMessage(arrayifyParameters6)
      await expect(
        UserStateContractProxy.updateAllStates(
          [
            1,
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
          signature6,
        ),
      )
        .to.be.revertedWithCustomError(UserStateContractProxy, 'AlreadyExists')
        .withArgs('User Wallet Address')

      const encodeUserParameters8 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            3,
            0,
          ],
        ],
      )
      const hashParameters8 = ethers.utils.keccak256(encodeUserParameters8)
      const arrayifyParameters8 = ethers.utils.arrayify(hashParameters8)
      const signature8 = await signer.signMessage(arrayifyParameters8)
      await expect(
        UserStateContractProxy.updateAllStates(
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            3,
            0,
          ],
          signature8,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('State index')

      const encodeUserParameters9 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQnga',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
        ],
      )
      const hashParameters9 = ethers.utils.keccak256(encodeUserParameters9)
      const arrayifyParameters9 = ethers.utils.arrayify(hashParameters9)
      const signature9 = await signer.signMessage(arrayifyParameters9)
      await expect(
        UserStateContractProxy.updateAllStates(
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQnga',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            0,
          ],
          signature9,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('User state metadata hash')

      const encodeUserParameters10 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQnga',
            0,
            0,
            0,
          ],
        ],
      )
      const hashParameters10 = ethers.utils.keccak256(encodeUserParameters10)
      const arrayifyParameters10 = ethers.utils.arrayify(hashParameters10)
      const signature10 = await signer.signMessage(arrayifyParameters10)
      await expect(
        UserStateContractProxy.updateAllStates(
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQnga',
            0,
            0,
            0,
          ],
          signature10,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Game state metadata hash')

      const encodeUserParameters11 = abiCoder.encode(
        ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
        [
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            3,
          ],
        ],
      )
      const hashParameters11 = ethers.utils.keccak256(encodeUserParameters11)
      const arrayifyParameters11 = ethers.utils.arrayify(hashParameters11)
      const signature11 = await signer.signMessage(arrayifyParameters11)
      await expect(
        UserStateContractProxy.updateAllStates(
          [
            1,
            '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
            0,
            0,
            3,
          ],
          signature11,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('State index')

      await UserStateContractProxy.updateAllStates(
        [
          1,
          '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
          'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
          'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
          0,
          0,
          0,
        ],
        signature3,
      )

      const updatedUserStates = await UserStateContractProxy.getStatesByUserID(
        userID1,
      )
      expect(updatedUserStates.email).not.equal(incorrectEmail)
      expect(updatedUserStates.walletAddresses[0]).not.equal(
        incorrectWalletAddress,
      )
      expect(updatedUserStates.stateMetadataHash[0]).not.equal(
        incorrectStateMetadataHash,
      )
      expect(updatedUserStates.gameIDs[0].toNumber()).not.equal(incorrectGameID)
      expect(updatedUserStates.gameMetadataHash[0]).not.equal(
        incorrectGameMetadataHash,
      )
    })
  })
})
