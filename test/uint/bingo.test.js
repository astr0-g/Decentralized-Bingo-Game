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
          })

          describe("Construtor", () => {
              it("bet game", async () => {
                  await Bingo.bet({ value: fee })
                  const result = await Bingo.read()
                  console.log(result.toString())
                  await expect(Bingo.bet({ value: fee })).to.be.reverted
              })
              it("getreward", async () => {
                  await Bingo.bet({ value: fee })
                  await Bingo.reveal()
                  await Bingo.bet({ value: fee })
                //   await Bingo.reveal()
                  
              })
          })
      })
