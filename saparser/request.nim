import
  common,
  headers

type
  Verb* = enum
    CHECK,
    HEADERS,
    PING,
    PROCESS,
    REPORT,
    REPORT_IFSPAM,
    TELL,
    SYMBOLS

  Request* = ref RequestObj
  RequestObj = object
    verb* : Verb
    protocol* : Protocol
    version* : string
    message* : string
    headers* : seq[Header]
    body* : string

proc newRequest*(verb: Verb,
                 protocol = SPAMC,
                 version, message : string,
                 headers = @[Header],
                 body = "") : Request =
  Request(verb : verb,
          protocol : protocol,
          version : version,
          message : message,
          headers : headers,
          body : body)
