import
    common,
    headers
  
type
  Response* = ref ResponseObj
  ResponseObj = object
    protocol* : Protocol
    version* : string
    code*: int
    message* : string
    headers* : seq[Header]
    body* : string

proc newResponse*(protocol = SPAMD,
                version : string,
                code : int,
                message : string,
                headers = @[Header],
                body = "") : Response =
  Response(protocol : protocol,
           version : version,
           code : code,
           message : message,
           headers : headers,
           body : body)
  