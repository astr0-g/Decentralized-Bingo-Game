const { assert, expect } = require("chai");
const { parseEther } = require("ethers/lib/utils");
const { network, deployments, ethers, getNamedAccounts } = require("hardhat");
const { developmentChains } = require("../../helper-hardhat-config");
function display5x5matrix(e) {
  for (k = 0; k < 5; k++) {
    console.log(
      e.slice(",")[k * 5].toString(),
      e.slice(",")[k * 5 + 1].toString(),
      e.slice(",")[k * 5 + 2].toString(),
      e.slice(",")[k * 5 + 3].toString(),
      e.slice(",")[k * 5 + 4].toString()
    );
  }
}
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
        player9;
      const fee = ethers.utils.parseEther("1");
      beforeEach(async () => {
        deployer = (await getNamedAccounts()).deployer;
        accounts = await ethers.getSigners();
        player1 = accounts[1];
        player2 = accounts[2];
        player3 = accounts[3];
        player4 = accounts[4];
        player5 = accounts[5];
        player6 = accounts[6];
        player7 = accounts[7];
        player8 = accounts[8];
        player9 = accounts[9];
        await deployments.fixture(["all"]);
        Bingo = await ethers.getContract("Bingo");
        BingoToken = await ethers.getContract("BingoToken");
      });

      describe("Construtor", () => {
        it("Test mint BingoToken", async () => {
          await BingoToken.mint();
          const result = await BingoToken.balanceOf(deployer);
          assert.equal(result.toString(), 1 * 10 ** 18);
        });
        it("Test setConfig", async () => {
          const joinDuration = 10;
          const turnDuration = 10;
          const betAmountForBINGO = 10;
          await Bingo.setConfig(joinDuration, turnDuration, betAmountForBINGO);
          const joinDurationNow = await Bingo.joinDuration();
          const turnDurationNow = await Bingo.turnDuration();
          const betAmountForBINGONow = await Bingo.betAmountForBINGO();
          assert.equal(joinDurationNow.toString(), joinDuration);
          assert.equal(turnDurationNow.toString(), turnDuration);
          assert.equal(betAmountForBINGONow.toString(), betAmountForBINGO);
          await expect(
            Bingo.connect(player1).setConfig(
              joinDuration,
              turnDuration,
              betAmountForBINGO
            )
          ).to.be.revertedWith("error__notAdmin");
        });
        it("Test start new game with transfer BingoToken and player cannot join the same game.", async () => {
          await BingoToken.mint();
          await BingoToken.approve(Bingo.address, fee);
          await Bingo.startNewGameWithBet();
          const result = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result.toString(), 1 * 10 ** 18);
          const gameRoundNow = await Bingo.gameRoundNow();
          await BingoToken.mint();
          await BingoToken.approve(Bingo.address, fee);
          await expect(
            Bingo.joinCurrentGameWithBet(gameRoundNow)
          ).to.be.revertedWith("error__inGameAlready");
        });
        it("Test start new game and check player game board", async () => {
          await BingoToken.mint();
          await BingoToken.approve(Bingo.address, fee);
          await Bingo.startNewGameWithBet();
          const result = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result.toString(), 1 * 10 ** 18);
          const gameRoundNow = await Bingo.gameRoundNow();
          const playercards = await Bingo.getPlayerGameBoard(
            deployer,
            gameRoundNow
          );
          console.log(`player playBoardNumbers:`);
          display5x5matrix(playercards);
        });

        it("two players join same game and check their game board", async () => {
          await BingoToken.connect(player1).mint();
          await BingoToken.connect(player1).approve(Bingo.address, fee);
          await Bingo.connect(player1).startNewGameWithBet();
          const result = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result.toString(), 1 * 10 ** 18);
          const gameRoundNow = await Bingo.gameRoundNow();

          await BingoToken.connect(player2).mint();
          await BingoToken.connect(player2).approve(Bingo.address, fee);
          await Bingo.connect(player2).joinCurrentGameWithBet(gameRoundNow);
          const result2 = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result2.toString(), 2 * 10 ** 18);

          const player1cards = await Bingo.getPlayerGameBoard(
            player1.address,
            gameRoundNow
          );
          //   console.log(`player 1 playBoardNumbers:${player1cards.toString()}`);
          const player2cards = await Bingo.getPlayerGameBoard(
            player2.address,
            gameRoundNow
          );
          //   console.log(`player 2 playBoardNumbers:${player2cards.toString()}`);
        });
        it("only one player join a game and get their bet token back", async () => {
          console.log(`Game strating...`);
          console.log(`player 1 joinning...`);
          await BingoToken.connect(player1).mint();
          await BingoToken.connect(player1).approve(Bingo.address, fee);
          await Bingo.connect(player1).startNewGameWithBet();
          const result = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result.toString(), 1 * 10 ** 18);
          const gameRoundNow = await Bingo.gameRoundNow();
          const joinDuration = await Bingo.joinDuration();
          const turnDuration = await Bingo.turnDuration();
          console.log(`wait for time pass join duration and draw duration`);
          await network.provider.send("evm_increaseTime", [
            joinDuration.toNumber() + turnDuration.toNumber() + 1,
          ]);
          await Bingo.connect(player1).drawWinnerOrClaimPrize(gameRoundNow);
          const player1balance = await BingoToken.balanceOf(player1.address);
          console.log(`player 1 balance:${player1balance.toString()}`);
          assert.equal(player1balance.toString(), fee);
        });
        it("two players join same game and check their awards", async () => {
          console.log(`Game strating...`);
          console.log(`player 1 joinning...`);
          await BingoToken.connect(player1).mint();
          await BingoToken.connect(player1).approve(Bingo.address, fee);
          await Bingo.connect(player1).startNewGameWithBet();
          const result = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result.toString(), 1 * 10 ** 18);
          const gameRoundNow = await Bingo.gameRoundNow();
          console.log(`player 2 joinning...`);
          await BingoToken.connect(player2).mint();
          await BingoToken.connect(player2).approve(Bingo.address, fee);
          await Bingo.connect(player2).joinCurrentGameWithBet(gameRoundNow);
          const result2 = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result2.toString(), 2 * 10 ** 18);

          const player1cards = await Bingo.getPlayerGameBoard(
            player1.address,
            gameRoundNow
          );
          console.log(`player 1 playBoardNumbers:`);
          console.log(`-------------------------------`);
          display5x5matrix(player1cards);
          console.log(`-------------------------------`);
          //   const array1 = JSON.parse(array.slice(0, 5));
          const player2cards = await Bingo.getPlayerGameBoard(
            player2.address,
            gameRoundNow
          );
          console.log(`player 2 playBoardNumbers:`);
          console.log(`-------------------------------`);
          display5x5matrix(player2cards);
          console.log(`-------------------------------`);
          const joinDuration = await Bingo.joinDuration();
          const turnDuration = await Bingo.turnDuration();
          console.log(`wait for time pass join duration and draw duration`);
          await network.provider.send("evm_increaseTime", [
            joinDuration.toNumber() + turnDuration.toNumber() + 1,
          ]);
          console.log(`player draw results and claim winning.`);
          await Bingo.connect(player1).drawWinnerOrClaimPrize(gameRoundNow);
          await Bingo.connect(player2).drawWinnerOrClaimPrize(gameRoundNow);
          const player1balance = await BingoToken.balanceOf(player1.address);
          const player2balance = await BingoToken.balanceOf(player2.address);
          const gameReuslt = await Bingo.getRoundBingoResult(gameRoundNow);
          console.log(`Bingo result: ${gameReuslt[0]}`);
          const player1win = await Bingo.checkWinner(
            gameRoundNow,
            player1.address
          );
          const player2win = await Bingo.checkWinner(
            gameRoundNow,
            player2.address
          );

          console.log(`player 1 win, Prize:${player1win.toString()}`);
          console.log(`player 2 win, Prize:${player2win.toString()}`);
          console.log(`winning numbers result: ${gameReuslt[1].toString()}`);
          console.log(`player 1 balance:${player1balance.toString()}`);
          console.log(`player 2 balance:${player2balance.toString()}`);
        });
        it("three players join same game and check their awards for multiple times to check accurate gas cost", async () => {
          for (i = 0; i < 1; i++) {
            console.log(`No.${i + 1} Game strating...`);
            console.log(`player 1 joinning...`);
            await BingoToken.connect(player1).mint();
            await BingoToken.connect(player1).approve(Bingo.address, fee);
            await Bingo.connect(player1).startNewGameWithBet();
            const result = await BingoToken.balanceOf(Bingo.address);
            assert.equal(result.toString(), 1 * 10 ** 18);
            const gameRoundNow = await Bingo.gameRoundNow();
            console.log(`player 2 joinning...`);
            await BingoToken.connect(player2).mint();
            await BingoToken.connect(player2).approve(Bingo.address, fee);
            await Bingo.connect(player2).joinCurrentGameWithBet(gameRoundNow);
            const result2 = await BingoToken.balanceOf(Bingo.address);
            assert.equal(result2.toString(), 2 * 10 ** 18);
            console.log(`player 3 joinning...`);
            await BingoToken.connect(player3).mint();
            await BingoToken.connect(player3).approve(Bingo.address, fee);
            await Bingo.connect(player3).joinCurrentGameWithBet(gameRoundNow);
            const result3 = await BingoToken.balanceOf(Bingo.address);
            assert.equal(result3.toString(), 3 * 10 ** 18);

            const player1cards = await Bingo.getPlayerGameBoard(
              player1.address,
              gameRoundNow
            );
            console.log(`player 1 playBoardNumbers:`);
            console.log(`-------------------------------`);
            display5x5matrix(player1cards);
            console.log(`-------------------------------`);
            const player2cards = await Bingo.getPlayerGameBoard(
              player2.address,
              gameRoundNow
            );
            console.log(`player 2 playBoardNumbers:`);
            console.log(`-------------------------------`);
            display5x5matrix(player2cards);
            console.log(`-------------------------------`);

            const player3cards = await Bingo.getPlayerGameBoard(
              player3.address,
              gameRoundNow
            );
            console.log(`player 3 playBoardNumbers:`);
            console.log(`-------------------------------`);
            display5x5matrix(player3cards);
            console.log(`-------------------------------`);
            const joinDuration = await Bingo.joinDuration();
            const turnDuration = await Bingo.turnDuration();
            console.log(`wait for time pass join duration and draw duration`);
            await network.provider.send("evm_increaseTime", [
              joinDuration.toNumber() + turnDuration.toNumber() + 1,
            ]);
            console.log(`player draw results and claim winning.`);
            await Bingo.connect(player1).drawWinnerOrClaimPrize(gameRoundNow);
            await Bingo.connect(player2).drawWinnerOrClaimPrize(gameRoundNow);
            await Bingo.connect(player3).drawWinnerOrClaimPrize(gameRoundNow);
            const player1balance = await BingoToken.balanceOf(player1.address);
            const player2balance = await BingoToken.balanceOf(player2.address);
            const player3balance = await BingoToken.balanceOf(player3.address);
            const gameReuslt = await Bingo.getRoundBingoResult(gameRoundNow);
            console.log(`Bingo result: ${gameReuslt[0]}`);
            const player1win = await Bingo.checkWinner(
              gameRoundNow,
              player1.address
            );
            const player2win = await Bingo.checkWinner(
              gameRoundNow,
              player2.address
            );
            const player3win = await Bingo.checkWinner(
              gameRoundNow,
              player3.address
            );
            console.log(`player 1 win, Prize:${player1win.toString()}`);
            console.log(`player 2 win, Prize:${player2win.toString()}`);
            console.log(`player 3 win, Prize:${player3win.toString()}`);
            console.log(`winning numbers result: ${gameReuslt[1].toString()}`);
            console.log(`player 1 player1balance:${player1balance.toString()}`);
            console.log(`player 2 player2balance:${player2balance.toString()}`);
            console.log(`player 3 player2balance:${player3balance.toString()}`);
          }
        });
        it("five players join same game and check their awards for multiple times to check accurate gas cost", async () => {
          console.log(`No.${i + 1} Game strating...`);
          console.log(`player 1 joinning...`);
          await BingoToken.connect(player1).mint();
          await BingoToken.connect(player1).approve(Bingo.address, fee);
          await Bingo.connect(player1).startNewGameWithBet();
          const result = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result.toString(), 1 * 10 ** 18);
          const gameRoundNow = await Bingo.gameRoundNow();
          console.log(`player 2 joinning...`);
          await BingoToken.connect(player2).mint();
          await BingoToken.connect(player2).approve(Bingo.address, fee);
          await Bingo.connect(player2).joinCurrentGameWithBet(gameRoundNow);
          const result2 = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result2.toString(), 2 * 10 ** 18);
          console.log(`player 3 joinning...`);
          await BingoToken.connect(player3).mint();
          await BingoToken.connect(player3).approve(Bingo.address, fee);
          await Bingo.connect(player3).joinCurrentGameWithBet(gameRoundNow);
          const result3 = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result3.toString(), 3 * 10 ** 18);
          console.log(`player 4 joinning...`);
          await BingoToken.connect(player4).mint();
          await BingoToken.connect(player4).approve(Bingo.address, fee);
          await Bingo.connect(player4).joinCurrentGameWithBet(gameRoundNow);
          const result4 = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result4.toString(), 4 * 10 ** 18);
          console.log(`player 5 joinning...`);
          await BingoToken.connect(player5).mint();
          await BingoToken.connect(player5).approve(Bingo.address, fee);
          await Bingo.connect(player5).joinCurrentGameWithBet(gameRoundNow);
          const result5 = await BingoToken.balanceOf(Bingo.address);
          assert.equal(result5.toString(), 5 * 10 ** 18);
          // console.log(`player 6 joinning...`);
          // await BingoToken.connect(player6).mint();
          // await BingoToken.connect(player6).approve(Bingo.address, fee);
          // await Bingo.connect(player6).joinCurrentGameWithBet(gameRoundNow);
          // const result6 = await BingoToken.balanceOf(Bingo.address);
          // assert.equal(result6.toString(), 6 * 10 ** 18);
          const player1cards = await Bingo.getPlayerGameBoard(
            player1.address,
            gameRoundNow
          );
          console.log(`player 1 playBoardNumbers:`);
          console.log(`-------------------------------`);
          display5x5matrix(player1cards);
          console.log(`-------------------------------`);
          const player2cards = await Bingo.getPlayerGameBoard(
            player2.address,
            gameRoundNow
          );
          console.log(`player 2 playBoardNumbers:`);
          console.log(`-------------------------------`);
          display5x5matrix(player2cards);
          console.log(`-------------------------------`);

          const player3cards = await Bingo.getPlayerGameBoard(
            player3.address,
            gameRoundNow
          );
          console.log(`player 3 playBoardNumbers:`);
          console.log(`-------------------------------`);
          display5x5matrix(player3cards);
          console.log(`-------------------------------`);
          const player4cards = await Bingo.getPlayerGameBoard(
            player4.address,
            gameRoundNow
          );
          console.log(`player 4 playBoardNumbers:`);
          console.log(`-------------------------------`);
          display5x5matrix(player4cards);
          console.log(`-------------------------------`);
          const player5cards = await Bingo.getPlayerGameBoard(
            player5.address,
            gameRoundNow
          );
          console.log(`player 5 playBoardNumbers:`);
          console.log(`-------------------------------`);
          display5x5matrix(player5cards);
          console.log(`-------------------------------`);
          // const player6cards = await Bingo.getPlayerGameBoard(
          //   player6.address,
          //   gameRoundNow
          // );
          // console.log(`player 6 playBoardNumbers:`);
          // console.log(`-------------------------------`);
          // display5x5matrix(player6cards);
          // console.log(`-------------------------------`);
          const joinDuration = await Bingo.joinDuration();
          const turnDuration = await Bingo.turnDuration();
          console.log(`wait for time pass join duration and draw duration`);
          await network.provider.send("evm_increaseTime", [
            joinDuration.toNumber() + turnDuration.toNumber() + 1,
          ]);

          console.log(`player draw results and claim winning.`);
          await Bingo.connect(player1).drawWinnerOrClaimPrize(gameRoundNow);
          await Bingo.connect(player2).drawWinnerOrClaimPrize(gameRoundNow);
          await Bingo.connect(player3).drawWinnerOrClaimPrize(gameRoundNow);
          await Bingo.connect(player4).drawWinnerOrClaimPrize(gameRoundNow);
          await Bingo.connect(player5).drawWinnerOrClaimPrize(gameRoundNow);
          // await Bingo.connect(player6).drawWinnerOrClaimPrize(gameRoundNow);
          const player1balance = await BingoToken.balanceOf(player1.address);
          const player2balance = await BingoToken.balanceOf(player2.address);
          const player3balance = await BingoToken.balanceOf(player3.address);
          const player4balance = await BingoToken.balanceOf(player4.address);
          const player5balance = await BingoToken.balanceOf(player5.address);
          // const player6balance = await BingoToken.balanceOf(player6.address);
          const gameReuslt = await Bingo.getRoundBingoResult(gameRoundNow);
          console.log(`Bingo result: ${gameReuslt[0]}`);
          const player1win = await Bingo.checkWinner(
            gameRoundNow,
            player1.address
          );
          const player2win = await Bingo.checkWinner(
            gameRoundNow,
            player2.address
          );
          const player3win = await Bingo.checkWinner(
            gameRoundNow,
            player3.address
          );
          const player4win = await Bingo.checkWinner(
            gameRoundNow,
            player4.address
          );
          const player5win = await Bingo.checkWinner(
            gameRoundNow,
            player5.address
          );
          // const player6win = await Bingo.checkWinner(
          //   gameRoundNow,
          //   player6.address
          // );
          console.log(`player 1 win, Prize:${player1win.toString()}`);
          console.log(`player 2 win, Prize:${player2win.toString()}`);
          console.log(`player 3 win, Prize:${player3win.toString()}`);
          console.log(`player 4 win, Prize:${player4win.toString()}`);
          console.log(`player 5 win, Prize:${player5win.toString()}`);
          // console.log(`player 6 win, Prize:${player6win.toString()}`);
          console.log(`winning numbers result: ${gameReuslt[1].toString()}`);
          console.log(`player 1 balance:${player1balance.toString()}`);
          console.log(`player 2 balance:${player2balance.toString()}`);
          console.log(`player 3 balance:${player3balance.toString()}`);
          console.log(`player 4 balance:${player4balance.toString()}`);
          console.log(`player 5 balance:${player5balance.toString()}`);
          // console.log(`player 6 balance:${player6balance.toString()}`);
        });
        it("four players join same game and check their awards for multiple times to check accurate gas cost", async () => {
          for (i = 0; i < 10; i++) {
            console.log(`No.${i + 1} Game strating...`);
            console.log(`player 1 joinning...`);
            await BingoToken.connect(player1).mint();
            await BingoToken.connect(player1).approve(Bingo.address, fee);
            await Bingo.connect(player1).startNewGameWithBet();
            const result = await BingoToken.balanceOf(Bingo.address);
            assert.equal(result.toString(), 1 * 10 ** 18);
            const gameRoundNow = await Bingo.gameRoundNow();
            console.log(`player 2 joinning...`);
            await BingoToken.connect(player2).mint();
            await BingoToken.connect(player2).approve(Bingo.address, fee);
            await Bingo.connect(player2).joinCurrentGameWithBet(gameRoundNow);
            const result2 = await BingoToken.balanceOf(Bingo.address);
            assert.equal(result2.toString(), 2 * 10 ** 18);
            console.log(`player 3 joinning...`);
            await BingoToken.connect(player3).mint();
            await BingoToken.connect(player3).approve(Bingo.address, fee);
            await Bingo.connect(player3).joinCurrentGameWithBet(gameRoundNow);
            const result3 = await BingoToken.balanceOf(Bingo.address);
            assert.equal(result3.toString(), 3 * 10 ** 18);
            console.log(`player 4 joinning...`);
            await BingoToken.connect(player4).mint();
            await BingoToken.connect(player4).approve(Bingo.address, fee);
            await Bingo.connect(player4).joinCurrentGameWithBet(gameRoundNow);
            const result4 = await BingoToken.balanceOf(Bingo.address);
            assert.equal(result4.toString(), 4 * 10 ** 18);
            // console.log(`player 5 joinning...`);
            // await BingoToken.connect(player5).mint();
            // await BingoToken.connect(player5).approve(Bingo.address, fee);
            // await Bingo.connect(player5).joinCurrentGameWithBet(gameRoundNow);
            // const result5 = await BingoToken.balanceOf(Bingo.address);
            // assert.equal(result5.toString(), 5 * 10 ** 18);
            // console.log(`player 6 joinning...`);
            // await BingoToken.connect(player6).mint();
            // await BingoToken.connect(player6).approve(Bingo.address, fee);
            // await Bingo.connect(player6).joinCurrentGameWithBet(gameRoundNow);
            // const result6 = await BingoToken.balanceOf(Bingo.address);
            // assert.equal(result6.toString(), 6 * 10 ** 18);
            const player1cards = await Bingo.getPlayerGameBoard(
              player1.address,
              gameRoundNow
            );
            console.log(`player 1 playBoardNumbers:`);
            console.log(`-------------------------------`);
            display5x5matrix(player1cards);
            console.log(`-------------------------------`);
            const player2cards = await Bingo.getPlayerGameBoard(
              player2.address,
              gameRoundNow
            );
            console.log(`player 2 playBoardNumbers:`);
            console.log(`-------------------------------`);
            display5x5matrix(player2cards);
            console.log(`-------------------------------`);

            const player3cards = await Bingo.getPlayerGameBoard(
              player3.address,
              gameRoundNow
            );
            console.log(`player 3 playBoardNumbers:`);
            console.log(`-------------------------------`);
            display5x5matrix(player3cards);
            console.log(`-------------------------------`);
            const player4cards = await Bingo.getPlayerGameBoard(
              player4.address,
              gameRoundNow
            );
            console.log(`player 4 playBoardNumbers:`);
            console.log(`-------------------------------`);
            display5x5matrix(player4cards);
            console.log(`-------------------------------`);
            const player5cards = await Bingo.getPlayerGameBoard(
              player5.address,
              gameRoundNow
            );
            // console.log(`player 5 playBoardNumbers:`);
            // console.log(`-------------------------------`);
            // display5x5matrix(player5cards);
            // console.log(`-------------------------------`);
            // const player6cards = await Bingo.getPlayerGameBoard(
            //   player6.address,
            //   gameRoundNow
            // );
            // console.log(`player 6 playBoardNumbers:`);
            // console.log(`-------------------------------`);
            // display5x5matrix(player6cards);
            // console.log(`-------------------------------`);
            const joinDuration = await Bingo.joinDuration();
            const turnDuration = await Bingo.turnDuration();
            console.log(`wait for time pass join duration and draw duration`);
            await network.provider.send("evm_increaseTime", [
              joinDuration.toNumber() + turnDuration.toNumber() + 1,
            ]);

            console.log(`player draw results and claim winning.`);
            await Bingo.connect(player1).drawWinnerOrClaimPrize(gameRoundNow);
            await Bingo.connect(player2).drawWinnerOrClaimPrize(gameRoundNow);
            await Bingo.connect(player3).drawWinnerOrClaimPrize(gameRoundNow);
            await Bingo.connect(player4).drawWinnerOrClaimPrize(gameRoundNow);
            // await Bingo.connect(player5).drawWinnerOrClaimPrize(gameRoundNow);
            // await Bingo.connect(player6).drawWinnerOrClaimPrize(gameRoundNow);
            const player1balance = await BingoToken.balanceOf(player1.address);
            const player2balance = await BingoToken.balanceOf(player2.address);
            const player3balance = await BingoToken.balanceOf(player3.address);
            const player4balance = await BingoToken.balanceOf(player4.address);
            // const player5balance = await BingoToken.balanceOf(player5.address);
            // const player6balance = await BingoToken.balanceOf(player6.address);
            const gameReuslt = await Bingo.getRoundBingoResult(gameRoundNow);
            console.log(`Bingo result: ${gameReuslt[0]}`);
            const player1win = await Bingo.checkWinner(
              gameRoundNow,
              player1.address
            );
            const player2win = await Bingo.checkWinner(
              gameRoundNow,
              player2.address
            );
            const player3win = await Bingo.checkWinner(
              gameRoundNow,
              player3.address
            );
            const player4win = await Bingo.checkWinner(
              gameRoundNow,
              player4.address
            );
            // const player5win = await Bingo.checkWinner(
            //   gameRoundNow,
            //   player5.address
            // );
            // const player6win = await Bingo.checkWinner(
            //   gameRoundNow,
            //   player6.address
            // );
            console.log(`player 1 win, Prize:${player1win.toString()}`);
            console.log(`player 2 win, Prize:${player2win.toString()}`);
            console.log(`player 3 win, Prize:${player3win.toString()}`);
            console.log(`player 4 win, Prize:${player4win.toString()}`);
            // console.log(`player 5 win, Prize:${player5win.toString()}`);
            // console.log(`player 6 win, Prize:${player6win.toString()}`);
            console.log(`winning numbers result: ${gameReuslt[1].toString()}`);
            console.log(`player 1 balance:${player1balance.toString()}`);
            console.log(`player 2 balance:${player2balance.toString()}`);
            console.log(`player 3 balance:${player3balance.toString()}`);
            console.log(`player 4 balance:${player4balance.toString()}`);
            // console.log(`player 5 balance:${player5balance.toString()}`);
            // console.log(`player 6 balance:${player6balance.toString()}`);
          }
        });
      });
    });
