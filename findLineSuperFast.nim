import api
import puzzleUtils
import algorithm

proc findBestLine*(status: KeyStatusResponse, playerId: string, number: int): string =
    let allowedChars = httpGetLegalCharacters()
    var tries = 0

    proc findBestLineFromList(lastBestWord: string): string = 
        var entries: seq[Entry] = @[]
        
        for index in 0..(allowedChars.len - 1):
            entries.add(Entry(
                line: lastBestWord & allowedChars[index],
                number: number
            ))

        let scores = httpPostEvaluate(EvaluateRequest(
            playerId: playerId,
            entries: entries
        ))
        inc tries

        var scoreEntries = scores.entries
        scoreEntries.sort(sortByScore)
        echo "Best guess: ", scoreEntries[0].line, " score: ", scoreEntries[0].score, " #: ", tries
        if scoreEntries[0].score == 0:
            return scoreEntries[0].line
        else:
            return findBestLineFromList(scoreEntries[0].line)
            
    return findBestLineFromList("")