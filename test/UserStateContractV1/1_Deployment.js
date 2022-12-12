const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')
const { constants } = require('ethers')
require('dotenv').config()

const incorrectNewbaseURI = 'https://gateway.pinata.cloud/ipfs/2'

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

  describe('Deployment', function () {
    it('Verifying contract - BaseURI.', async function () {
      const { UserStateContractProxy } = await loadFixture(
        deployUserStateContractV1,
      )
      expect(await UserStateContractProxy.baseURI()).to.equal(
        'https://gateway.pinata.cloud/ipfs/',
      )
    })

    it('Verifying contract [Negative case] - BaseURI.', async function () {
      const { UserStateContractProxy } = await loadFixture(
        deployUserStateContractV1,
      )
      expect(await UserStateContractProxy.baseURI()).not.equal(
        incorrectNewbaseURI,
      )
    })
  })
})
