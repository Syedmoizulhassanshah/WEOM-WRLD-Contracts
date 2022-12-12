const ethers = require('ethers')
require('dotenv').config()

const privateKey = process.env.PRIVATEKEY
const signer = new ethers.Wallet(privateKey)
const abiCoder = ethers.utils.defaultAbiCoder

const encodeUserParameters = abiCoder.encode(
  ['tuple(uint256, uint256, address)'],
  [[1, 0, '0xe2b5a5b611643c7e0e4D705315bf580B75472d7b']],
)

async function generateSignature() {
  const hashParameters = ethers.utils.keccak256(encodeUserParameters)
  const arrayifyParameters = ethers.utils.arrayify(hashParameters)
  const signature = await signer.signMessage(arrayifyParameters)

  console.log('Signature is :', signature)
}

generateSignature()