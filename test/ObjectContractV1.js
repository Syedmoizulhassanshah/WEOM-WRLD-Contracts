const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require('chai');

const newbaseURI = 'https://gateway.pinata.cloud/ipfs/1';

describe("ObjectContractV1", function (accounts) {

    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployObjectContractV1() {

        // Contracts are deployed using the first signer/account by default
        const [owner, addr1] = await ethers.getSigners();
        const ObjectContractV1 = await hre.ethers.getContractFactory("ObjectContract"); // this function allows us to get the actual class for our contract, which is in UserStateContractV1.sol
        const ObjectContractProxy = await upgrades.deployProxy(ObjectContractV1, { initializer: 'initialize', kind: 'uups' }); // here ,deploying proxy ,passing it implementation and defining which function to call and its kind.
        return { ObjectContractProxy, owner, addr1 };
    }

    describe("Deployment", function () {

        it('The NFT contract name getting initialized upon deployment.', async function () {
            const { ObjectContractProxy } = await loadFixture(deployObjectContractV1);
            let name = await ObjectContractProxy.name()
            console.log("This is the contract name upon deployment:", name);
            expect(await ObjectContractProxy.name()).to.equal("ObjectContract"); //actually testing the contract, this expect statement allows us to expect some result and compare our expectation versus reality.

        });// end of it block

        it('The NFT contract symbol getting initialized upon deployment.', async function () {
            const { ObjectContractProxy } = await loadFixture(deployObjectContractV1);
            let symbol = await ObjectContractProxy.symbol()
            console.log("This is the contract symbol upon deployment:", symbol);
            expect(await ObjectContractProxy.symbol()).to.equal("W-Objects"); //actually testing the contract, this expect statement allows us to expect some result and compare our expectation versus reality.

        });// end of it block


        it('The baseURI is getting initialized upon deployment.', async function () {
            const { ObjectContractProxy } = await loadFixture(deployObjectContractV1);
            let uri = await ObjectContractProxy.baseURI();
            console.log("This is the contract baseURI upon deployment:", uri);
            expect(await ObjectContractProxy.baseURI()).to.equal("https://gateway.pinata.cloud/ipfs/"); //actually testing the contract, this expect statement allows us to expect some result and compare our expectation versus reality.
        }); // end of  it block

    }); //end of describe



    describe("Update Functions", function () {

        it('The updateBaseURI() function is working properly.', async function () {
            const { ObjectContractProxy, owner } = await loadFixture(deployObjectContractV1);
            await ObjectContractProxy.addWhitelistAdmin(owner.address, 2);
            let uriBefore = await ObjectContractProxy.baseURI();
            console.log("This is the contract baseURI before update function call:", uriBefore);
            await ObjectContractProxy.updateBaseURI(newbaseURI);
            let uriAfter = await ObjectContractProxy.baseURI();
            console.log("This is the contract baseURI after update function call:", uriAfter);
            expect(await ObjectContractProxy.baseURI()).to.equal(newbaseURI);

        }); // end of it block


        it('The updateMintingStatus() function is working properly.', async function () {
            const { ObjectContractProxy, owner } = await loadFixture(deployObjectContractV1);
            await ObjectContractProxy.addWhitelistAdmin(owner.address, 2);
            let mintingStatusBefore = await ObjectContractProxy.isMintingEnable();
            console.log("This is the contract minting status before update function call:", mintingStatusBefore);
            await ObjectContractProxy.updateMintingStatus(true);
            let mintingStatusAfter = await ObjectContractProxy.isMintingEnable();
            console.log("This is the contract minting status after update function call:", mintingStatusAfter);
            expect(await ObjectContractProxy.isMintingEnable()).to.equal(true);

        }); // end of it block



        it('The updateContractPauseStatus() function is working properly.', async function () {
            const { ObjectContractProxy, owner } = await loadFixture(deployObjectContractV1);
            await ObjectContractProxy.addWhitelistAdmin(owner.address, 2);
            let contractPauseStatusBefore = await ObjectContractProxy.paused();
            console.log("This is the contract paused status before update function call:", contractPauseStatusBefore);
            await ObjectContractProxy.updateContractPauseStatus(true);
            let contractPauseStatusAfter = await ObjectContractProxy.paused();
            console.log("This is the contract paused status after update function call:", contractPauseStatusAfter);
            expect(await ObjectContractProxy.paused()).to.equal(true);

        }); // end of it block

    }); //end of describe


    describe("Mint,Add and Get Functions", function () {

        it('The mintObject() function is working properly.', async function () {
            const { ObjectContractProxy, owner, addr1 } = await loadFixture(deployObjectContractV1);
            await ObjectContractProxy.addWhitelistAdmin(addr1.address, 1);
            await ObjectContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfUserBeforeMint = await ObjectContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintObject() function:", balanceOfUserBeforeMint.toNumber());
            await ObjectContractProxy.updateMintingStatus(true);
            await ObjectContractProxy.connect(addr1).mintObject(addr1.address, 1, "S-Class", "Car", "false", "True", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB");
            let balanceOfUserAfterMint = await ObjectContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintObject() function:", balanceOfUserAfterMint.toNumber());
            expect(balanceOfUserAfterMint.toNumber()).to.equal(1);

        }); //end of it block

        it('The getObjectByID() function is working properly.', async function () {
            const { ObjectContractProxy, owner, addr1 } = await loadFixture(deployObjectContractV1);
            await ObjectContractProxy.addWhitelistAdmin(addr1.address, 1);
            await ObjectContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfUserBeforeMint = await ObjectContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintObject() function:", balanceOfUserBeforeMint.toNumber());
            await ObjectContractProxy.updateMintingStatus(true);
            await ObjectContractProxy.connect(addr1).mintObject(addr1.address, 1, "S-Class", "Car", "false", "True", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB");
            let balanceOfUserAfterMint = await ObjectContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintObject() function:", balanceOfUserAfterMint.toNumber());
            expect(balanceOfUserAfterMint.toNumber()).to.equal(1);
            let objectInfoByID = await ObjectContractProxy.getObjectByID(1);
            console.log("This is the Object ID `1` data by ID:", objectInfoByID);

        }); //end of it block

        it('The getObjectByAddress() function is working properly.', async function () {
            const { ObjectContractProxy, owner, addr1 } = await loadFixture(deployObjectContractV1);
            await ObjectContractProxy.addWhitelistAdmin(addr1.address, 1);
            await ObjectContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfUserBeforeMint = await ObjectContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintObject() function:", balanceOfUserBeforeMint.toNumber());
            await ObjectContractProxy.updateMintingStatus(true);
            await ObjectContractProxy.connect(addr1).mintObject(addr1.address, 1, "C-Class", "Car", "false", "True", "QmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV");
            let balanceOfUserAfterMint = await ObjectContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintObject() function:", balanceOfUserAfterMint.toNumber());
            expect(balanceOfUserAfterMint.toNumber()).to.equal(1);
            let objectInfoByAddress = await ObjectContractProxy.getObjectByAddress(addr1.address);
            console.log("This is the Object ID `1` data by address:", objectInfoByAddress);

        }); //end of it block

    }); // end of describe block  

    describe("tokenURI Function", function () {

        it('The tokenURI() function is working properly.', async function () {
            const { ObjectContractProxy, owner, addr1 } = await loadFixture(deployObjectContractV1);
            await ObjectContractProxy.addWhitelistAdmin(addr1.address, 1);
            await ObjectContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfUserBeforeMint = await ObjectContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintObject() function:", balanceOfUserBeforeMint.toNumber());
            await ObjectContractProxy.updateMintingStatus(true);
            await ObjectContractProxy.connect(addr1).mintObject(addr1.address, 1, "S-Class", "Car", "false", "True", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB");
            let balanceOfUserAfterMint = await ObjectContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintObject() function:", balanceOfUserAfterMint.toNumber());
            let tokenURI = await ObjectContractProxy.tokenURI(1);
            console.log("This is required tokenURI for object ID `1` :", tokenURI);
            expect(tokenURI).to.equal("https://gateway.pinata.cloud/ipfs/QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB");

        }); //end of it block

    }); // end of describe block 

}); // //end of main ObjectContractV1 describe