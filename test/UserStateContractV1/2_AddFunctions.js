const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { constants } = require('ethers')
require('dotenv').config()
require('@nomicfoundation/hardhat-chai-matchers/withArgs')
require('@nomicfoundation/hardhat-chai-matchers')

const NONE = 0
const minterRole = 1
const managerRole = 2
const userID1 = 1
const incorrectWalletAddress = '0x4a1F61b785E710451A6c11eB236285735e2Bb75a'
const incorrectStateMetadataHash =
  'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB'
const incorrectGameMetadataHash =
  'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAVVV'
const gameID1 = 1

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

  describe('Add Functions', function () {
    it('Adding in contract - addWhitelistAdmin().', async function () {
      const { UserStateContractProxy, owner, secondWallet } = await loadFixture(
        deployUserStateContractV1,
      )
      await UserStateContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      let addressWhitelistedRole = await UserStateContractProxy.adminWhitelistedAddresses(
        secondWallet.address,
      )
      expect(addressWhitelistedRole).to.equal(minterRole)
    })

    it('Adding in contract [Negative Case]- addWhitelistAdmin().', async function () {
      const { UserStateContractProxy, secondWallet } = await loadFixture(
        deployUserStateContractV1,
      )
      await UserStateContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      await expect(
        UserStateContractProxy.addWhitelistAdmin(
          secondWallet.address,
          minterRole,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressAlreadyExists',
      )

      await expect(
        UserStateContractProxy.connect(secondWallet).addWhitelistAdmin(
          secondWallet.address,
          minterRole,
        ),
      ).to.be.revertedWith('Ownable: caller is not the owner')

      let addressWhitelistedRole = await UserStateContractProxy.adminWhitelistedAddresses(
        secondWallet.address,
      )
      expect(addressWhitelistedRole).not.equal(NONE)
    })

    it('Adding in contract - addUser()', async function () {
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
      let UserCount = await UserStateContractProxy.userCount()
      expect(UserCount.toNumber()).to.equal(1)
    })

    it('Adding in contract [Negative Case]  addUser()', async function () {
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

      await expect(
        UserStateContractProxy.connect(secondWallet).addUser(
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
          signature,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )

      await UserStateContractProxy.addUser(
        [
          1,
          'moiz',
          '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        signature,
      )

      await expect(
        UserStateContractProxy.addUser(
          [
            1,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
          signature,
        ),
      )
        .to.be.revertedWithCustomError(UserStateContractProxy, 'AlreadyExists')
        .withArgs('User Wallet Address')

      await expect(
        UserStateContractProxy.addUser(
          [
            0,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
          signature,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Signature')

      const encodeUserParameters2 = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            0,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )
      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)

      await expect(
        UserStateContractProxy.addUser(
          [
            0,
            'moiz',
            '0x4a1F61b785E710451A6c11eB236285735e2Bb75a',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
          signature2,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            1,
            'moiz',
            '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
        ],
      )
      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)

      await expect(
        UserStateContractProxy.addUser(
          [
            1,
            'moiz',
            '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
          signature3,
        ),
      )
        .to.be.revertedWithCustomError(UserStateContractProxy, 'AlreadyExists')
        .withArgs('Email')

      const encodeUserParameters4 = abiCoder.encode(
        ['tuple(uint256, string, address, string)'],
        [
          [
            2,
            'ali',
            '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMG',
          ],
        ],
      )
      const hashParameters4 = ethers.utils.keccak256(encodeUserParameters4)
      const arrayifyParameters4 = ethers.utils.arrayify(hashParameters4)
      const signature4 = await signer.signMessage(arrayifyParameters4)

      await expect(
        UserStateContractProxy.addUser(
          [
            2,
            'ali',
            '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMG',
          ],
          signature4,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('User state metadata hash')

      const UserCount = await UserStateContractProxy.userCount()
      expect(UserCount.toNumber()).not.equal(2)
    })

    it('Adding in contract - addUserNewWalletAddress', async function () {
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

    it('Adding in contract [Negative Case] - addUserNewWalletAddress', async function () {
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
        ['tuple(uint256, address)'],
        [[1, '0x025Add8324e11fE364661fD08267133c631F56AF']],
      )
      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)
      await expect(
        UserStateContractProxy.connect(secondWallet).addUserNewWalletAddress(
          [1, '0x025Add8324e11fE364661fD08267133c631F56AF'],
          signature2,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, address)'],
        [[1, '0x025Add8324e11fE364661fD08267133c631F56AF']],
      )
      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)
      await expect(
        UserStateContractProxy.addUserNewWalletAddress(
          [0, '0x025Add8324e11fE364661fD08267133c631F56AF'],
          signature3,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Signature')

      const encodeUserParameters4 = abiCoder.encode(
        ['tuple(uint256, address)'],
        [[0, '0x025Add8324e11fE364661fD08267133c631F56AF']],
      )
      const hashParameters4 = ethers.utils.keccak256(encodeUserParameters4)
      const arrayifyParameters4 = ethers.utils.arrayify(hashParameters4)
      const signature4 = await signer.signMessage(arrayifyParameters4)
      await expect(
        UserStateContractProxy.addUserNewWalletAddress(
          [0, '0x025Add8324e11fE364661fD08267133c631F56AF'],
          signature4,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const encodeUserParameters5 = abiCoder.encode(
        ['tuple(uint256, address)'],
        [[2, '0x025Add8324e11fE364661fD08267133c631F56AF']],
      )
      const hashParameters5 = ethers.utils.keccak256(encodeUserParameters5)
      const arrayifyParameters5 = ethers.utils.arrayify(hashParameters5)
      const signature5 = await signer.signMessage(arrayifyParameters5)
      await expect(
        UserStateContractProxy.addUserNewWalletAddress(
          [2, '0x025Add8324e11fE364661fD08267133c631F56AF'],
          signature5,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const encodeUserParameters6 = abiCoder.encode(
        ['tuple(uint256, address)'],
        [[1, '0x4a1F61b785E710451A6c11eB236285735e2Bb75a']],
      )
      const hashParameters6 = ethers.utils.keccak256(encodeUserParameters6)
      const arrayifyParameters6 = ethers.utils.arrayify(hashParameters6)
      const signature6 = await signer.signMessage(arrayifyParameters6)
      await expect(
        UserStateContractProxy.addUserNewWalletAddress(
          [1, '0x4a1F61b785E710451A6c11eB236285735e2Bb75a'],
          signature6,
        ),
      )
        .to.be.revertedWithCustomError(UserStateContractProxy, 'AlreadyExists')
        .withArgs('User Wallet Address')

      const newWalletAddress = await UserStateContractProxy.getWalletAddressesByUserID(
        userID1,
      )
      expect(newWalletAddress[1]).not.equal(incorrectWalletAddress)
    })

    it('Adding in contract - addStateMetadataHash()', async function () {
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

    it('Adding in contract [Negative Case] - addStateMetadataHash()', async function () {
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
        ['tuple(uint256, string)'],
        [[1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )

      const hashParameters2 = ethers.utils.keccak256(encodeUserParameters2)
      const arrayifyParameters2 = ethers.utils.arrayify(hashParameters2)
      const signature2 = await signer.signMessage(arrayifyParameters2)
      await expect(
        UserStateContractProxy.connect(secondWallet).addStateMetadataHash(
          [1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV'],
          signature2,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, string)'],
        [[1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV']],
      )
      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)
      await expect(
        UserStateContractProxy.addStateMetadataHash(
          [1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
          signature3,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('Signature')

      const encodeUserParameters4 = abiCoder.encode(
        ['tuple(uint256, string)'],
        [[0, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )
      const hashParameters4 = ethers.utils.keccak256(encodeUserParameters4)
      const arrayifyParameters4 = ethers.utils.arrayify(hashParameters4)
      const signature4 = await signer.signMessage(arrayifyParameters4)
      await expect(
        UserStateContractProxy.addStateMetadataHash(
          [0, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
          signature4,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const encodeUserParameters5 = abiCoder.encode(
        ['tuple(uint256, string)'],
        [[2, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy']],
      )
      const hashParameters5 = ethers.utils.keccak256(encodeUserParameters5)
      const arrayifyParameters5 = ethers.utils.arrayify(hashParameters5)
      const signature5 = await signer.signMessage(arrayifyParameters5)
      await expect(
        UserStateContractProxy.addStateMetadataHash(
          [2, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy'],
          signature5,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const encodeUserParameters6 = abiCoder.encode(
        ['tuple(uint256, string)'],
        [[1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV']],
      )
      const hashParameters6 = ethers.utils.keccak256(encodeUserParameters6)
      const arrayifyParameters6 = ethers.utils.arrayify(hashParameters6)
      const signature6 = await signer.signMessage(arrayifyParameters6)
      await expect(
        UserStateContractProxy.addStateMetadataHash(
          [1, 'QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV'],
          signature6,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('User state metadata hash')

      const newStateMetadataHash = await UserStateContractProxy.getUserStateMetadataHashByUserID(
        userID1,
      )
      expect(newStateMetadataHash[1]).not.equal(incorrectStateMetadataHash)
    })

    it('Adding in contract - addNewGameState()', async function () {
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

    it('Adding in contract [Negative Case] - addNewGameState()', async function () {
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
      await expect(
        UserStateContractProxy.connect(secondWallet).addNewGameState(
          [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
          signature2,
        ),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )

      const encodeUserParameters3 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV', 1]],
      )
      const hashParameters3 = ethers.utils.keccak256(encodeUserParameters3)
      const arrayifyParameters3 = ethers.utils.arrayify(hashParameters3)
      const signature3 = await signer.signMessage(arrayifyParameters3)
      await expect(
        UserStateContractProxy.addNewGameState(
          [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
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
        [[0, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )
      const hashParameters4 = ethers.utils.keccak256(encodeUserParameters4)
      const arrayifyParameters4 = ethers.utils.arrayify(hashParameters4)
      const signature4 = await signer.signMessage(arrayifyParameters4)
      await expect(
        UserStateContractProxy.addNewGameState(
          [0, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
          signature4,
        ),
      )
        .to.be.revertedWithCustomError(
          UserStateContractProxy,
          'InvalidParameters',
        )
        .withArgs('UserId cannot be zero')

      const encodeUserParameters5 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[2, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )
      const hashParameters5 = ethers.utils.keccak256(encodeUserParameters5)
      const arrayifyParameters5 = ethers.utils.arrayify(hashParameters5)
      const signature5 = await signer.signMessage(arrayifyParameters5)
      await expect(
        UserStateContractProxy.addNewGameState(
          [2, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
          signature5,
        ),
      ).to.be.revertedWithCustomError(UserStateContractProxy, 'UserIdNotExists')

      const encodeUserParameters6 = abiCoder.encode(
        ['tuple(uint256, string, uint256)'],
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV', 1]],
      )
      const hashParameters6 = ethers.utils.keccak256(encodeUserParameters6)
      const arrayifyParameters6 = ethers.utils.arrayify(hashParameters6)
      const signature6 = await signer.signMessage(arrayifyParameters6)
      await expect(
        UserStateContractProxy.addNewGameState(
          [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFV', 1],
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
        [[1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
      )
      const hashParameters7 = ethers.utils.keccak256(encodeUserParameters7)
      const arrayifyParameters7 = ethers.utils.arrayify(hashParameters7)
      const signature7 = await signer.signMessage(arrayifyParameters7)
      await UserStateContractProxy.addNewGameState(
        [1, 'Q2cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1],
        signature7,
      )

      const newGameStateMetadataHash = await UserStateContractProxy.getGameStateMetadataHashByUserID(
        userID1,
        gameID1,
      )
      expect(newGameStateMetadataHash).not.equal(incorrectGameMetadataHash)
    })
  })
})
