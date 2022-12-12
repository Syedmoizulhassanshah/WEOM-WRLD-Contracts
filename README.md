# mv-smart-contracts

## About Wrld3d - Blockchain

We have been developing following contracts for Wetopia:

* Land NFT Contract - ERC721
* Order Settlement Contract
* Avatar Contract
* User State Contract

### Built With

Following frameworks/libraries has been used in this project:

* [![Ethereum Blockchain][Ethereum.org]][Ethereum-url]
* [![Polygon Blockchain][Polygon.technology]][Polygon-url]
* [![Hardhat][Hardhat.org]][Hardhat-url]
* [![OpenZepplin][Openzeppelin.com]][Openzeppelin-url]
* [![Javascript][Javascript.com]][Javascript-url]
* [![ChaiJS][Chaijs.com]][Chaijs-url]

## Getting Started - Local Setup

This is a guide to run repository in local environment. Following are the steps of configuration:

### Prerequisites

#### Packages

This is an example of how to list things you need to use the software and how to install them.
* nvm
  ```sh
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  ```
  ```sh
  nvm install 16
  ``` 
* node-gyp
  ```sh
  npm install node-gyp@latest -g
  ``` 

#### VS-Code Extensions

* Solidity + HardHat (https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity)

### Installation

1. Clone the repo
2. Install NPM packages
   ```sh
   npm install
   ```
3. Create `.env` file and use `.env-example` structure
4. Configure keys in `.env`
5. To run tests
   ```sh
   npx hardhat test
   GAS_REPORT=true npx hardhat test
   ``` 
6. To run contract script
   ```sh
   npx hardhat run scripts/deploy.js
   ```   
7. To verify contract
   ```sh
   npx hardhat verify CONTRACT_ADDR --network NETWORK_NAME
   ``` 

### Deploy and Verify -  Upgradable contract

1. Run the deployment script **deployContractV1.js** present in the scripts folder, using following command:  

   ```sh
   npx hardhat run --network rinkeby scripts/deployContractV1.js
   ``` 

2. Now add your proxy address in **upgradeContractV2.js** at "CONTRACT_ADDR"
 
3. Run the upgrade script **upgradeContractV2.js** present in the scripts folder, using following command:  

   ```sh
   npx hardhat run --network rinkeby scripts/upgradeContractV2.js
   ``` 

### Merkle Tree for Whitelist User 

#### Install npm packages

1. Go to the **merkleProofScripts** folder

2. Install NPM packages
   ```sh
   npm install
   ```

#### Set & Run script - Merkle Root Generator 

1. Add whitelist addresses array in `const whitelistAddresses = [ADD_ADDRESSESS_HERE];` 

2. Run the merkle proof script merkle_tree.js present in the scripts folder, using following command:
  ```sh
  node merkle_tree.js
   ``` 
#### Generate Merkle Proof for specific address 

2. Select your address index from leafNodes: `const claimingAddress = leafNodes[0];`
to see if an address is verified in the Merkle Tree or Not.

## Roadmap

- [x] Setup Repository
- [x] Requirement Document
- [ ] Land Contract
    - [x] Structure Development
    - [ ] Contract Development
    - [ ] Unit Test Development
    - [ ] Tested
    - [ ] Staged
    - [ ] Deployed
- [ ] Avatar Contract
    - [ ] Structure Development
    - [ ] Contract Development
    - [ ] Unit Test Development
    - [ ] Tested
    - [ ] Staged
    - [ ] Deployed
- [ ] User State Contract
    - [ ] Structure Development
    - [ ] Contract Development
    - [ ] Unit Test Development
    - [ ] Tested
    - [ ] Staged
    - [ ] Deployed
- [ ] Order Settlement Contract
    - [x] Structure Development
    - [ ] Contract Development
    - [ ] Unit Test Development
    - [ ] Tested
    - [ ] Staged
    - [ ] Deployed


<!-- MARKDOWN LINKS & IMAGES -->
[Ethereum.org]: https://img.shields.io/badge/Blockchain-Ethereum-lightgrey
[Ethereum-url]: https://ethereum.org/en/
[Polygon.technology]: https://img.shields.io/badge/Blockchain-Polygon-lightgrey
[Polygon-url]: https://polygon.technology/
[Hardhat.org]: https://img.shields.io/badge/Framework-HardHat-green
[Hardhat-url]: https://hardhat.org/
[Openzeppelin.com]: https://img.shields.io/badge/Framework-Openzeppelin-green
[Openzeppelin-url]: https://www.openzeppelin.com/
[Javascript.com]: https://img.shields.io/badge/Framework-Javascript-green
[Javascript-url]: https://www.javascript.com/
[Chaijs.com]: https://img.shields.io/badge/Framework-Chaijs-yellow
[Chaijs-url]: https://www.chaijs.com/
