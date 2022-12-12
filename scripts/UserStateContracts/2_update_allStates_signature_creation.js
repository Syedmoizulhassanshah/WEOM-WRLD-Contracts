var Web3 = require('web3');
var web3 = new Web3();
require('dotenv').config();


const encode_value = web3.eth.abi.encodeParameter(
    {

        "UpdateAllStatesEncryption": {
            "walletAddresses": 'address',
            "stateMetadataHash": 'string',
            "gameStateMetadataHash": 'string',
            "gameIDs": 'uint256'
        }
    },
    {
        "walletAddresses": "0xa864f883E78F67a005a94B1B32Bf3375dfd121E6",
        "stateMetadataHash": "QmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV",
        "gameStateMetadataHash": "QmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV",
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
