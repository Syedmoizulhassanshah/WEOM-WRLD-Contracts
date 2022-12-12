const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require('chai');

const newbaseURI = 'https://gateway.pinata.cloud/ipfs/1';

describe("UserStateContractV1", function (accounts) {

    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployUserStateContractV1() {

        // Contracts are deployed using the first signer/account by default
        const [owner, addr1] = await ethers.getSigners();
        const UserStateContractV1 = await hre.ethers.getContractFactory("UserStateContractV1"); // this function allows us to get the actual class for our contract, which is in UserStateContractV1.sol
        const UserStateContractProxy = await upgrades.deployProxy(UserStateContractV1, { initializer: 'initialize', kind: 'uups' }); // here ,deploying proxy ,passing it implementation and defining which function to call and its kind.

        return { UserStateContractProxy, owner, addr1 };

    }

    describe("Deployment", function () {

        it('The baseURI is getting initialized upon deployment.', async function () {
            const { UserStateContractProxy } = await loadFixture(deployUserStateContractV1);
            expect(await UserStateContractProxy.baseURI()).to.equal("https://gateway.pinata.cloud/ipfs/"); //actually testing the contract, this expect statement allows us to expect some result and compare our expectation versus reality.
        }); // end of  it block

    }); //end of describe

    describe("Add Functions", function () {

        it('The addUser() and addWhitelistAdmin() functions are working properly.', async function () {
            const { UserStateContractProxy, owner } = await loadFixture(deployUserStateContractV1);
            await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
            await UserStateContractProxy.addUser(1, ["moiz", "0x4a1F61b785E710451A6c11eB236285735e2Bb75a", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", 1], "0x09d132e07988479a601fe0f4e87dadc69d16e19ec51b7134c0c0c252bb0bcb5d67d8abf56cca96bad94bd0f23c32d33a6252ead1d558de05f3725444ad0795031b");
            let UserCount = await UserStateContractProxy.userCount();
            expect(UserCount.toNumber()).to.equal(1);

        }); //end of it block

    }); // end of describe block

    describe("Update and Get Functions", function () {

        it('The updateBaseURI() function is working properly.', async function () {
            const { UserStateContractProxy, owner } = await loadFixture(deployUserStateContractV1);
            await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
            await UserStateContractProxy.updateBaseURI(newbaseURI);
            expect(await UserStateContractProxy.baseURI()).to.equal(newbaseURI);
        }); // end of it block

        it('The updateWalletAddress() & getWalletAddressesByUserID() functions are working properly.', async function () {

            const { UserStateContractProxy, owner } = await loadFixture(deployUserStateContractV1);
            await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
            await UserStateContractProxy.addUser(1, ["moiz", "0x4a1F61b785E710451A6c11eB236285735e2Bb75a", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", 1], "0x09d132e07988479a601fe0f4e87dadc69d16e19ec51b7134c0c0c252bb0bcb5d67d8abf56cca96bad94bd0f23c32d33a6252ead1d558de05f3725444ad0795031b");
            const walletAddressBeforeUpdate = await UserStateContractProxy.getWalletAddressesByUserID(1);
            console.log("These are the wallet addresses before update:", walletAddressBeforeUpdate);
            await UserStateContractProxy.updateWalletAddress(1, "0x22372bbf7855C718C4B08848bBdEf25D42AEa4Cf", "0x41da240762c2e362fc9210e5db68df870d3f3d1e1064654a5ed2bd39305282e133bc26381adec6ba5dd1fededf5b8257bc43266e775fc678e52381ae21a000021b");
            const walletAddressAfterUpdate = await UserStateContractProxy.getWalletAddressesByUserID(1);
            console.log("These are the wallet addresses after update:", walletAddressAfterUpdate);


        }); // end of it block

        it('The updateStateMetadataHash() & getUserStateMetadataHashByUserID() functions are working properly.', async function () {

            const { UserStateContractProxy, owner } = await loadFixture(deployUserStateContractV1);
            await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
            await UserStateContractProxy.addUser(1, ["moiz", "0x4a1F61b785E710451A6c11eB236285735e2Bb75a", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", 1], "0x09d132e07988479a601fe0f4e87dadc69d16e19ec51b7134c0c0c252bb0bcb5d67d8abf56cca96bad94bd0f23c32d33a6252ead1d558de05f3725444ad0795031b");
            const StateMetadataHashBeforeUpdate = await UserStateContractProxy.getUserStateMetadataHashByUserID(1);
            console.log("These are the state metadata hashes before update:", StateMetadataHashBeforeUpdate);
            await UserStateContractProxy.updateStateMetadataHash(1, "QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy", "0xa29f88aeff59942d6ff77c2ea60e805f06093f55c516ac2cc853ef9352a49dc1114e346c2fa9bd9d9b696471f7d9a390cdafce8b5e052763dfe2c66495c3a3311b");
            const StateMetadataHashAfterUpdate = await UserStateContractProxy.getUserStateMetadataHashByUserID(1);
            console.log("These are the state metadata hashes after update:", StateMetadataHashAfterUpdate);

        }); // end of it block

        it('The updateGameStateMetadataHash() and getGameStateMetadataHashByUserID() functions are working properly.', async function () {

            const { UserStateContractProxy, owner } = await loadFixture(deployUserStateContractV1);
            await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
            await UserStateContractProxy.addUser(1, ["moiz", "0x4a1F61b785E710451A6c11eB236285735e2Bb75a", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", 1], "0x09d132e07988479a601fe0f4e87dadc69d16e19ec51b7134c0c0c252bb0bcb5d67d8abf56cca96bad94bd0f23c32d33a6252ead1d558de05f3725444ad0795031b");
            const GameStateMetadataHashBeforeUpdate = await UserStateContractProxy.getGameStateMetadataHashByUserID(1, 1);
            console.log("This is the game state metadata hash before update:", GameStateMetadataHashBeforeUpdate);
            await UserStateContractProxy.updateGameStateMetadataHash(1, ["QmcnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy", 1], "0xcebf452428842500f026aa3aa38f52c7a0ddb50c14ec0913fcbe167f6b4ba9c50aa5c11ba9a1c7607be7500d552462ea7de98f0f597cfce8651a0bf5f6cabe951b");
            const GameStateMetadataHashAfterUpdate = await UserStateContractProxy.getGameStateMetadataHashByUserID(1, 1);
            console.log("This is the game state metadata hash after update:", GameStateMetadataHashAfterUpdate);

        }); // end of it block

        it('The updateAllStates() & getUserInfoByUserID() functions are working properly.', async function () {
            const { UserStateContractProxy, owner } = await loadFixture(deployUserStateContractV1);
            await UserStateContractProxy.addWhitelistAdmin(owner.address, 2);
            await UserStateContractProxy.addUser(1, ["moiz", "0x4a1F61b785E710451A6c11eB236285735e2Bb75a", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB", 1], "0x09d132e07988479a601fe0f4e87dadc69d16e19ec51b7134c0c0c252bb0bcb5d67d8abf56cca96bad94bd0f23c32d33a6252ead1d558de05f3725444ad0795031b");
            const UserInfoBeforeUpdate = await UserStateContractProxy.getUserInfoByUserID(1);
            console.log("This is the user info before update:", UserInfoBeforeUpdate);
            await UserStateContractProxy.updateAllStates(1, ["0xa864f883E78F67a005a94B1B32Bf3375dfd121E6", "QmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV", "QmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV", 1], "0xed4fb3da94eef3a7de680f2dfbb468ef5a5ec897c3dd60f629d36f644cff197f59c9283e9c60225f1d9e11c407d4bd51ad858d9df151b9ec76e6b9335c9d115e1c");
            const UserInfoAfterUpdate = await UserStateContractProxy.getUserInfoByUserID(1);
            console.log("This is the user info after update:", UserInfoAfterUpdate);

        }); // end of it block



    }); //end of describe




}); //end of main UserStateContractV1 describe
