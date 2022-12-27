const creatorcontract = require("./abi.json")
const ethers = require("ethers")
const FormData = require("form-data")
const fetch = require("node-fetch")
require("dotenv").config()
const rpc = process.env.rpc
async function main() {
    const provider = new ethers.providers.WebSocketProvider(rpc)
    const CONTRACT_ADDRESS = creatorcontract.address
    const CONTRACT_ABI = creatorcontract.abi
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider)
    const getRoundBingoResult = await contract.getRoundBingoResult(2)
    console.log(`Bingo in round 2 is:`, getRoundBingoResult[0].toString())
    console.log(`Winning in round 2 are:`, getRoundBingoResult[1].toString())
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
