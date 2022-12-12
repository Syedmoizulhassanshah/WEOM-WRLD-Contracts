const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { CustomError } = require('hardhat/internal/core/errors')

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

  describe('Mint functions', function () {
    it('Minting in contract - mintObject().', async function () {
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

      expect(balanceOfUser.toNumber()).to.equal(1)
    })

    it('Minting in contract [Negative Case] - mintObject().', async function () {
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

      await expect(
        ObjectContractProxy.connect(secondWallet).mintObject(
          secondWallet.address,
          objectId,
          objectName,
          objectType,
          metadataHash,
        ),
      ).to.be.revertedWithCustomError(
        ObjectContractProxy,
        'MintingStatusPaused',
      )

      await ObjectContractProxy.updateMintingStatus(true)
      await expect(
        ObjectContractProxy.connect(firstWallet).mintObject(
          secondWallet.address,
          objectId,
          objectName,
          objectType,
          metadataHash,
        ),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')

      let balanceOfUser = await ObjectContractProxy.balanceOf(
        secondWallet.address,
      )

      expect(balanceOfUser.toNumber()).to.equal(0)
    })

    it('Minting in contract - mintBulkObjects().', async function () {
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
      await ObjectContractProxy.connect(secondWallet).mintBulkObjects([
        [
          1,
          '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
          'moiz',
          '2d',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
        ],
        [
          2,
          '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
          'moiz',
          '3d',
          'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGG',
        ],
      ])
      let balanceOfUser = await ObjectContractProxy.balanceOf(
        firstWallet.address,
      )

      expect(balanceOfUser.toNumber()).to.equal(2)
    })

    it('Minting in contract [Negative Case] - mintBulkObjects().', async function () {
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

      await expect(
        ObjectContractProxy.connect(secondWallet).mintBulkObjects([
          [
            1,
            '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
            'moiz',
            '2d',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
          [
            2,
            '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
            'moiz',
            '3d',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGG',
          ],
        ]),
      ).to.be.revertedWithCustomError(
        ObjectContractProxy,
        'MintingStatusPaused',
      )

      await ObjectContractProxy.updateMintingStatus(true)
      await expect(
        ObjectContractProxy.connect(firstWallet).mintBulkObjects([
          [
            1,
            '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
            'moiz',
            '2d',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB',
          ],
          [
            2,
            '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
            'moiz',
            '3d',
            'QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGG',
          ],
        ]),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')

      let balanceOfUser = await ObjectContractProxy.balanceOf(
        firstWallet.address,
      )

      expect(balanceOfUser.toNumber()).to.equal(0)
    })
  })
})
