async function main() {
    const proxyAddress = 'ADD_PROXY_ADDRESS_HERE';
   
    const UserStateContractV2 = await ethers.getContractFactory("UserStateContractV2");
    const UserStateContractV2Proxy = await upgrades.upgradeProxy(proxyAddress, UserStateContractV2);

    console.log("UserStateContractV2Proxy deployed to:", UserStateContractV2Proxy.address);
  }
   
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
