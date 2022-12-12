const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require('chai');
const ethUtil = require('ethereumjs-util');
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')

const newbaseURI = 'https://gateway.TTTTTT.cloud/ipfs/';

describe("LandContract", function (accounts) {

    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployLandContractV1() {

        // Contracts are deployed using the first signer/account by default
        const [owner, addr1] = await ethers.getSigners();
        const LandContract = await hre.ethers.getContractFactory("LandContract"); // this function allows us to get the actual class for our contract, which is in UserStateContractV1.sol
        const LandContractProxy = await upgrades.deployProxy(LandContract, [100, 7, 5], { initializer: 'initialize', kind: 'uups' }); // here ,deploying proxy ,passing it implementation and defining which function to call and its kind.
        return { LandContractProxy, owner, addr1 };
    }

    describe("Deployment", function () {

        it('The NFT contract name getting initialized upon deployment.', async function () {
            const { LandContractProxy } = await loadFixture(deployLandContractV1);
            let name = await LandContractProxy.name()
            console.log("This is the contract name upon deployment:", name);
            expect(await LandContractProxy.name()).to.equal("LandContract"); //actually testing the contract, this expect statement allows us to expect some result and compare our expectation versus reality.

        });// end of it block

        it('The NFT contract symbol getting initialized upon deployment.', async function () {
            const { LandContractProxy } = await loadFixture(deployLandContractV1);
            let symbol = await LandContractProxy.symbol()
            console.log("This is the contract symbol upon deployment:", symbol);
            expect(await LandContractProxy.symbol()).to.equal("W-Land"); //actually testing the contract, this expect statement allows us to expect some result and compare our expectation versus reality.

        });// end of it block


        it('The baseURI is getting initialized upon deployment.', async function () {
            const { LandContractProxy } = await loadFixture(deployLandContractV1);
            let uri = await LandContractProxy.baseURI();
            console.log("This is the contract baseURI upon deployment:", uri);
            expect(await LandContractProxy.baseURI()).to.equal("https://dev-services.wrld.xyz/assets/getLandMetadataById/"); //actually testing the contract, this expect statement allows us to expect some result and compare our expectation versus reality.
        }); // end of  it block

    }); //end of describe

    describe("Update Functions", function () {

        it('The updateBaseURI() function is working properly.', async function () {
            const { LandContractProxy, owner } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let uriBefore = await LandContractProxy.baseURI();
            console.log("This is the contract baseURI before update function call:", uriBefore);
            await LandContractProxy.updateBaseURI(newbaseURI);
            let uriAfter = await LandContractProxy.baseURI();
            console.log("This is the contract baseURI after update function call:", uriAfter);
            expect(await LandContractProxy.baseURI()).to.equal(newbaseURI);

        }); // end of it block

        it('The updateMintingStatus() function is working properly.', async function () {
            const { LandContractProxy, owner } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let mintingStatusBefore = await LandContractProxy.isMintingEnable();
            console.log("This is the contract minting status before update function call:", mintingStatusBefore);
            await LandContractProxy.updateMintingStatus(true);
            let mintingStatusAfter = await LandContractProxy.isMintingEnable();
            console.log("This is the contract minting status after update function call:", mintingStatusAfter);
            expect(await LandContractProxy.isMintingEnable()).to.equal(true);

        }); // end of it block


        it('The updateContractPauseStatus() function is working properly.', async function () {
            const { LandContractProxy, owner } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let contractPauseStatusBefore = await LandContractProxy.paused();
            console.log("This is the contract paused status before update function call:", contractPauseStatusBefore);
            await LandContractProxy.updateContractPauseStatus(true);
            let contractPauseStatusAfter = await LandContractProxy.paused();
            console.log("This is the contract paused status after update function call:", contractPauseStatusAfter);
            expect(await LandContractProxy.paused()).to.equal(true);

        }); // end of it block


        it('The updateLandMintingLimitPerAddress() function is working properly.', async function () {
            const { LandContractProxy, owner } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let landMintingLimitPerAddressBefore = await LandContractProxy.landMintingLimitPerAddress();
            console.log("This is the landMinting limit per address before update function call:", landMintingLimitPerAddressBefore.toNumber());
            await LandContractProxy.updateLandMintingLimitPerAddress(3);
            let landMintingLimitPerAddressAfter = await LandContractProxy.landMintingLimitPerAddress();
            console.log("This is the landMinting limit per address after update function call:", landMintingLimitPerAddressAfter.toNumber());
            expect(landMintingLimitPerAddressAfter.toNumber()).to.equal(3);

        }); // end of it block


        it('The updateWhitelistUsers() function is working properly.', async function () {
            const { LandContractProxy, owner, addr1 } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let WhitelistUsersMintingLimitBefore = await LandContractProxy.whitelistUsersMintingLimit();
            console.log("This is the whitelist users minting limit before update function call:", WhitelistUsersMintingLimitBefore.toNumber());
            let UsersWhitelistRootHashBefore = await LandContractProxy.usersWhitelistRootHash();
            console.log("This is users whitelist root hash before update function call:", UsersWhitelistRootHashBefore);
            let publicMintingLimitBefore = await LandContractProxy.publicMintingLimit();
            console.log("This is public minting limit before update function call:", publicMintingLimitBefore.toNumber());

            let whitelistAddresses = [
                '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
                '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
                '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
                '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
                '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65',
                '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
                '0x976EA74026E726554dB657fA54763abd0C3a0aa9',
            ]
            const leafNodes = whitelistAddresses.map((addr) => keccak256(addr))
            const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true })
            const rootHash = merkleTree.getRoot();

            console.log('Root Hash: ', ethUtil.bufferToHex(rootHash));
            const claimingAddress = addr1.address
            const hexProof = merkleTree.getHexProof(claimingAddress)
            console.log("hexProof:", hexProof)

            await LandContractProxy.updateWhitelistUsers(2, ethUtil.bufferToHex(rootHash));
            let WhitelistUsersMintingLimitAfter = await LandContractProxy.whitelistUsersMintingLimit();
            console.log("This is the whitelist users minting limit after update function call:", WhitelistUsersMintingLimitAfter.toNumber());
            let UsersWhitelistRootHashAfter = await LandContractProxy.usersWhitelistRootHash();
            console.log("This is users whitelist root hash after update function call:", UsersWhitelistRootHashAfter);
            let PublicMintingLimitAfter = await LandContractProxy.publicMintingLimit();
            console.log("This is public minting limit after update function call:", PublicMintingLimitAfter.toNumber());
            expect(WhitelistUsersMintingLimitAfter.toNumber()).to.equal(14);
            expect(UsersWhitelistRootHashAfter).to.equal('0xb38540218109b86482322426ad7fb1c83ed332400113b41517b41acdccb470b4')
            expect(PublicMintingLimitAfter.toNumber()).to.equal(81);


        }); // end of it block


        it('The updatePublicSaleStatus() function is working properly.', async function () {
            const { LandContractProxy, owner } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let PublicSaleStatusBefore = await LandContractProxy.isPublicSaleActive();
            console.log("This is the public sale status before update function call:", PublicSaleStatusBefore);
            await LandContractProxy.updatePublicSaleStatus(true);
            let PublicSaleStatusAfter = await LandContractProxy.isPublicSaleActive();
            console.log("This is the public sale status after update function call:", PublicSaleStatusAfter);
            expect(PublicSaleStatusAfter).to.be.true;

        }); // end of it block

    }); //end of describe

    describe("Mint,Add and Get Functions", function () {

        it('The mintLandWhitelistAdmin() function is working properly.', async function () {
            const { LandContractProxy, owner, addr1 } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(addr1.address, 1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfAdminBeforeMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintLandWhitelistAdmin() function:", balanceOfAdminBeforeMint.toNumber());
            let PlatformMintingCountBeforeMint = await LandContractProxy.platformMintingCount();
            console.log("This is the platform minting count before calling mintLandWhitelistAdmin() function:", PlatformMintingCountBeforeMint.toNumber());
            await LandContractProxy.updateMintingStatus(true);
            await LandContractProxy.connect(addr1).mintLandWhitelistAdmin(addr1.address, 1, "10", "10", "[{'longitude': '10', 'latitude':'10'}]");
            let balanceOfAdminAfterMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintLandWhitelistAdmin() function:", balanceOfAdminAfterMint.toNumber());
            let PlatformMintingCountAfterMint = await LandContractProxy.platformMintingCount();
            console.log("This is the platform minting count after calling mintLandWhitelistAdmin() function:", PlatformMintingCountAfterMint.toNumber());
            expect(balanceOfAdminAfterMint.toNumber()).to.equal(1);
            expect(PlatformMintingCountAfterMint.toNumber()).to.equal(1);

        });// end of it block


        it('The mintLandPublic() function is working properly.', async function () {
            const { LandContractProxy, owner, addr1 } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfUserBeforeMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintLandPublic() function:", balanceOfUserBeforeMint.toNumber());
            await LandContractProxy.updateMintingStatus(true);
            await LandContractProxy.updatePublicSaleStatus(true);
            let PublicSaleStatus = await LandContractProxy.isPublicSaleActive();
            console.log("This is the public sale status after update function call:", PublicSaleStatus);
            let PublicUsersMintingCountBeforeMint = await LandContractProxy.publicUsersMintingCount();
            console.log("This is the public users minting count before calling the mintLandPublic() function:", PublicUsersMintingCountBeforeMint.toNumber());
            await LandContractProxy.connect(addr1).mintLandPublic(addr1.address, 1, "20", "20", "[{'longitude': '20', 'latitude':'20'}]");
            let balanceOfUserAfterMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintLandPublic() function:", balanceOfUserAfterMint.toNumber());
            let PublicUsersMintingCountAfterMint = await LandContractProxy.publicUsersMintingCount();
            console.log("This is the public users minting count after calling the mintLandPublic() function:", PublicUsersMintingCountAfterMint.toNumber());
            expect(balanceOfUserAfterMint.toNumber()).to.equal(1);
            expect(PublicUsersMintingCountAfterMint.toNumber()).to.equal(1);

        });// end of it block


        it('The mintLandWhitelistUsers() function is working properly.', async function () {

            const { LandContractProxy, owner, addr1 } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(addr1.address, 1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfUserBeforeMint = await LandContractProxy.balanceOf(owner.address);
            console.log("This is the NFT balance of addr1 before calling mintLandWhitelistAdmin() function:", balanceOfUserBeforeMint.toNumber());
            await LandContractProxy.connect(owner).updateMintingStatus(true);
            let whitelistUsersMintingCountBeforeMint = await LandContractProxy.whitelistUsersMintingCount();
            console.log("This is the whitelist users minting count before calling mintLandWhitelistAdmin() function:", whitelistUsersMintingCountBeforeMint.toNumber());

            let whitelistAddresses = [
                '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
                '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
                '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
                '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
                '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65',
                '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
                '0x976EA74026E726554dB657fA54763abd0C3a0aa9',
            ]
            const leafNodes = whitelistAddresses.map((addr) => keccak256(addr))
            const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true })
            const rootHash = merkleTree.getRoot();
            const hexProof = merkleTree.getHexProof(keccak256(addr1.address));
            console.log("hexProof", hexProof)
            console.log("This is the root hash before calling the updateWhitelistUsers() function:", await LandContractProxy.usersWhitelistRootHash());
            await LandContractProxy.connect(owner).updateWhitelistUsers(whitelistAddresses.length, rootHash);
            console.log("This is the root hash after calling the updateWhitelistUsers() function", await LandContractProxy.usersWhitelistRootHash());

            await LandContractProxy.connect(addr1).mintLandWhitelistUsers(addr1.address, 1, "30", "30", "[{'longitude': '30', 'latitude':'30'}]", hexProof);
            let balanceOfUserAfterMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintLandWhitelistAdmin() function:", balanceOfUserAfterMint.toNumber());
            let whitelistUsersMintingCountAfterMint = await LandContractProxy.whitelistUsersMintingCount();
            console.log("This is the whitelist users minting count after calling mintLandWhitelistAdmin() function:", whitelistUsersMintingCountAfterMint.toNumber());
            expect(balanceOfUserAfterMint.toNumber()).to.equal(1);
            expect(whitelistUsersMintingCountAfterMint.toNumber()).to.equal(1);

        }); // end of it block


        it('The getLandByID() function is working properly.', async function () {
            const { LandContractProxy, owner, addr1 } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(addr1.address, 1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfAdminBeforeMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintLandWhitelistAdmin() function:", balanceOfAdminBeforeMint.toNumber());
            let PlatformMintingCountBeforeMint = await LandContractProxy.platformMintingCount();
            console.log("This is the platform minting count before calling mintLandWhitelistAdmin() function:", PlatformMintingCountBeforeMint.toNumber());
            await LandContractProxy.updateMintingStatus(true);
            await LandContractProxy.connect(addr1).mintLandWhitelistAdmin(addr1.address, 1, "10", "10", "[{'longitude': '100', 'latitude':'100'}]");
            let balanceOfAdminAfterMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintLandWhitelistAdmin() function:", balanceOfAdminAfterMint.toNumber());
            let PlatformMintingCountAfterMint = await LandContractProxy.platformMintingCount();
            console.log("This is the platform minting count after calling mintLandWhitelistAdmin() function:", PlatformMintingCountAfterMint.toNumber());
            let LandInfoByID = await LandContractProxy.getLandById(1);
            console.log("This is the land ID `1` data by ID:", LandInfoByID);

        }); //end of it block

        it('The getLandsByAddress() function is working properly.', async function () {
            const { LandContractProxy, owner, addr1 } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfUserBeforeMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintLandPublic() function:", balanceOfUserBeforeMint.toNumber());
            await LandContractProxy.updateMintingStatus(true);
            await LandContractProxy.updatePublicSaleStatus(true);
            let PublicSaleStatus = await LandContractProxy.isPublicSaleActive();
            console.log("This is the public sale status after update function call:", PublicSaleStatus);
            let PublicUsersMintingCountBeforeMint = await LandContractProxy.publicUsersMintingCount();
            console.log("This is the public users minting count before calling the mintLandPublic() function:", PublicUsersMintingCountBeforeMint.toNumber());
            await LandContractProxy.connect(addr1).mintLandPublic(addr1.address, 1, "20", "20", "[{'longitude': '20', 'latitude':'20'}]");
            let balanceOfUserAfterMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintLandPublic() function:", balanceOfUserAfterMint.toNumber());
            let PublicUsersMintingCountAfterMint = await LandContractProxy.publicUsersMintingCount();
            console.log("This is the public users minting count after calling the mintLandPublic() function:", PublicUsersMintingCountAfterMint.toNumber());
            let landInfoByAddress = await LandContractProxy.getLandsByAddress(addr1.address);
            console.log("This is the Land ID `1` data by address:", landInfoByAddress);

        }); //end of it block


    }); //end of describe


    describe("tokenURI Function", function () {

        it('The tokenURI() function is working properly.', async function () {
            const { LandContractProxy, owner, addr1 } = await loadFixture(deployLandContractV1);
            await LandContractProxy.addWhitelistAdmin(addr1.address, 1);
            await LandContractProxy.addWhitelistAdmin(owner.address, 2);
            let balanceOfAdminBeforeMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 before calling mintLandWhitelistAdmin() function:", balanceOfAdminBeforeMint.toNumber());
            let PlatformMintingCountBeforeMint = await LandContractProxy.platformMintingCount();
            console.log("This is the platform minting count before calling mintLandWhitelistAdmin() function:", PlatformMintingCountBeforeMint.toNumber());
            await LandContractProxy.updateMintingStatus(true);
            await LandContractProxy.connect(addr1).mintLandWhitelistAdmin(addr1.address, 1, "10", "10", "[{'longitude': '10', 'latitude':'10'}]");
            let balanceOfAdminAfterMint = await LandContractProxy.balanceOf(addr1.address);
            console.log("This is the NFT balance of addr1 after calling mintLandWhitelistAdmin() function:", balanceOfAdminAfterMint.toNumber());
            let PlatformMintingCountAfterMint = await LandContractProxy.platformMintingCount();
            console.log("This is the platform minting count after calling mintLandWhitelistAdmin() function:", PlatformMintingCountAfterMint.toNumber());
            let tokenURI = await LandContractProxy.tokenURI(1);
            console.log("This is required tokenURI for land ID `1` :", tokenURI);
            expect(tokenURI).to.equal("https://dev-services.wrld.xyz/assets/getLandMetadataById/1");

        }); //end of it block

    }); // end of describe block 




}); //end of main LandContractV1 describe
