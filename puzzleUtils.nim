import api

proc sortByScore*(x, y: Entry): int =
    if x.score > y.score: -1
    elif x.score == y.score: 0
    else: 1