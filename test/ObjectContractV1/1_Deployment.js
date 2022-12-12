const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')
const { expect } = require('chai')

const baseURI = 'https://gateway.pinata.cloud/ipfs/'
const contractName = 'ObjectContract'
const contractSymbol = 'W-Objects'

const incorrectbaseURI = 'https://gateway.pinata.cloud/ipfs/2'
const incorrectContractName = 'ObjectContract2'
const incorrectContractSymbol = 'W-Objects2'

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

  describe('Deployment', function () {
    it('Verifying contract - Name & symbol', async function () {
      const { ObjectContractProxy } = await loadFixture(deployObjectContractV1)
      expect(await ObjectContractProxy.name()).to.equal(contractName)
      expect(await ObjectContractProxy.symbol()).to.equal(contractSymbol)
    })

    it('Verifying contract [Negative Case] - Name & symbol', async function () {
      const { ObjectContractProxy } = await loadFixture(deployObjectContractV1)
      expect(await ObjectContractProxy.name()).not.equal(incorrectContractName)
      expect(await ObjectContractProxy.symbol()).not.equal(
        incorrectContractSymbol,
      )
    })

    it('Verifying contract - BaseURI.', async function () {
      const { ObjectContractProxy } = await loadFixture(deployObjectContractV1)
      expect(await ObjectContractProxy.baseURI()).to.equal(baseURI)
    })

    it('Verifying contract [Negative Case] - BaseURI.', async function () {
      const { ObjectContractProxy } = await loadFixture(deployObjectContractV1)
      expect(await ObjectContractProxy.baseURI()).not.equal(incorrectbaseURI)
    })
  })
})
