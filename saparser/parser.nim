import
  options,
  nre,
  strutils,

  request,
  response,
  headers

type
  MessageType* = enum
    SpamcRequest,
    SpamdResponse

  Result* = object
    case kind* : MessageType
    of SpamcRequest:
      request* : Request
    of SpamdResponse:
      response* : Response

  State = object
    index : int
    

proc initState() : State =
  State(index : 0)

proc advance(state : var State, distance : int) =
  state.index += distance

proc match(state : State, input, symbol : string) : bool =
  result = input[state.index .. <state.index + symbol.len] == symbol

proc match(state : State, input, symbol : string, delimiter : char) : bool =
  # let starts = input[state.index .. <state.index + symbol.len] == symbol
  let starts = match(state, input, symbol)
  let delimited = input[state.index + symbol.len] == delimiter
  result = starts and delimited

proc match(state : State, input : string, pattern : Regex) : Option[RegexMatch] =
  result = match(input, pattern, state.index)

proc consume(state : var State, input, symbol : string, delimiter : char) : bool =
  result = match(state, input, symbol, delimiter)
  if result:
    advance(state, len(symbol) + 1)

proc consume(state : var State, input, symbol : string) : bool =
  result = match(state, input, symbol)
  if result:
    advance(state, len(symbol))

proc consume(state : var State, input : string, pattern : Regex) : bool =
  let m = match(state, input, pattern)
  if m.isSome:
    result = true
    advance(state, len(m.get.matchBounds))

proc newline(state : var State, input : string) : bool =
  result = consume(state, input, "\r\l")

proc verb(state : var State, input : string) : Option[Verb] =
  for v in request.Verb:
    if consume(state, input, $v, ' '):
      return some(v)

proc version(state : var State, input : string) : Option[string] =
  let m = match(state, input, re"\d+\.\d+")
  if m.isSome:
    result = some(m.get.match)
    advance(state, len(m.get.match))

proc headers(state : var State, input : string) : seq[Header] =
  discard

proc request*(input : string) : Option[Request] =
  var state = initState()
  echo state
  
  let verb = verb(state, input)
  echo "Verb : ", verb
  echo state

  let protocol = consume(state, input, "SPAMC", '/')
  echo "Protocol : ", protocol
  echo state

  let version = version(state, input)
  echo "Version : ", version
  echo state

  let nl = newline(state, input)
  echo "NL : ", nl
  echo state

  echo state

proc parse*(input : string) : Option[Result] =
  var state = initState()

when isMainModule:
  # let input = "   123.456"
  # var s = State(index : 3)
  # echo version(s, input)
  # echo s

  discard request("CHECK SPAMC/1.5\r\l")
