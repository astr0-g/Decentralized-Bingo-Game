const creatorcontract = require("./abi.json")
const ethers = require("ethers")
require("dotenv").config()
const rpc = process.env.rpc
async function main() {
    const provider = new ethers.providers.WebSocketProvider(rpc)
    const CONTRACT_ADDRESS = creatorcontract.address
    const CONTRACT_ABI = creatorcontract.abi
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider)
    const playerGameBoard = await contract.getPlayerArray(2)
    console.log(`players in round 2 are:`, playerGameBoard)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
