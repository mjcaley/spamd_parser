type
  CompressionType* = enum
    zlib

  MessageClassType* = enum
    ham,
    spam

  Action* = enum
    local,
    remote


  Header* = ref object of RootObj
    name* : string
    value* : string

  Compress* = ref object of Header
    algorithm* : CompressionType

  ContentLength* = ref object of Header
    length* : int

  DidRemove* = ref object of Header
    action* : Action

  DidSet* = ref object of Header
    action* : Action

  Remove* = ref object of Header
    action* : Action

  SetHeader* = ref object of Header
    action* : Action

  MessageClass* = ref object of Header
    class* : MessageClassType

  User* = ref object of Header
    username* : string

  Spam* = ref object of Header
    spam* : bool
    score* : float
    threshold* : float


proc newHeader*(name, value : string) : Header =
  Header(name : name, value : value)

proc newCompress*(algorithm = zlib) : Compress =
  Compress(name : "Compress", algorithm : algorithm)

proc newContentLength*(length : int) : ContentLength =
  ContentLength(name : "Content-length", length : length)

proc newDidRemove*(action : Action) : DidRemove =
  DidRemove(name : "DidRemove", action : action)

proc newDidSet*(action : Action) : DidSet =
  DidSet(name : "DidSet", action : action)

proc newRemove*(action : Action) : Remove =
  Remove(name : "Remove", action : action)

proc newSet*(action : Action) : SetHeader =
  SetHeader(name : "Set", action : action)

proc newMessageClass*(class : MessageClassType) : MessageClass =
  MessageClass(name : "Message-class", class : class)

proc newSpam*(spam : bool, score, threshold : float) : Spam =
  Spam(name : "Spam", spam : spam, score : score, threshold : threshold)

proc newUser*(username : string) : User =
  User(name : "User", username : username)
