const creatorcontract = require("./abi.json")
const ethers = require("ethers")
require("dotenv").config()
function display5x5matrix(e) {
    for (k = 0; k < 5; k++) {
        console.log(
            e.slice(",")[k * 5].toString(),
            e.slice(",")[k * 5 + 1].toString(),
            e.slice(",")[k * 5 + 2].toString(),
            e.slice(",")[k * 5 + 3].toString(),
            e.slice(",")[k * 5 + 4].toString()
        )
    }
}
const rpc = process.env.rpc
async function main() {
    const provider = new ethers.providers.WebSocketProvider(rpc)
    const CONTRACT_ADDRESS = creatorcontract.address
    const CONTRACT_ABI = creatorcontract.abi
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider)
    const playerGameBoard = await contract.getPlayerGameBoard(
        "0x51580828DF98f7d9Bb09a0410795183fe6183E14",
        2
    )
    console.log("player game board in this round 2 is:")
    display5x5matrix(playerGameBoard)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
