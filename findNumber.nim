import api
import math
import puzzleUtils
import algorithm

proc findBestNumber*(status: KeyStatusResponse, playerId: string): int =

    proc findBestNumberInRange(
        minValue: int, 
        maxValue: int
    ): int =
        var entries: seq[Entry] = @[]

        var min = minValue
        var max = maxValue
        if max < min:
            let t = min
            min = max
            max = t

        var i = min
        var delta = math.ceil((max - min) / (status.maxNumberOfEntries)).toInt()
        if delta < 1:
            delta = 1

        while i <= max:
            entries.add(Entry(
                line: "test",
                number: i
            ))
            i += delta

        let scores = httpPostEvaluate(EvaluateRequest(
            playerId: playerId,
            entries: entries
        ))

        var scoreEntries = scores.entries
        scoreEntries.sort(sortByScore)
        scoreEntries.setLen(4)

        echo "Best guess: ", scoreEntries[0].number, " score: ", scoreEntries[0].score

        var scoreDelta = abs(scoreEntries[0].number - scoreEntries[1].number)
        if scoreDelta == 1:
            if scoreEntries[0].score < scoreEntries[1].score:
                return scoreEntries[1].number
            else:  
                return scoreEntries[0].number
        else:
            return findBestNumberInRange(
                scoreEntries[0].number, 
                scoreEntries[1].number
            )

    return findBestNumberInRange(0, high(int32))