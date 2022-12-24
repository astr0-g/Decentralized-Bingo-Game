const { assert, expect } = require("chai")
const { parseEther } = require("ethers/lib/utils")
const { network, deployments, ethers, getNamedAccounts } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Bingo test", function () {
          let nftmarketplace,
              deployer,
              player1,
              player2,
              player3,
              player4,
              player5,
              player6,
              player7,
              player8,
              player9
          const fee = ethers.utils.parseEther("1")
          beforeEach(async () => {
              deployer = (await getNamedAccounts()).deployer
              accounts = await ethers.getSigners()
              player1 = accounts[1]
              player2 = accounts[2]
              player3 = accounts[3]
              player4 = accounts[4]
              player5 = accounts[5]
              player6 = accounts[6]
              player7 = accounts[7]
              player8 = accounts[8]
              player9 = accounts[9]
              await deployments.fixture(["all"])
              Bingo = await ethers.getContract("Bingo")
              BingoToken = await ethers.getContract("BingoToken")
          })

          describe("Construtor", () => {
              it("trun", async () => {
                  const result = await Bingo.trun()
                  console.log(result.toString())
              })

              it("mint BingoToken", async () => {
                  await BingoToken.mint()
                  const result = await BingoToken.balanceOf(deployer)
                  assert.equal(result.toString(), 1 * 10 ** 18)
              })
              it("Test start new game with transfer BingoToken", async () => {
                  await BingoToken.mint()
                  await BingoToken.approve(Bingo.address, fee)
                  await Bingo.startNewGameWithBet()
                  const result = await BingoToken.balanceOf(Bingo.address)
                  assert.equal(result.toString(), 1 * 10 ** 18)
                  Bingo.startNewGameWithBet()
              })
              it("Test start new game and check player game board", async () => {
                  await BingoToken.mint()
                  await BingoToken.approve(Bingo.address, fee)
                  await Bingo.startNewGameWithBet()
                  const result = await BingoToken.balanceOf(Bingo.address)
                  assert.equal(result.toString(), 1 * 10 ** 18)
                  const gameRoundNow = await Bingo.gameRoundNow()
                  const playercards = await Bingo.readPlayerGameBoard(deployer, gameRoundNow)
                  console.log(`player playBoardNumbers:${playercards.toString()}`)
              })
              it("two players join same game and check their game board", async () => {
                  await BingoToken.connect(player1).mint()
                  await BingoToken.connect(player1).approve(Bingo.address, fee)
                  await Bingo.connect(player1).startNewGameWithBet()
                  const result = await BingoToken.balanceOf(Bingo.address)
                  assert.equal(result.toString(), 1 * 10 ** 18)
                  const gameRoundNow = await Bingo.gameRoundNow()

                  await BingoToken.connect(player2).mint()
                  await BingoToken.connect(player2).approve(Bingo.address, fee)
                  await Bingo.connect(player2).joinCurrentGameWithBet(gameRoundNow)
                  const result2 = await BingoToken.balanceOf(Bingo.address)
                  assert.equal(result2.toString(), 2 * 10 ** 18)

                  const player1cards = await Bingo.readPlayerGameBoard(
                      player1.address,
                      gameRoundNow
                  )
                  console.log(`player 1 playBoardNumbers:${player1cards.toString()}`)
                  const player2cards = await Bingo.readPlayerGameBoard(
                      player2.address,
                      gameRoundNow
                  )
                  console.log(`player 2 playBoardNumbers:${player2cards.toString()}`)
              })
              it("two players join same game and check their awards", async () => {
                  await BingoToken.connect(player1).mint()
                  await BingoToken.connect(player1).approve(Bingo.address, fee)
                  await Bingo.connect(player1).startNewGameWithBet()
                  const result = await BingoToken.balanceOf(Bingo.address)
                  assert.equal(result.toString(), 1 * 10 ** 18)
                  const gameRoundNow = await Bingo.gameRoundNow()

                  await BingoToken.connect(player2).mint()
                  await BingoToken.connect(player2).approve(Bingo.address, fee)
                  await Bingo.connect(player2).joinCurrentGameWithBet(gameRoundNow)
                  const result2 = await BingoToken.balanceOf(Bingo.address)
                  assert.equal(result2.toString(), 2 * 10 ** 18)

                  const player1cards = await Bingo.readPlayerGameBoard(
                      player1.address,
                      gameRoundNow
                  )
                  console.log(`player 1 playBoardNumbers:${player1cards.toString()}`)
                  const player2cards = await Bingo.readPlayerGameBoard(
                      player2.address,
                      gameRoundNow
                  )
                  console.log(`player 2 playBoardNumbers:${player2cards.toString()}`)
                  const joinDuration = await Bingo.joinDuration()
                  const turnDuration = await Bingo.turnDuration()
                  await network.provider.send("evm_increaseTime", [
                      joinDuration.toNumber() + turnDuration.toNumber() + 1,
                  ])
                  await Bingo.connect(player1).drawWinnerOrClaimRewrads(gameRoundNow)
                //   await Bingo.connect(player2).drawWinnerOrClaimRewrads(gameRoundNow)
              })
          })
      })
