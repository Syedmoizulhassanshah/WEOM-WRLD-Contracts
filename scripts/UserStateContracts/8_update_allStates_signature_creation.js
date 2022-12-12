const ethers = require('ethers')
require('dotenv').config()

const privateKey = process.env.PRIVATEKEY
const signer = new ethers.Wallet(privateKey)
const abiCoder = ethers.utils.defaultAbiCoder

const encodeUserParameters = abiCoder.encode(
  ['tuple(uint256, address, string, string, uint256, uint256, uint256)'],
  [
    [
      1,
      '0xa864f883E78F67a005a94B1B32Bf3375dfd121E6',
      'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
      'CmSwPtZ8dpJdDKTaKrK6VfPjZ4DpQtrrt1HMUhe6MQngaV',
      0,
      0,
      0,
    ],
  ],
)

async function generateSignature() {
  const hashParameters = ethers.utils.keccak256(encodeUserParameters)
  const arrayifyParameters = ethers.utils.arrayify(hashParameters)
  const signature = await signer.signMessage(arrayifyParameters)

  console.log('Signature is :', signature)
}

generateSignature()
