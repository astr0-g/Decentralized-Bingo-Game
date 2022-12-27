import os
import json
from django.http import JsonResponse
from django.forms.models import model_to_dict
from rest_framework.response import Response
from rest_framework.decorators import api_view
from web3 import Web3
import json
from dotenv import load_dotenv

load_dotenv()
providerurl = os.environ.get("providerurl")
web3 = Web3(Web3.HTTPProvider(providerurl))
token_abi = json.loads(
    '[ { "inputs": [ { "internalType": "address", "name": "_bingoTokenAddress", "type": "address" } ], "stateMutability": "nonpayable", "type": "constructor" }, { "inputs": [], "name": "erorr__entryFee", "type": "error" }, { "inputs": [], "name": "error__drawsNotStared", "type": "error" }, { "inputs": [], "name": "error__exceedLimitPlayersInOneGame", "type": "error" }, { "inputs": [], "name": "error__gameStarted", "type": "error" }, { "inputs": [], "name": "error__gameWinnerDrawed", "type": "error" }, { "inputs": [], "name": "error__gameWinnerNotDrawed", "type": "error" }, { "inputs": [], "name": "error__inGameAlready", "type": "error" }, { "inputs": [], "name": "error__notAdmin", "type": "error" }, { "inputs": [], "name": "error__notInGameOrClaimedRewards", "type": "error" }, { "inputs": [], "name": "error__winnerIsDRAWING", "type": "error" }, { "anonymous": false, "inputs": [ { "indexed": true, "internalType": "address", "name": "player", "type": "address" }, { "indexed": true, "internalType": "uint256", "name": "Claimed", "type": "uint256" } ], "name": "Claimed", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": true, "internalType": "address", "name": "creator", "type": "address" }, { "indexed": true, "internalType": "uint256", "name": "roundCreated", "type": "uint256" }, { "indexed": true, "internalType": "uint256", "name": "timeCreated", "type": "uint256" } ], "name": "Created", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": true, "internalType": "uint256", "name": "gameRound", "type": "uint256" }, { "indexed": true, "internalType": "uint256", "name": "playersNum", "type": "uint256" }, { "indexed": false, "internalType": "uint256[24]", "name": "winningNumbers", "type": "uint256[24]" }, { "indexed": false, "internalType": "uint256", "name": "bingoRound", "type": "uint256" } ], "name": "Drawed", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": true, "internalType": "address", "name": "player", "type": "address" }, { "indexed": true, "internalType": "uint256", "name": "roundJoined", "type": "uint256" } ], "name": "Joined", "type": "event" }, { "inputs": [], "name": "BingoToken", "outputs": [ { "internalType": "address", "name": "", "type": "address" } ], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "admin", "outputs": [ { "internalType": "address", "name": "", "type": "address" } ], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "betAmountForBINGO", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "_gameRound", "type": "uint256" }, { "internalType": "address", "name": "_player", "type": "address" } ], "name": "checkWinner", "outputs": [ { "internalType": "bool", "name": "", "type": "bool" }, { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "_gameRound", "type": "uint256" } ], "name": "claimPrize", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "_gameRound", "type": "uint256" } ], "name": "drawWinner", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "name": "gameRoundNow", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "_gameRound", "type": "uint256" } ], "name": "getPlayerArray", "outputs": [ { "internalType": "address[]", "name": "", "type": "address[]" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "address", "name": "_player", "type": "address" }, { "internalType": "uint256", "name": "_gameRound", "type": "uint256" } ], "name": "getPlayerGameBoard", "outputs": [ { "internalType": "uint256[25]", "name": "", "type": "uint256[25]" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "_gameRound", "type": "uint256" } ], "name": "getRoundBingoResult", "outputs": [ { "internalType": "bool", "name": "", "type": "bool" }, { "internalType": "uint256[24]", "name": "", "type": "uint256[24]" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "_gameRoundToJoin", "type": "uint256" } ], "name": "joinCurrentGameWithBet", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "name": "joinDuration", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "maxPlayerNum", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "returnBet", "outputs": [ { "internalType": "bool", "name": "", "type": "bool" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "uint256", "name": "_joinDuration", "type": "uint256" }, { "internalType": "uint256", "name": "_turnDuration", "type": "uint256" }, { "internalType": "uint256", "name": "_betAmountForBINGO", "type": "uint256" }, { "internalType": "bool", "name": "_returnBet", "type": "bool" }, { "internalType": "uint256", "name": "_maxPlayerNum", "type": "uint256" } ], "name": "setConfig", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "name": "startNewGameWithBet", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "name": "turnDuration", "outputs": [ { "internalType": "uint256", "name": "", "type": "uint256" } ], "stateMutability": "view", "type": "function" }, { "inputs": [ { "internalType": "address", "name": "_erc20ContractAddress", "type": "address" }, { "internalType": "uint256", "name": "_amount", "type": "uint256" }, { "internalType": "address", "name": "_to", "type": "address" } ], "name": "withdrawToken", "outputs": [], "stateMutability": "nonpayable", "type": "function" } ]')
