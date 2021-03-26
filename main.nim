import api
import config
import random
import findNumber
import findLineSuperFast
import os

randomize()

var conf = getConfig()

while true:
    var status = httpGetKeyStatus()
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
    
    echo "\nnumber: ", correctNumber, " line: ", word
    echo "\nnext key at: ", status.expiresUtc

    var nextStatus = httpGetKeyStatus()
    while nextStatus.currentKeyNumber == status.currentKeyNumber:
        sleep(15 * 1000)
        nextStatus = httpGetKeyStatus()

