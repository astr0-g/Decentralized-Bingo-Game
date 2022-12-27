const creatorcontract = require("./abi.json")
const ethers = require("ethers")
const sleep = (ms) => new Promise((res) => setTimeout(res, ms))
require("dotenv").config()
const WALLET_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY
const rpc = process.env.rpc
const provider = new ethers.providers.WebSocketProvider(rpc)
const CONTRACT_ADDRESS = creatorcontract.address
const CONTRACT_ABI = creatorcontract.abi
const signer = new ethers.Wallet(WALLET_PRIVATE_KEY, provider)
const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer)
module.exports = async function drawwinner(e) {
    console.log(`wait for 370s to call drawinner`)
    await sleep(370000)
    console.log(`call now`)
    const tx = await contract.drawWinner(e)
    await tx.wait()
}
