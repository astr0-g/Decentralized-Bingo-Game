// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

/// @title Bingo Game Smart Contract
/// @author Ge
/// @notice You can use this contract for playing bingo game

import "./Interface/ICER20.sol";

error erorr__entryFee();
error error__inGameAlready();
error error__drawsNotStared();
error error__winnerIsDarwing();
error error__gameStarted();
error error__notInGameOrClaimedRewards();
error error__notAdmin();

contract Bingo {
    enum gameStage {
        BETTING,
        DARWING,
        DARWED
    }

    struct player {
        gameStage stage;
        uint256[25] gameBoard;
        mapping(uint256 => uint256) gameBoardMatchs;
    }

    struct gameRound {
        /// @notice When one person calls function `drawWinnerOrClaimRewrads`, it will draw the winner of this round
        bool drawing;
        /// @notice If `winnerAnnounced` is true, other players don't have to draw instead of claiming their prize
        bool winnerAnnounced;
        uint256 startTime;
        bool bingo;
        /// @notice Support multiple players in a game
        /// @notice If two or more players have their first bingo in the same round, they will share the prize pool
        address[] winner;
        address[] playersArray;
        uint256[30] winningNumders;
        mapping(address => player) players;
    }

    uint256 public gameRoundNow;
    /// @notice Admin can update the entry fee, join duration, and turn duration
    address public admin;
    /// @notice Games have a minimum join duration before start
    /// @notice `joinDuration` sets to 180 seconds as default to save gas
    uint256 public joinDuration = 180;
    /// @notice Games have a minimum turn duration between draws
    /// @notice `turnDuration` sets to 180 seconds as default to save gas
    uint256 public turnDuration = 180;
    /// @notice Each player pays an ERC20 entry fee, transferred on join
    address public BingoToken;
    /// @notice `betAmountForBINGO` sets to 1 token as default to save gas
    uint256 public betAmountForBINGO = 1000000000000000000;

    /// @notice Support multiple concurrent games
    mapping(uint256 => gameRound) gameRounds;

    /// @notice Event emit when player create a new game
    event Created(
        address indexed creator,
        uint256 indexed roundCreated,
        uint256 indexed timeCreated
    );
    /// @notice Event emit when player joins a existing game
    event Joined(address indexed player, uint256 indexed roundJoined);
    /// @notice Event emit when a game is drawed
    event Drawed(
        uint256 indexed gameRound,
        uint256 indexed playersNum,
        uint256[30] winningNumbers,
        bool bingo
    );
    /// @notice Event emit when a player claimed
    event Claimed(address indexed player, uint256 indexed Claimed);

    /// @notice Only allowing one player to draw the winning numbers with time limit
    modifier drawingWinnerCheck(uint256 _gameRound) {
        if (
            block.timestamp <
            gameRounds[_gameRound].startTime + joinDuration + turnDuration
        ) revert error__drawsNotStared();
        if (gameRounds[_gameRound].drawing) revert error__winnerIsDarwing();

        /// @notice Start drawing
        gameRounds[_gameRound].drawing = true;
        _;
        /// @notice Stop drawing
        gameRounds[_gameRound].drawing = false;
    }
    /// @notice Deploying Bingo Token first before deploying this contract
    constructor(address _bingoTokenAddress) {
        BingoToken = _bingoTokenAddress;
        admin = msg.sender;
    }
    /// @notice player start a new with game board generated
    function startNewGameWithBet() public {
        /// @notice Send Bingo Token to this contract, and check transaction success  
        if (
            IERC20(BingoToken).transferFrom(
                msg.sender,
                address(this),
                betAmountForBINGO
            ) != true
        ) revert erorr__entryFee();
        /// @notice Make a new game round
        unchecked {
            ++gameRoundNow;
        }
        /// @notice Save game round Id into this function 
        uint256 gameRoundnow = gameRoundNow;
        /// @notice Save game round start time
        gameRounds[gameRoundnow].startTime = block.timestamp;
        /// @notice Generating player game board for this round
        playerGenerateGameBoard(msg.sender, gameRoundnow);
        /// @notice Emit 'Created' event
        emit Created(msg.sender, gameRoundnow, block.timestamp);
    }

    /// @notice Calculate tree age in years, rounded up, for live trees
    /// @dev The Alexandr N. Tetearing algorithm could increase precision
    /// @param _gameRoundToJoin The number of rings from dendrochronological sample
    function joinCurrentGameWithBet(uint256 _gameRoundToJoin) public {
        (
            gameStage stageOfPlayer,
            uint256 roundStartedTimeWithDuration
        ) = getRoundDetails(_gameRoundToJoin, msg.sender);
        if (stageOfPlayer != gameStage.BETTING) revert error__inGameAlready();
        if (block.timestamp > roundStartedTimeWithDuration)
            revert error__gameStarted();
        if (
            IERC20(BingoToken).transferFrom(
                msg.sender,
                address(this),
                betAmountForBINGO
            ) != true
        ) revert erorr__entryFee();

        playerGenerateGameBoard(msg.sender, _gameRoundToJoin);
    }

    function drawWinnerOrClaimRewrads(
        uint256 _gameRound
    ) public drawingWinnerCheck(_gameRound) {
        if (
            gameRounds[_gameRound].players[msg.sender].stage !=
            gameStage.DARWING
        ) revert error__notInGameOrClaimedRewards();
        uint256 betAmount = betAmountForBINGO;
        uint256 prizeToSend;
        if (gameRounds[_gameRound].winnerAnnounced == true) {
            if (gameRounds[_gameRound].bingo) {
                prizeToSend = checkPrize(_gameRound, msg.sender);
                if (prizeToSend > 0) {
                    IERC20(BingoToken).transfer(msg.sender, prizeToSend);
                }
            } else {
                IERC20(BingoToken).transfer(msg.sender, betAmount);
            }
        } else {
            address[] memory playersArrays = gameRounds[_gameRound]
                .playersArray;
            uint256[30] memory winningNumbers = gameGenerateNumber(_gameRound);
            uint256 BingoIndex = 30;
            uint256 i;
            uint256 j;
            uint256 k;
            do {
                j = 0;
                do {
                    k = 0;
                    uint256[25] memory playerGameBoard = getPlayerGameBoard(
                        playersArrays[i],
                        _gameRound
                    );
                    do {
                        if (winningNumbers[j] == playerGameBoard[k]) {
                            gameRounds[_gameRound]
                                .players[playersArrays[i]]
                                .gameBoardMatchs[k] = 1;
                        }
                        if (k == 11) {
                            unchecked {
                                ++k;
                            }
                        }
                        unchecked {
                            ++k;
                        }
                        if (k > 4) {
                            if (checkWinning(_gameRound, playersArrays[i])) {
                                unchecked {
                                    BingoIndex = j + 1;
                                }
                                if (j == BingoIndex - 1) {
                                    gameRounds[_gameRound].winner.push(
                                        playersArrays[i]
                                    );
                                } else {
                                    uint256 w = 0;
                                    do {
                                        gameRounds[_gameRound].winner.push(
                                            playersArrays[w]
                                        );
                                        unchecked {
                                            ++w;
                                        }
                                    } while (
                                        w < gameRounds[_gameRound].winner.length
                                    );
                                }
                                gameRounds[_gameRound].bingo = true;
                                break;
                            }
                        }
                    } while (k < 25);
                    unchecked {
                        ++j;
                    }
                } while (j < BingoIndex);
                unchecked {
                    ++i;
                }
            } while (i < playersArrays.length);
            gameRounds[_gameRound].winnerAnnounced = true;
            if (gameRounds[_gameRound].bingo) {
                prizeToSend = checkPrize(_gameRound, msg.sender);
                if (prizeToSend > 0) {
                    IERC20(BingoToken).transfer(msg.sender, prizeToSend);
                }
            } else {
                IERC20(BingoToken).transfer(msg.sender, betAmount);
            }
            emit Drawed(
                _gameRound,
                playersArrays.length,
                winningNumbers,
                gameRounds[_gameRound].bingo
            );
        }
        gameRounds[_gameRound].players[msg.sender].stage = gameStage.DARWED;
        emit Claimed(msg.sender, prizeToSend);
    }

    function playerGenerateGameBoard(
        address _player,
        uint256 _gameRound
    ) internal {
        gameRounds[_gameRound].players[_player].stage = gameStage.DARWING;
        gameRounds[_gameRound].playersArray.push(_player);
        uint256 i;
        bytes32 blockHashPrevious = blockhash(block.number - 1);
        uint256 seed = uint256(blockHashPrevious);
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(seed, msg.sender))
        );
        uint256[25] memory array;
        do {
            randomNumber = (randomNumber >> 8 > 0)
                ? (randomNumber >> 8) % 75
                : (uint256(keccak256(abi.encodePacked(seed, msg.sender, i)))) %
                    75;
            array[i] = randomNumber;
            if (i == 11) {
                unchecked {
                    ++i;
                }
            }

            unchecked {
                ++i;
            }
        } while (i < 25);
        gameRounds[_gameRound].players[_player].gameBoard = array;
        gameRounds[_gameRound].players[_player].gameBoardMatchs[12] = 1;
        emit Joined(msg.sender, _gameRound);
    }

    function gameGenerateNumber(
        uint256 _gameRound
    ) internal returns (uint256[30] memory) {
        uint256 i;
        bytes32 blockHashPrevious = blockhash(block.number - 1);
        uint256 seed = uint256(blockHashPrevious);
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(seed, msg.sender))
        );
        uint256[30] memory array;
        do {
            randomNumber = (randomNumber >> 8 > 0)
                ? (randomNumber >> 8) % 75
                : (uint256(keccak256(abi.encodePacked(seed, msg.sender, i)))) %
                    75;
            array[i] = randomNumber;
            unchecked {
                ++i;
            }
        } while (i < 30);
        gameRounds[_gameRound].winningNumders = array;
        return (array);
    }

    function getRoundDetails(
        uint256 _gameRound,
        address _player
    ) internal view returns (gameStage, uint256) {
        return (
            gameRounds[_gameRound].players[_player].stage,
            gameRounds[_gameRound].startTime + joinDuration
        );
    }

    function getRoundBingoResult(
        uint256 _gameRound
    ) public view returns (bool, uint256[30] memory) {
        return (
            gameRounds[_gameRound].bingo,
            gameRounds[_gameRound].winningNumders
        );
    }

    function getPlayerGameBoard(
        address _player,
        uint256 _gameRound
    ) public view returns (uint256[25] memory) {
        return (gameRounds[_gameRound].players[_player].gameBoard);
    }

    function checkPrize(
        uint256 _gameRound,
        address _player
    ) internal view returns (uint256 winningPrize) {
        address[] memory winnners = gameRounds[_gameRound].winner;
        uint256 i;
        uint256 n;
        do {
            if (winnners[i] == _player) {
                unchecked {
                    n++;
                }
            }
            unchecked {
                ++i;
            }
        } while (i < winnners.length);
        return ((n *
            (betAmountForBINGO *
                (gameRounds[_gameRound].playersArray.length))) /
            (winnners.length));
    }

    function checkWinner(
        uint256 _gameRound,
        address _player
    ) public view returns (bool, uint256) {
        address[] memory winnners = gameRounds[_gameRound].winner;
        uint256 i;
        if (winnners.length > 0) {
            do {
                if (winnners[i] == _player) {
                    uint256 prize = checkPrize(_gameRound, _player);
                    return (true, prize);
                }
                unchecked {
                    ++i;
                }
            } while (i < winnners.length);
            return (false, 0);
        } else {
            return (false, 0);
        }
    }

    function checkWinning(
        uint256 _gameRound,
        address _player
    ) internal view returns (bool) {
        uint256 i;
        do {
            if (
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    i * 5 + 0
                ] ==
                1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    i * 5 + 1
                ] ==
                1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    i * 5 + 2
                ] ==
                1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    i * 5 + 3
                ] ==
                1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    i * 5 + 4
                ] ==
                1
            ) {
                return (true);
            } else if (
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    0 + i
                ] ==
                1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    5 + i
                ] ==
                1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    10 + i
                ] ==
                1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    15 + i
                ] ==
                1 &&
                gameRounds[_gameRound].players[_player].gameBoardMatchs[
                    20 + i
                ] ==
                1
            ) {
                return (true);
            }
            unchecked {
                ++i;
            }
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

    function setConfig(
        uint256 _joinDuration,
        uint256 _turnDuration,
        uint256 _betAmountForBINGO
    ) public {
        if (msg.sender != admin) revert error__notAdmin();
        joinDuration = _joinDuration;
        turnDuration = _turnDuration;
        betAmountForBINGO = _betAmountForBINGO;
    }
}