contract = web3.eth.contract(
    "0xF7756666306c26c82DA2650DFeD9636Bc6676B61", abi=token_abi)


@api_view(["GET"])
def api_getbingobasicdetails(request, *arg, **kwargs):
    jsonobj = []
    gameRoundNow = contract.functions.gameRoundNow().call()
    admin = contract.functions.admin().call()
    joinDuration = contract.functions.joinDuration().call()
    turnDuration = contract.functions.turnDuration().call()
    BingoToken = contract.functions.BingoToken().call()
    betAmountForBINGO = contract.functions.betAmountForBINGO().call()
    returnBet = contract.functions.returnBet().call()
    maxPlayerNum = contract.functions.maxPlayerNum().call()
    jsonobj.append({
        "gameRoundNow": f"{gameRoundNow}",
        "admin": f"{admin}",
        "joinDuration": f"{joinDuration}",
        "turnDuration": f"{turnDuration}",
        "BingoToken address": f"{BingoToken}",
        "betAmountForBINGO": f"{betAmountForBINGO}",
        "returnBet": f"{returnBet}",
        "maxPlayerNumInOneRound": f"{maxPlayerNum}"
    })
    return Response(jsonobj, status=200)


@api_view(["GET"])
def api_getplayergameboard(request, playeraddress, gameround):
    jsonobj = []
    gameBoard = contract.functions.getPlayerGameBoard(
        playeraddress, int(gameround)).call()
    jsonobj.append({
        "playerAddres": f"{playeraddress}",
        "gameRound": f"{gameround}",
        "gameBoard": f"{gameBoard}",
    })
    return Response(jsonobj, status=200)


@api_view(["GET"])
def api_getplayer(request, gameround):
    jsonobj = []
    PlayerArray = contract.functions.getPlayerArray(
        int(gameround)).call()
    for i in PlayerArray:
        jsonobj.append({
            "playerAddres": f"{i}",
        })
    return Response(jsonobj, status=200)


@api_view(["GET"])
def api_getroundbingoresult(request, gameround):
    jsonobj = []
    BingoResult = contract.functions.getRoundBingoResult(
        int(gameround)).call()
    jsonobj.append(
        {"bingo": f"{BingoResult[0]}", "winningNumber": f"{BingoResult[1]}"})

    return Response(jsonobj, status=200)


@api_view(["GET"])
def api_checkwinner(request, playeraddress, gameround):
    jsonobj = []
    winnerDetails = contract.functions.checkWinner(
        int(gameround), playeraddress).call()
    jsonobj.append(
        {"winnerstates": f"{winnerDetails[0]}", "prize": f"{winnerDetails[1]}"})

    return Response(jsonobj, status=200)


@api_view(["GET"])
def api_get10rounddetils(request):
    jsonobj = []
    gameRoundNow = contract.functions.gameRoundNow().call()
    for i in reversed(range(gameRoundNow)):
        PlayerArray = contract.functions.getPlayerArray(
            int(i+1)).call()

        BingoResult = contract.functions.getRoundBingoResult(
            int(i+1)).call()
        for k in PlayerArray:
            gameBoard = contract.functions.getPlayerGameBoard(
                k, int(i+1)).call()
            winnerDetails = contract.functions.checkWinner(
                int(i+1), k).call()
            jsonobj.append(
                {"gameround": f"{i+1}", "gameround bingo result": f"{BingoResult[0]}", "gameround winning numbers": f"{BingoResult[1]}", "player": f"{k}", "gameboard": f"{gameBoard}", "winnerstates": f"{winnerDetails[0]}", "prize": f"{winnerDetails[1]}"})

    # winnerDetails = contract.functions.checkWinner(
    #     int(gameround), playeraddress).call()

    return Response(jsonobj, status=200)
