const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
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

  describe('Remove Functions', function () {
    it('Remove in contract - removeWhitelistAdmin().', async function () {
      const { ObjectContractProxy, secondWallet } = await loadFixture(
        deployObjectContractV1,
      )
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      await ObjectContractProxy.removeWhitelistAdmin(secondWallet.address)
      let addressWhitelistedRole = await ObjectContractProxy.adminWhitelistedAddresses(
        secondWallet.address,
      )

      expect(addressWhitelistedRole).to.equal(NONE)
    })

    it('Remove in contract [Negative Case] - removeWhitelistAdmin().', async function () {
      const {
        ObjectContractProxy,
        firstWallet,
        secondWallet,
      } = await loadFixture(deployObjectContractV1)
      await ObjectContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      await expect(
        ObjectContractProxy.removeWhitelistAdmin(firstWallet.address),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')

      await expect(
        ObjectContractProxy.connect(secondWallet).removeWhitelistAdmin(
          firstWallet.address,
        ),
      ).to.be.revertedWith('Ownable: caller is not the owner')

      await ObjectContractProxy.removeWhitelistAdmin(secondWallet.address)

      await expect(
        ObjectContractProxy.removeWhitelistAdmin(secondWallet.address),
      ).to.be.revertedWithCustomError(ObjectContractProxy, 'NotExists')

      let addressWhitelistedRole = await ObjectContractProxy.adminWhitelistedAddresses(
        secondWallet.address,
      )

      expect(addressWhitelistedRole).to.equal(NONE)
    })
  })
})
