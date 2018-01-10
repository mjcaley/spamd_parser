import request, response, headers, options

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

proc verb(state : var State, input : string) : string =
  discard

proc request*(input : string) : Option[Request] =
  discard

proc parse*(input : string) : Option[Result] =
  discard
