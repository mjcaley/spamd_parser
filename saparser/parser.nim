import
  nre,
  options,
  parseutils,
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

  Error = object
    index : int
    message : string

  State = object
    index : int
    errors : seq[Error]
    

proc initState() : State =
  State(index : 0, errors : @[])

proc error(s : var State, message : string) =
  s.errors.add(Error(index : s.index, message : message))

proc atEnd(state : State, input : string) : bool =
  result = state.index >= len(input)

proc advance(state : var State, distance : int) =
  state.index += distance

proc match(state : State, input, symbol : string) : bool =
  result = input[state.index .. <state.index + symbol.len] == symbol

proc match(state : State, input, symbol : string, delimiter : char) : bool =
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


proc whitespace(state : var State, input : string) : bool =
  result = consume(state, input, re"\V*")

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


proc compressHeader(state : var State, input : string) : Option[Header] =
  # var name : string
  var value : string

  # discard whitespace(state, input)
  # state.index += parseUntil(input, name, ':', state.index)
  # name = name.strip()
  let name = consume(state, input, re"Compress\V+:")
  if not name:
    error(state, "Header name does not match \"Compress\"")
    return none(Header)
  
  discard whitespace(state, input)
  state.index +=  parseUntil(input, value, "\r\l", state.index)
  value = value.strip()
  var compression_value : CompressionType
  if value == "zlib":
    compression_value = zlib

  result = some(Header(newCompress(compression_value)))

proc genericHeader(state : var State, input : string) : Option[Header] =
  var name : string
  var value : string

  discard whitespace(state, input)
  state.index += parseUntil(input, name, ':', state.index)
  echo state.index
  name = name.strip()
  discard whitespace(state, input)
  
  state.index += parseUntil(input, value, "\r\l", state.index)
  echo state.index
  value = value.strip()
  result = some(newHeader(name, value))

proc header(state : var State, input : string) : Option[Header] =
  let name = match(state, input, re"\w+")
  if name.isNone:
    state.error("Header name not found")
    return none(Header)
  
  case name.get.match
  # of "Compress":
  #   result = compressHeader(state, input)
  else:
    result = genericHeader(state, input)
  
  # let colon = match(state, input, ":")
  # if not colon:
  #   state.error("Colon not found, not formatted as a header")
  #   return none(Header)
  # discard whitespace(state, input)

  # var h : Option[Header]
  # case name.get.match
  # of "Compress":
  #   h = compress_header(state, input)
  # else:
  #   h = genericHeader(state, input)

proc headers(state : var State, input : string) : seq[Header] =
  result = @[]
  while not newline(state, input) or atEnd(state, input):
    echo state
    let h = header(state, input)
    if h.isSome:
      result.add(h.get)

proc body(state : var State, input : string) : string =
  if atEnd(state, input):
    result = ""
  else:
    result = input[state.index .. <len(input)]

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

  #parse headers

  #parse newline
  #parse body

  #construct Request

proc parse*(input : string) : Option[Result] =
  var state = initState()

when isMainModule:
  # let input = "   123.456"
  # var s = State(index : 3)
  # echo version(s, input)
  # echo s

  discard request("CHECK SPAMC/1.5\r\l")

  # let alphabet = "abc"
  # echo alphabet[1 .. <len(alphabet)]

  var s2 = initState()
  let c = headers(s2, "Compress : zlib\r\l\r\l")
  echo s2
  # for h in c:
  #   echo $h
