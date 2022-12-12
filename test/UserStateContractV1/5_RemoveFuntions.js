const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { constants } = require('ethers')
require('@nomicfoundation/hardhat-chai-matchers')
require('dotenv').config()

const NONE = 0
const minterRole = 1
const managerRole = 2

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

  describe('Remove Functions', function () {
    it('Remove in contract - removeWhitelistAdmin().', async function () {
      const { UserStateContractProxy, owner, secondWallet } = await loadFixture(
        deployUserStateContractV1,
      )
      await UserStateContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      await UserStateContractProxy.removeWhitelistAdmin(secondWallet.address)
      let addressWhitelistedRole = await UserStateContractProxy.adminWhitelistedAddresses(
        secondWallet.address,
      )

      expect(addressWhitelistedRole).to.equal(NONE)
    })

    it('Remove in contract [Negative case] - removeWhitelistAdmin().', async function () {
      const { UserStateContractProxy, owner, secondWallet } = await loadFixture(
        deployUserStateContractV1,
      )
      await UserStateContractProxy.addWhitelistAdmin(
        secondWallet.address,
        minterRole,
      )

      await expect(
        UserStateContractProxy.removeWhitelistAdmin(owner.address),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )

      await expect(
        UserStateContractProxy.connect(secondWallet).removeWhitelistAdmin(
          owner.address,
        ),
      ).to.be.revertedWith('Ownable: caller is not the owner')

      await UserStateContractProxy.removeWhitelistAdmin(secondWallet.address)

      await expect(
        UserStateContractProxy.removeWhitelistAdmin(secondWallet.address),
      ).to.be.revertedWithCustomError(
        UserStateContractProxy,
        'AddressNotExists',
      )

      let addressWhitelistedRole = await UserStateContractProxy.adminWhitelistedAddresses(
        secondWallet.address,
      )

      expect(addressWhitelistedRole).to.equal(NONE)
    })
  })
})
