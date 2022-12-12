const { execSync } = require('child_process')
const { ethers } = require("hardhat");

async function main() {
  const UserStateContract = await ethers.getContractFactory(
    'UserStateContractV1',
  )
  const UserStateContractProxy = await upgrades.deployProxy(
    UserStateContract,
    { initializer: 'initialize', kind: 'uups' }
  )
  const implementationContract = await upgrades.erc1967.getImplementationAddress(
    UserStateContractProxy.address,
  )
  console.log(
    'Implementation Address',
    await upgrades.erc1967.getImplementationAddress(
      UserStateContractProxy.address,
    ),
  )

  execSync('sleep 30')

  await verifyContract(implementationContract)
  console.log('Proxy Address', UserStateContractProxy.address)
}

async function verifyContract(implementationContract) {
  await hre.run('verify:verify', {
    address: implementationContract,
    constract:
      'contracts/UserStateContracts/UserStateContractV1.sol:UserStateContractV1',
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
