const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')

const minterRole = 1
const managerRole = 2
const objectId = 1
const incorrectObjectID = 2
const objectName = 'WrldObject'
const objectType = 'land'
const metadataHash = 'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB'

describe('ObjectContractV1', function () {
  async function deployObjectContractV1() {
    const [firstWallet, secondWallet] = await ethers.getSigners()
    const ObjectContractV1 = await hre.ethers.getContractFactory(
      'ObjectContractV1',
    )
    const ObjectContractProxy = await upgrades.deployProxy(ObjectContractV1, {
      initializer: 'initialize',
      kind: 'uups',
    })
    return { ObjectContractProxy, firstWallet, secondWallet }
  }

  describe('Get Functions', function () {
    it('Fetching in contract - getObjectByID().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await ObjectContractProxy.updateMintingStatus(true)
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash,
      )
      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address,
      )

      expect(balanceOfUser.toNumber()).to.equal(balanceOfUser.toNumber())
      let objectInfoByID = await ObjectContractProxy.getObjectByID(objectId)
      expect(objectInfoByID[0]).to.equal(objectName)
      expect(objectInfoByID[1]).to.equal(objectType)
      expect(objectInfoByID[2]).to.equal(metadataHash)
    })

    it('Fetching in contract [Negative Case] - getObjectByID().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await ObjectContractProxy.updateMintingStatus(true)
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash,
      )
      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address,
      )

      expect(balanceOfUser.toNumber()).not.equal(3)

      await expect(
        ObjectContractProxy.getObjectByID(incorrectObjectID),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')
    })

    it('Fetching in contract - getObjectsByAddress().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await ObjectContractProxy.updateMintingStatus(true)
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash,
      )
      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address,
      )

      expect(balanceOfUser.toNumber()).to.equal(balanceOfUser.toNumber())
      let objectInfoByAddress = await ObjectContractProxy.getObjectsByAddress(
        secondWallet.address,
      )

      expect(objectInfoByAddress[0].name).to.equal(objectName)
      expect(objectInfoByAddress[0].objectType).to.equal(objectType)
      expect(objectInfoByAddress[0].metadataHash).to.equal(metadataHash)
    })

    it('Fetching in contract [Negative Case] - getObjectsByAddress().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await ObjectContractProxy.updateMintingStatus(true)
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash,
      )
      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address,
      )

      expect(balanceOfUser.toNumber()).not.equal(3)

      await expect(
        ObjectContractProxy.getObjectsByAddress(firstWallet.address),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')
    })
  })

  describe('tokenURI Function', function () {
    it('Fetching in contract - tokenURI().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await ObjectContractProxy.updateMintingStatus(true)
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash,
      )

      let tokenURI = await ObjectContractProxy.tokenURI(objectId)
      expect(tokenURI).to.equal(
        'https://gateway.pinata.cloud/ipfs/QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
      )
    })

    it('Fetching in contract [Negative Case]  - tokenURI().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await ObjectContractProxy.updateMintingStatus(true)
      await ObjectContractProxy.connect(secondWallet).mintObject(
        secondWallet.address,
        objectId,
        objectName,
        objectType,
        metadataHash,
      )

      await expect(
        ObjectContractProxy.tokenURI(incorrectObjectID),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')
    })
  })
})
