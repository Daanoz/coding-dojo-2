import api
import config
import random
import findNumber
import findLine

randomize()

var conf = getConfig()

let status = httpGetKeyStatus()
if status.currentKeyNumber < 0:
    raise Exception.newException("nothing to join")
echo status
if status.winners.contains(conf.name):
    raise Exception.newException("already won")

let playerId = httpPostPlayerJoin(PlayerJoinRequest(
    clientId: conf.clientId,
    playerName: conf.name
)).playerId
echo playerId

let correctNumber = findBestNumber(status, playerId)
let word = findBestLine(status, playerId, correctNumber)
echo "number: ", correctNumber, " line: ", word

