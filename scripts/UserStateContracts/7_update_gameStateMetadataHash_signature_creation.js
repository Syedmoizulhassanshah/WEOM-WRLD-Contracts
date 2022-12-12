const ethers = require('ethers')
require('dotenv').config()

const privateKey = process.env.PRIVATEKEY
const signer = new ethers.Wallet(privateKey)
const abiCoder = ethers.utils.defaultAbiCoder

const encodeUserParameters = abiCoder.encode(
  ['tuple(uint256, string, uint256)'],
  [[1, 'Q3cnhWWo9BSSssEXjvpU9kp6aLYjmD2xTSCcewoiTmAFVy', 1]],
)

async function generateSignature() {
  const hashParameters = ethers.utils.keccak256(encodeUserParameters)
  const arrayifyParameters = ethers.utils.arrayify(hashParameters)
  const signature = await signer.signMessage(arrayifyParameters)

  console.log('Signature is :', signature)
}

generateSignature()
