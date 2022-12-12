const ethers = require('ethers')
require('dotenv').config()

const privateKey = process.env.PRIVATEKEY
const signer = new ethers.Wallet(privateKey)
const abiCoder = ethers.utils.defaultAbiCoder

console.log(signer);
const encodeUserParameters = abiCoder.encode(
  ['tuple(uint256, string, address, string)'],
  [
    [
      10003,
      "farhan.zia@netsoltech.com",
      "0x4FA729a061cBbd1695DEC8a3c0f5f54d4260d16B",
      "QmcfhWWo9BSSssFXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy",
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
