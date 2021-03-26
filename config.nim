
const clientId = "AMAZE"
const name = "me"

type 
    Config* = object
        clientId*: string
        name*: string

proc getConfig*(): Config =
    return Config(
        clientId: clientId,
        name: name
    )