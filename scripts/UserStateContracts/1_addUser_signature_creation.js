var Web3 = require('web3');
var web3 = new Web3();
require('dotenv').config();


const encode_value = web3.eth.abi.encodeParameter(
    {

        "UserEncryption": {
            "email": 'string',
            "walletAddresses": 'address',
            "stateMetadataHash": 'string',
            "gameStateMetadataHash": 'string',
            "gameIDs": 'uint256'
        }
    },
    {
        "email": "moiz",
        "walletAddresses": "0x4a1F61b785E710451A6c11eB236285735e2Bb75a",
        "stateMetadataHash": "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
        "gameStateMetadataHash": "QmQhQT6NcCQC2JMRRPg8qshj4vf4W4pKSfK1HtEH1LjMGB",
        "gameIDs": 1
    }
);
const privateKey = process.env.PRIVATEKEY;
const structHash = web3.utils.keccak256(encode_value);
const signature = web3.eth.accounts.sign(structHash, privateKey);
const signerAddress = web3.eth.accounts.recover(structHash, signature.signature);

console.log("This is the abi.encode value similar to on chain:", encode_value);
console.log("\nThis is the structHash value similar to on chain:", structHash);
console.log("\nThe require signature is :", signature.signature);
console.log("\nThis is the required signature address :", signerAddress);
