// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "./SafeMath.sol";
import "hardhat/console.sol";

contract Bingo {
    using SafeMath for uint256;

    enum Stage {
        BETTING,
        REVEALING
    }

    struct Player {
        Stage stage;
        uint256 block;
        uint256 bet;
        uint256[] card;
        uint256[] generatedNumders;
        mapping(uint256 => uint256) cardsCheker;
    }

    uint256 public minBet = 1000000000000000000;
    uint256 public maxBet = 10000000000000000000;
    uint256 public payoutPerCombination = 2;
    mapping(address => Player) public players;

    event Bet(address player, uint256 block, uint256 bet);
    event Reveal(address player, uint256[] numbers, uint256 result);

    function bet() public payable {
        require(msg.value >= minBet && msg.value <= maxBet);
        require(players[msg.sender].stage == Stage.BETTING);
        players[msg.sender].stage = Stage.REVEALING;
        players[msg.sender].block = block.number - 1;
        players[msg.sender].bet = msg.value;
        players[msg.sender].card = new uint256[](25);
        players[msg.sender].generatedNumders = new uint256[](30);
        console.log(block.number - 1);
        emit Bet(msg.sender, block.number, msg.value);
    }

    function read()
        public
        view
        returns (Stage, uint256, uint256, uint256[] memory, uint256[] memory)
    {
        return (
            players[msg.sender].stage,
            players[msg.sender].block,
            players[msg.sender].bet,
            players[msg.sender].card,
            players[msg.sender].generatedNumders
        );
    }

    function reveal() public payable {
        require(players[msg.sender].stage == Stage.REVEALING);
        uint256 result;
        uint256 i;
        uint256 card;
        uint256 idx;
        Player storage player = players[msg.sender];
        bytes32 blockHashPrevious = blockhash(players[msg.sender].block);
        console.log("1");
        uint256 seed = uint256(blockHashPrevious);
        uint256 rand = uint256(keccak256(abi.encodePacked(seed, msg.sender)));
        console.log("2");
        while (i < 25) {
            card = 1 + ((rand & 255) % 75);
            rand = (rand >> 8 > 0)
                ? rand >> 8
                : uint256(keccak256(abi.encodePacked(seed, msg.sender, i)));
            idx = player.cardsCheker[card];
            if (idx == 0) {
                players[msg.sender].card[i] = card;
                player.cardsCheker[card] = i;
                i += (i == 11) ? 2 : 1;
            }
        }
        console.log("3");
        uint256[] memory numbers = players[msg.sender].card;

        rand = uint256(keccak256(abi.encodePacked(seed, address(this))));
        i = 0;
        card = 0;
        idx = 0;

        for (i = 0; i < 30; i++) {
            card = 1 + ((rand & 255) % 75);
            rand = (rand >> 8 > 0)
                ? rand >> 8
                : uint256(keccak256(abi.encodePacked(seed, address(this), i)));
            player.generatedNumders[i] = card;
            idx = player.cardsCheker[card];
            if (player.card[idx] == card) {
                players[msg.sender].card[i] = 0;
                player.cardsCheker[card] = 0;
            }
        }
        for (i = 0; i < 5; i++) {
            if (
                players[msg.sender].card[i * 5 + 0] == 0 &&
                players[msg.sender].card[i * 5 + 1] == 0 &&
                players[msg.sender].card[i * 5 + 2] == 0 &&
                players[msg.sender].card[i * 5 + 3] == 0 &&
                players[msg.sender].card[i * 5 + 4] == 0
            ) {
                result++;
            }

            if (
                players[msg.sender].card[0 + i] == 0 &&
                players[msg.sender].card[5 + i] == 0 &&
                players[msg.sender].card[10 + i] == 0 &&
                players[msg.sender].card[15 + i] == 0 &&
                players[msg.sender].card[20 + i] == 0
            ) {
                result++;
            }
        }

        if (
            players[msg.sender].card[0 + i] == 0 &&
            players[msg.sender].card[6] == 0 &&
            players[msg.sender].card[12] == 0 &&
            players[msg.sender].card[18] == 0 &&
            players[msg.sender].card[24] == 0
        ) {
            result++;
        }

        if (
            players[msg.sender].card[4] == 0 &&
            players[msg.sender].card[8] == 0 &&
            players[msg.sender].card[12] == 0 &&
            players[msg.sender].card[16] == 0 &&
            players[msg.sender].card[20] == 0
        ) {
            result++;
        }
        console.log("5");
        // .mul(result).mul(payoutPerCombination)
        (bool callSuccess, ) = payable(msg.sender).call{value: player.bet}("");

        require(callSuccess, "Call failed");
        players[msg.sender].stage = Stage.BETTING;
        players[msg.sender].block = 0;
        players[msg.sender].bet = 0;
        players[msg.sender].card = new uint256[](25);
        players[msg.sender].generatedNumders = new uint256[](30);
        emit Reveal(msg.sender, numbers, result);
    }
}
