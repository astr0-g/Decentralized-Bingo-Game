// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

/// @title Bingo Game Smart Contract
/// @author astro Ge
/// @notice You can use this contract for playing bingo game

import "./Interface/ICER20.sol";
import "hardhat/console.sol";
error erorr__entryFee();
error error__inGameAlready();
error error__drawsNotStared();
error error__winnerIsDRAWING();
error error__gameStarted();
error error__notInGameOrClaimedRewards();
error error__notAdmin();
error error__exceedLimitPlayersInOneGame();

contract Bingo {
    /// @notice This is game stage for each player in each game round
    enum gameStage {
        BETTING,
        DRAWING,
        DARWED
    }

    /// @notice This is player struct in each game round
    struct player {
        gameStage stage;
        uint256[25] gameBoard;
        /// @notice Matched number will be set as 1 for function to know it matches, 0 means unmatch
        mapping(uint256 => uint256) gameBoardMatchs;
    }

    struct gameRound {
        /// @notice When one person calls function `drawWinnerOrClaimRewrads`, it will draw the winner of this round
        bool drawing;
        /// @notice If `winnerAnnounced` is true, other players don't have to draw instead of claiming their prize
        bool winnerAnnounced;
        uint256 startTime;
        uint256 bingo;
        /// @notice Support multiple players in a game
        /// @notice If two or more players have their first bingo in the same round, they will share the prize pool
        address[] winner;
        address[] playersArray;
        uint256[24] winningNumders;
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
    /// @dev bingoRound == 0: no Bingo; bingoRound > 0: bingo in number of rounds
    event Drawed(
        uint256 indexed gameRound,
        uint256 indexed playersNum,
        uint256[24] winningNumbers,
        uint256 bingoRound
    );
    /// @notice Event emit when a player claimed prize
    event Claimed(address indexed player, uint256 indexed Claimed);

    /// @notice Only allowing one player to draw the winning numbers with time limit
    modifier drawingWinnerCheck(uint256 _gameRound) {
        if (
            block.timestamp <
            gameRounds[_gameRound].startTime + joinDuration + turnDuration
        ) revert error__drawsNotStared();
        if (gameRounds[_gameRound].drawing) revert error__winnerIsDRAWING();

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
        /// @notice Generating player game board for this game round
        playerGenerateGameBoard(msg.sender, gameRoundnow);
        emit Created(msg.sender, gameRoundnow, block.timestamp);
    }

    /// @notice Players join current game and generate their game board
    /// @param _gameRoundToJoin the round of game id
    /// @dev Worst case of nobody has a bingo for five players are about 28000000 gas within 0 - 64 as numbers that this contract generated for bingo game with 24 winning numbers generated
    function joinCurrentGameWithBet(uint256 _gameRoundToJoin) public {
        /// @notice With 2 lines above being said, limit no more than 5 players in a game to limit out of gas problem
        if (gameRounds[_gameRoundToJoin].playersArray.length + 1 > 5)
            revert error__exceedLimitPlayersInOneGame();
        (
            gameStage stageOfPlayer,
            uint256 roundStartedTimeWithDuration
        ) = getRoundDetails(_gameRoundToJoin, msg.sender);
        /// @notice Player can join multiple game at the same time, but not in the same round
        if (stageOfPlayer != gameStage.BETTING) revert error__inGameAlready();
        /// @notice Players can not join the game after join duration
        if (block.timestamp > roundStartedTimeWithDuration)
            revert error__gameStarted();
        /// @notice Send Bingo Token to this contract, and check transaction success
        if (
            IERC20(BingoToken).transferFrom(
                msg.sender,
                address(this),
                betAmountForBINGO
            ) != true
        ) revert erorr__entryFee();
        /// @notice Generating player game board for this game round
        playerGenerateGameBoard(msg.sender, _gameRoundToJoin);
    }

    /// @notice Players draw winner of this game round or claim prize
    /// @dev if one game is drawed, other players in this round
    /// @param _gameRound the round of game id that player joined
    function drawWinnerOrClaimPrize(
        uint256 _gameRound
    ) public drawingWinnerCheck(_gameRound) {
        /// @notice Cheak if stage of player in this is DRAWING to let them draw or claim
        if (
            gameRounds[_gameRound].players[msg.sender].stage !=
            gameStage.DRAWING
        ) revert error__notInGameOrClaimedRewards();
        /// @notice Read bet amount to use for this function at beginning to save gas
        uint256 betAmount = betAmountForBINGO;
        uint256 prizeToSend;
        /// @notice If winner is announced then distribute the prize to the caller
        /// @dev This only be true when second time this function is called
        if (gameRounds[_gameRound].winnerAnnounced == true) {
            /// @notice If there is one of more bingo achieved, check the prize and send to the winner
            if (gameRounds[_gameRound].bingo > 0) {
                prizeToSend = checkPrize(_gameRound, msg.sender);
                if (prizeToSend > 0) {
                    IERC20(BingoToken).transfer(msg.sender, prizeToSend);
                }
            } else {
                /// @notice If there no bingo achieved, refund Bingo Token player bet
                IERC20(BingoToken).transfer(msg.sender, betAmount);
            }
        } else {
            /// @notice Draw winner or winners, if two players achieved bingo in the same round, they will split the prize poll
            /// @dev Drawing winner spend unbelievable gas amount, using a automation keeper to call this function could wave gas for player in real cases
            /// @notice Read players's addresses to use for this function at beginning of drawing process to save gas
            address[] memory playersArrays = gameRounds[_gameRound]
                .playersArray;
            /// @notice if there are more than one player in the game, then drawing start
            if (playersArrays.length > 1) {
                /// @notice Call `gameGenerateNumber` to generate winning numbers
                uint256[24] memory winningNumbers = gameGenerateNumber(
                    _gameRound
                );
                uint256 BingoIndex = 24;
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
                                if (
                                    checkWinning(_gameRound, playersArrays[i])
                                ) {
                                    if (j == BingoIndex - 1) {
                                        gameRounds[_gameRound].winner.push(
                                            playersArrays[i]
                                        );
                                    } else {
                                        gameRounds[_gameRound]
                                            .winner = new address[](0);
                                        gameRounds[_gameRound].winner.push(
                                            playersArrays[i]
                                        );
                                    }
                                    unchecked {
                                        BingoIndex = j + 1;
                                    }
                                    gameRounds[_gameRound].bingo = j;
                                    console.log(j);
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
                if (gameRounds[_gameRound].bingo > 0) {
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
            } else {
                IERC20(BingoToken).transfer(msg.sender, betAmount);
                // gameRounds[_gameRound].winnerAnnounced = true;
            }
        }
        gameRounds[_gameRound].players[msg.sender].stage = gameStage.DARWED;
        emit Claimed(msg.sender, prizeToSend);
    }

    /// @notice Player generating game board when creating or joinning a game
    /// @dev `joinCurrentGameWithBet` & `startNewGameWithBet` will call this internal function
    /// @param _player player's address
    /// @param _gameRound the round of game id
    function playerGenerateGameBoard(
        address _player,
        uint256 _gameRound
    ) internal {
        /// @notice Change player's stage of this game round to DRAWING
        gameRounds[_gameRound].players[_player].stage = gameStage.DRAWING;
        /// @notice Save player's address to game round player array
        gameRounds[_gameRound].playersArray.push(_player);
        uint256 i;
        /// @notice Make a memory array for generating game board numbers in this function
        /// @dev Saving more gas compares to directly save numbers into contract each time
        uint256[25] memory array;
        /// @dev Generate random number, but could be replaced by on-chain services provider, such as Chainlink
        bytes32 blockHashPrevious = blockhash(block.number - 1);
        uint256 seed = uint256(blockHashPrevious);
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(seed, msg.sender))
        );
        /// @dev Use do while and unchecked{} to save gas.
        do {
            /// @notice Check if the random number bigger than 64
            /// @dev The reason why i choose 64 is because 256 will hardly get a bingo and spent a lot of gas without a winner
            /// @dev We could definetly choose 256 if we insist
            randomNumber = (randomNumber >> 6 > 0)
                ? (randomNumber >> 6) % 64
                : (uint256(keccak256(abi.encodePacked(seed, msg.sender, i)))) %
                    64;
            /// @notice Save random number into memory array
            array[i] = randomNumber;
            /// @notice No need to save the center game borad number
            if (i == 11) {
                unchecked {
                    ++i;
                }
            }
            unchecked {
                ++i;
            }
        } while (i < 25);
        /// @notice Save generated number into player game board
        gameRounds[_gameRound].players[_player].gameBoard = array;
        /// @notice Set player game board matches array[12] become matched
        gameRounds[_gameRound].players[_player].gameBoardMatchs[12] = 1;
        emit Joined(msg.sender, _gameRound);
    }

    /// @notice Game generating winning number of this game round
    /// @dev `drawWinnerOrClaimPrize` will call this internal function
    /// @param _gameRound the round of game id
    function gameGenerateNumber(
        uint256 _gameRound
    ) internal returns (uint256[24] memory) {
        /// @notice Make a memory array for generating game board numbers in this function
        /// @dev Saving more gas compares to directly save numbers into contract each time
        /// @dev Choose 24 winning numbers between 0 - 63 is enough for a bingo to be true, and it is also be able to make player gameboard match all bingos
        /// @dev Worst case of nobody has a bingo for five players are about 28000000 gas within 0 - 64 as numbers that this contract generated for bingo game with 24 winning numbers generated
        /// @dev We could definetly choose more to make every game has a Bingo if we insist
        uint256[24] memory array;
        uint256 i;
        /// @dev Generate random number, but could be replaced by on-chain services provider, such as Chainlink
        bytes32 blockHashPrevious = blockhash(block.number - 1);
        uint256 seed = uint256(blockHashPrevious);
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(seed, msg.sender))
        );
        /// @dev Use do while and unchecked{} to save gas.
        do {
            /// @notice Check if the random number bigger than 64
            /// @dev The reason why choose 64 is because 256 will hardly get a bingo and spent a lot of gas without a winner
            /// @dev We could definetly choose 256 if we insist
            randomNumber = (randomNumber >> 6 > 0)
                ? (randomNumber >> 6) % 64
                : (uint256(keccak256(abi.encodePacked(seed, msg.sender, i)))) %
                    64;
            /// @notice Save random number into memory array
            array[i] = randomNumber;
            unchecked {
                ++i;
            }
        } while (i < 24);
        /// @notice Save winning numbers into contract
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
    ) public view returns (bool, uint256[24] memory) {
        return (
            gameRounds[_gameRound].bingo > 0,
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
            gameRounds[_gameRound].players[_player].gameBoardMatchs[18] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[24] == 1
        ) {
            return (true);
        }

        if (
            gameRounds[_gameRound].players[_player].gameBoardMatchs[4] == 1 &&
            gameRounds[_gameRound].players[_player].gameBoardMatchs[8] == 1 &&
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
