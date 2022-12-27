const creatorcontract = require("./abi.json")
const ethers = require("ethers")
require("dotenv").config()

const rpc = process.env.rpc
async function main() {
    const provider = new ethers.providers.WebSocketProvider(rpc)
    const CONTRACT_ADDRESS = creatorcontract.address
    const CONTRACT_ABI = creatorcontract.abi
    const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider)
    const gameRoundNow = await contract.gameRoundNow()
    const admin = await contract.admin()
    const joinDuration = await contract.joinDuration()
    const turnDuration = await contract.turnDuration()
    const BingoToken = await contract.BingoToken()
    const betAmountForBINGO = await contract.betAmountForBINGO()
    const returnBet = await contract.returnBet()
    const maxPlayerNum = await contract.maxPlayerNum()
    console.log(`newest game round is ${gameRoundNow.toString()}`)
    console.log(`admin is ${admin}`)
    console.log(`joinDuration is ${joinDuration.toString()} seconds`)
    console.log(`turnDuration is ${turnDuration.toString()} seconds`)
    console.log(`BingoToken contract address is ${BingoToken}`)
    console.log(`bet amount for BINGO game is ${ethers.utils.formatUnits(betAmountForBINGO)}`)
    console.log(`return Bet is ${returnBet}`)
    console.log(`max player numbers in one game is ${maxPlayerNum.toString()}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
