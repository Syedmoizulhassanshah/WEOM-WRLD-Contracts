const ethers = require('ethers')
require('dotenv').config()

const privateKey = process.env.PRIVATEKEY
const signer = new ethers.Wallet(privateKey)
const abiCoder = ethers.utils.defaultAbiCoder

const encodeUserParameters = abiCoder.encode(
  ['tuple(uint256, address)'],
  [[1, '0x025Add8324e11fE364661fD08267133c631F56AF']],
)

async function generateSignature() {
  const hashParameters = ethers.utils.keccak256(encodeUserParameters)
  const arrayifyParameters = ethers.utils.arrayify(hashParameters)
  const signature = await signer.signMessage(arrayifyParameters)

  console.log('Signature is :', signature)
}

generateSignature()
