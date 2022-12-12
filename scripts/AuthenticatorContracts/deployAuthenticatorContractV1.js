const { execSync } = require('child_process')

async function main() {
  const AuthenticatorContract = await ethers.getContractFactory(
    'AuthenticatorContractV1',
  )
  const AuthenticatorContractProxy = await upgrades.deployProxy(
    AuthenticatorContract,
    { initializer: 'initialize', kind: 'uups' },
  )
  const implementationContract = await upgrades.erc1967.getImplementationAddress(
    AuthenticatorContractProxy.address,
  )
  console.log(
    'Implementation Address',
    await upgrades.erc1967.getImplementationAddress(
      AuthenticatorContractProxy.address,
    ),
  )

  execSync('sleep 30')

  await verifyContract(implementationContract)
  console.log('Proxy Address', AuthenticatorContractProxy.address)
}

async function verifyContract(implementationContract) {
  await hre.run('verify:verify', {
    address: implementationContract,
    constract:
      'contracts/AuthenticatorContracts/AuthenticatorContractV1.sol:AuthenticatorContractV1',
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
