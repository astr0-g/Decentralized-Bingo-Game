// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "./SafeMath.sol";
import "./Interface/ICER20.sol";
import "hardhat/console.sol";

error erorr__entryFee();
error error__inGameAlready();
error error__drawsNotStared();
error error__winnerIsDarwing();
error error__gameStarted();
error error__notInGameOrClaimedRewards();

contract Bingo {
    using SafeMath for uint256;

    enum gameStage {
        BETTING,
        REVEALING,
        DARWED
    }

    struct player {
        gameStage stage;
        uint256[] gameBoard;
        mapping(uint256 => uint256) gameBoardMatchs;
    }

    struct gameRound {
        bool winnerAnnounced;
        uint256 startTime;
        address winner;
        uint256 BingoInRound;
        address[] playersArray;
        uint256[] winningNumders;
        mapping(address => player) players;
    }
    address public BingoToken;
    bool public drawing;
    uint256 public gameRoundNow;
    uint256 public joinDuration = 180;
    uint256 public turnDuration = 180;
    uint256 public betAmountForBINGO = 1000000000000000000;
    uint256 public payoutPerCombination = 2;

    mapping(uint256 => gameRound) gameRounds;
    event Created(
        address indexed creator,
        uint256 indexed roundCreated,
        uint256 indexed timeCreated
    );
    event Joined(address indexed player, uint256 indexed roundJoined);
    event Reveal(address player, uint256[] numbers, uint256 result);
    modifier drawingWinnerCheck(uint256 _gameRound) {
        if (block.timestamp < gameRounds[_gameRound].startTime + joinDuration + turnDuration)
            revert error__drawsNotStared();
        if (drawing) revert error__winnerIsDarwing();
        drawing = true;
        _;
        drawing = false;
    }

    constructor(address _bingoTokenAddress) {
        BingoToken = _bingoTokenAddress;
    }

    function startNewGameWithBet() public {
        if (IERC20(BingoToken).transferFrom(msg.sender, address(this), betAmountForBINGO) != true)
            revert erorr__entryFee();
        gameRoundNow++;
        gameRounds[gameRoundNow].startTime = block.timestamp;
        gameRounds[gameRoundNow].players[msg.sender].stage = gameStage.REVEALING;
        playerGenerateGameBoard(msg.sender, gameRoundNow);
        emit Created(msg.sender, gameRoundNow, block.timestamp);
    }

    function joinCurrentGameWithBet(uint256 _gameRoundToJoin) public {
        if (gameRounds[_gameRoundToJoin].players[msg.sender].stage != gameStage.BETTING)
            revert error__inGameAlready();
        if (block.timestamp > gameRounds[_gameRoundToJoin].startTime + joinDuration)
            revert error__gameStarted();
        if (IERC20(BingoToken).transferFrom(msg.sender, address(this), betAmountForBINGO) != true)
            revert erorr__entryFee();
        gameRounds[_gameRoundToJoin].players[msg.sender].stage = gameStage.REVEALING;
        playerGenerateGameBoard(msg.sender, _gameRoundToJoin);
    }

    function drawWinnerOrClaimRewrads(uint256 _gameRound) public drawingWinnerCheck(_gameRound) {
        if (gameRounds[_gameRound].players[msg.sender].stage != gameStage.REVEALING)
            revert error__notInGameOrClaimedRewards();
        if (gameRounds[_gameRound].winnerAnnounced == true) {
            if (gameRounds[_gameRound].winner == msg.sender) {
                IERC20(BingoToken).transfer(
                    msg.sender,
                    betAmountForBINGO * gameRounds[_gameRound].playersArray.length
                );
            }
        } else {
            uint256[] memory winningNumbers = gameGenerateNumber(_gameRound);
            console.log(gameRounds[_gameRound].playersArray.length);
            gameRounds[_gameRound].BingoInRound = 30;
            uint8 i;
            uint8 j;
            uint8 k;
            do {
                console.log("checking player", i);
                j = 0;
                do {
                    k = 0;
                    uint256[] memory playerGameBoard = readPlayerGameBoard(
                        gameRounds[_gameRound].playersArray[i],
                        _gameRound
                    );
                    do {
                        if (winningNumbers[j] == playerGameBoard[k]) {
                            gameRounds[_gameRound]
                                .players[gameRounds[_gameRound].playersArray[i]]
                                .gameBoardMatchs[k] = 1;
                            console.log("match", j, k);
                        }
                        if (k == 11) {
                            ++k;
                        }
                        ++k;
                        if (k > 4) {
                            if (checkWinning(_gameRound, gameRounds[_gameRound].playersArray[i])) {
                                gameRounds[_gameRound].BingoInRound = j + 1;
                                gameRounds[_gameRound].winner = gameRounds[_gameRound]
                                    .playersArray[i];
                                console.log("winner found");
                                console.log("winner is");
                                console.log(
                                    gameRounds[_gameRound].winner = gameRounds[_gameRound]
                                        .playersArray[i]
                                );
                                console.log("Bingo Round");
                                console.log(j);
                                break;
                            }
                        }
                    } while (k < 25);
                    ++j;
                } while (j < gameRounds[_gameRound].BingoInRound);
                ++i;
            } while (i < gameRounds[_gameRound].playersArray.length);
            gameRounds[_gameRound].winnerAnnounced = true;
            // emit Reveal(msg.sender, numbers, result);
        }
    }

    function playerGenerateGameBoard(address _player, uint256 _gameRound) internal {
        gameRounds[_gameRound].playersArray.push(_player);
        uint8 i;
        bytes32 blockHashPrevious = blockhash(block.number - 1);
        uint256 seed = uint256(blockHashPrevious);
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed, msg.sender)));
        do {
            randomNumber = (randomNumber >> 8 > 0)
                ? (randomNumber >> 8) % 255
                : (uint256(keccak256(abi.encodePacked(seed, msg.sender, i)))) % 255;
            gameRounds[_gameRound].players[_player].gameBoard.push(randomNumber);
            ++i;
            if (i == 11) {
                ++i;
                gameRounds[_gameRound].players[_player].gameBoard.push(0);
            }
        } while (i < 25);
        gameRounds[_gameRound].players[_player].gameBoardMatchs[12] = 1;
        emit Joined(msg.sender, _gameRound);
    }

    function gameGenerateNumber(uint256 _gameRound) internal returns (uint256[] memory) {
        uint8 i;
        bytes32 blockHashPrevious = blockhash(block.number - 1);
        uint256 seed = uint256(blockHashPrevious);
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed, msg.sender)));
        do {
            randomNumber = (randomNumber >> 8 > 0)
                ? (randomNumber >> 8) % 255
                : (uint256(keccak256(abi.encodePacked(seed, msg.sender, i)))) % 255;
            gameRounds[_gameRound].winningNumders.push(randomNumber);
            ++i;
        } while (i < 30);
        return (gameRounds[_gameRound].winningNumders);
    }

    function trun() public pure returns (uint256) {
        return (512 % 8);
    }

    function readPlayerGameBoard(
        address _player,
        uint256 _gameRound
    ) public view returns (uint256[] memory) {
        return (gameRounds[_gameRound].players[_player].gameBoard);
    }

    // function readPlayerGameBoardMatchs(
    //     address _player,
    //     uint256 _gameRound
    // ) public view returns (uint256[] memory) {
    //     return (gameRounds[_gameRound].players[_player].gameBoardMatchs);
    // }

    function checkWinning(uint256 _gameRound, address _player) internal view returns (bool) {
        uint8 i;
        do {
            if (
                gameRounds[_gameRound].players[_player].gameBoardMatchs[i * 5 + 0] == 1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[i * 5 + 1] == 1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[i * 5 + 2] == 1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[i * 5 + 3] == 1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[i * 5 + 4] == 1
            ) {
                return (true);
            } else if (
                gameRounds[_gameRound].players[_player].gameBoardMatchs[0 + i] == 1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[5 + i] == 1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[10 + i] == 1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[15 + i] == 1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[20 + i] == 1
            ) {
                return (true);
            }
            ++i;
        } while (i < 5);

        if (
            gameRounds[_gameRound].players[_player].gameBoardMatchs[0] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[6] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[12] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[18] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[24] == 1
        ) {
            return (true);
        }

        if (
            gameRounds[_gameRound].players[_player].gameBoardMatchs[4] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[8] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[12] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[16] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[20] == 1
        ) {
            return (true);
        }
        return (false);
    }
}
