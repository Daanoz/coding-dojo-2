import api
import random
import puzzleUtils
import algorithm
import sequtils

proc generateRandomWords(
    maxNumberOfEntries: int, 
    maxLineLength: int, 
    allowedChars: string,
    number: int
): seq[Entry] = 
    var entries: seq[Entry] = @[]
    while entries.len < maxNumberOfEntries:
        var randomLength = 1 + rand(maxLineLength - 1)
        var word = ""
        while word.len < randomLength:
            word.add(sample(allowedChars))

        entries.add(Entry(
            line: word,
            number: number
        ))
    return entries

proc replaceChar(allowedChars: string, word: string, i: int, delta: int): string = 
    var index = find(allowedChars, word[i])
    index = (index + delta + allowedChars.len) mod allowedChars.len
    return word.substr(0, i - 1) & allowedChars[index] & word.substr(i + 1)

proc findBestLine*(status: KeyStatusResponse, playerId: string, number: int): string =
    var allowedChars = httpGetLegalCharacters()
    var tries = 0
    let topxWords = 4
    let charDelta = status.maxNumberOfEntries div ((topxWords * 2) + (status.maxLineLength * 2 * topxWords))

    let randomWordList = generateRandomWords(
        status.maxNumberOfEntries, 
        status.maxLineLength, 
        allowedChars, 
        number
    )

    let scores = httpPostEvaluate(EvaluateRequest(
        playerId: playerId,
        entries: randomWordList
    ))

    var initialScoreEntries = scores.entries
    initialScoreEntries.sort(sortByScore)
    initialScoreEntries.setLen(topxWords)

    proc findBestLineFromList(prevEntries: seq[Entry]): string = 
        var entries: seq[Entry] = @[]
        for entry in prevEntries:
            var baseWord = entry.line
            var i = 0
            while i < baseWord.len:
                for offset in 1..charDelta:
                    entries.add(Entry(
                        line: replaceChar(allowedChars, baseWord, i, offset),
                        number: number
                    ))
                    entries.add(Entry(
                        line: replaceChar(allowedChars, baseWord, i, offset * -1),
                        number: number
                    ))
                inc i

            if baseWord.len > 1:
                entries.add(Entry(
                    line: baseWord.substr(0, baseWord.len - 1),
                    number: number
                ))
            elif baseWord.len < status.maxLineLength:
                entries.add(Entry(
                    line: baseWord & allowedChars[0],
                    number: number
                ))

        let scores = httpPostEvaluate(EvaluateRequest(
            playerId: playerId,
            entries: entries
        ))
        inc tries

        var scoreEntries = scores.entries
        scoreEntries.sort(sortByScore)
        scoreEntries = deduplicate(scoreEntries)
        scoreEntries.setLen(topxWords)
        echo "Best guess: ", scoreEntries[0].line, " score: ", scoreEntries[0].score, " #: ", tries
        if scoreEntries[0].score == 0:
            return scoreEntries[0].line
        else:
            return findBestLineFromList(scoreEntries)
            
    return findBestLineFromList(initialScoreEntries)