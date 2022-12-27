const creatorcontract = require("./abi.json")
const ethers = require("ethers")
const drawwinner = require("./keeper")
require("dotenv").config()

const rpc = process.env.rpc

async function main() {
    const provider = new ethers.providers.WebSocketProvider(rpc)
    const CONTRACT_ADDRESS = creatorcontract.address
    const CONTRACT_ABI = creatorcontract.abi
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider)
    contract.on("Created", (creator, roundCreated, timeCreated) => {
        console.log("Created")
        console.log(
            `${creator} created game round ${roundCreated.toString()} at epoch time ${timeCreated}`
        )
        drawwinner(parseInt(roundCreated.toString()))
    })
    contract.on("Joined", (player, roundJoined) => {
        console.log("Joined")
        console.log(player, "joined game round", roundJoined.toString())
    })
    contract.on("Drawed", (gameRound, playersNum, winningNumbers, bingoRound) => {
        console.log("Drawed")
        console.log(
            `game round ${gameRound.toString()} drawed, there are ${playersNum.toString()} players, winning number is ${winningNumbers.toString()}, and bingo is in round ${bingoRound.toString()}(0 means no bingo)`
        )
    })
    contract.on("Claimed", (player, Claimed) => {
        console.log("Claimed")
        console.log(player, "claimed", Claimed.toString(), "token")
    })
}

main()
