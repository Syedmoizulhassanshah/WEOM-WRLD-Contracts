const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { ethers } = require('hardhat')

const minterRole = 1
const NONE = 0

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

  describe('Add Functions', function () {
    it('Adding in contract - addWhitelistAdmin().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      let addressWhitelistedRole = await ObjectContractProxy.adminWhitelistedAddresses(
        secondWallet.address,
      )
      expect(addressWhitelistedRole).to.equal(minterRole)
    })

    it('Adding in contract [Negative Case]- addWhitelistAdmin().', async function () {
      const { ObjectContractProxy, secondWallet } = await loadFixture(
        deployObjectContractV1,
      )

      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      await expect(
        ObjectContractProxy.addWhitelistAdmin(secondWallet.address, minterRole),
      ).to.be.revertedWithCustomError(
        ObjectContractProxy,
        'AddressAlreadyExists',
      )

      await expect(
        ObjectContractProxy.connect(secondWallet).addWhitelistAdmin(
          secondWallet.address,
          minterRole,
        ),
      ).to.be.revertedWith('Ownable: caller is not the owner')

      let addressWhitelistedRole = await ObjectContractProxy.adminWhitelistedAddresses(
        secondWallet.address,
      )
      expect(addressWhitelistedRole).not.equal(NONE)
    })
  })
})
