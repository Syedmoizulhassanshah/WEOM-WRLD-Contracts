const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')

const newbaseURI = 'https://gateway.pinata.cloud/ipfs/1'
const incorrectNewbaseURI = 'https://gateway.pinata.cloud/ipfs/2'
const minterRole = 1
const managerRole = 2
const objectId = 1
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

  describe('Update Functions', function () {
    it('Updating contract - updateBaseURI().', async function () {
      const { ObjectContractProxy, firstWallet } = await loadFixture(
        deployObjectContractV1,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )
      await ObjectContractProxy.updateBaseURI(newbaseURI)

      expect(await ObjectContractProxy.baseURI()).to.equal(newbaseURI)
    })

    it('Updating contract [Negative Case] - updateBaseURI().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await expect(
        ObjectContractProxy.connect(secondWallet).updateBaseURI(newbaseURI),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')
      await ObjectContractProxy.updateBaseURI(newbaseURI)

      expect(await ObjectContractProxy.baseURI()).not.equal(incorrectNewbaseURI)
    })

    it('Updating contract - updateMintingStatus()', async function () {
      const { ObjectContractProxy, firstWallet } = await loadFixture(
        deployObjectContractV1,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )
      await ObjectContractProxy.updateMintingStatus(true)
      expect(await ObjectContractProxy.isMintingEnable()).to.equal(true)
    })

    it('Updating contract [Negative Case] - updateMintingStatus()', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await expect(
        ObjectContractProxy.connect(secondWallet).updateMintingStatus(true),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')
      await ObjectContractProxy.updateMintingStatus(true)
      expect(await ObjectContractProxy.isMintingEnable()).not.equal(false)
    })

    it('Updating contract - updateContractPauseStatus().', async function () {
      const { ObjectContractProxy, firstWallet } = await loadFixture(
        deployObjectContractV1,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await ObjectContractProxy.updateContractPauseStatus(true)
      expect(await ObjectContractProxy.paused()).to.equal(true)
    })

    it('Updating contract [Negative Case] - updateContractPauseStatus().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        firstWallet.address,
        managerRole,
      )

      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      await expect(
        ObjectContractProxy.connect(secondWallet).updateContractPauseStatus(
          true,
        ),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')

      await ObjectContractProxy.updateContractPauseStatus(true)

      await ObjectContractProxy.updateMintingStatus(true)

      await expect(
        ObjectContractProxy.connect(secondWallet).mintObject(
          secondWallet.address,
          objectId,
          objectName,
          objectType,
          metadataHash,
        ),
      ).to.be.revertedWith('Pausable: paused')

      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address,
      )

      expect(balanceOfUser.toNumber()).to.equal(0)
      expect(await ObjectContractProxy.paused()).not.equal(false)
    })
  })
})
