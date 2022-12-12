const { execSync } = require('child_process')

async function main() {
  const LandContract = await ethers.getContractFactory('LandContractV1')
  const LandContractProxy = await upgrades.deployProxy(
    LandContract,
    ['ADD_MERKLE_ROOT_HASH'],
    { initializer: 'initialize', kind: 'uups' },
  )
  const implementationContract = await upgrades.erc1967.getImplementationAddress(
    LandContractProxy.address,
  )
  console.log(
    'Implementation Address',
    await upgrades.erc1967.getImplementationAddress(LandContractProxy.address),
  )

  execSync('sleep 30')
  await verifyContract(implementationContract)

  console.log('Proxy Address', LandContractProxy.address)
}

async function verifyContract(implementationContract) {
  await hre.run('verify:verify', {
    address: implementationContract,
    constract: 'contracts/LandContracts/LandContractV1.sol:LandContractV1',
    constructorArgs: ['ADD_MERKLE_ROOT_HASH'],
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
