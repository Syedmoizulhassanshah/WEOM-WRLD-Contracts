async function main() {
    const proxyAddress = 'ADD_PROXY_ADDRESS_HERE';
   
    const LandContractV2 = await ethers.getContractFactory("LandContractV2");
    const LandContractV2Proxy = await upgrades.upgradeProxy(proxyAddress, LandContractV2);

    console.log("LandContractV2Proxy deployed to:", LandContractV2Proxy.address);
  }
   
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
