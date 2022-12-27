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
    const winner = await contract.checkWinner(2, "0xA6162ae3A7Af9D8B4c8fb6AEc1D397BC9c29f276")
    console.log(`winnerstates:`, winner[0].toString())
    console.log(`prize:`, winner[1].toString())
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
