import websocket, chronos, json, tables

type 
  ScClient* = WebSocket
    
  MessageData* = JsonNode
  
  Message* = object of RootObj
    event: string
    data: MessageData
  
  Response* = object of Message
    rid: int
  
  AsyncMessage* = object of Message
    cid: int

  AsyncResponse* = Future[Response]
        
  ChannelMessage = object
    channel: string
    data: MessageData

  ChannelPublish = object of RootObj
    event: string
    data: ChannelMessage

  SubscribeMessage = object of ChannelPublish
    cid: int
  
  ## ChannelStream = FutureStream[ChannelMessage]

var cid = 0
var responses = initTable[int, AsyncResponse]()

proc emit*(sc: ScClient, message: JsonNode) =
  echo "Emit: " & $message
  discard sc.send($message)
  
## proc emitAsync* (sc: ScClient, message: JsonNode): Future[AsyncResponse]
  
proc publish*(sc: ScClient, channel: string, data: MessageData): void =
  sc.emit(%* ChannelPublish(event: "#publish", data: ChannelMessage(channel: channel, data: data)))

proc subscribe*(sc: ScClient, channel: string): string  = 
  sc.emit(%* SubscribeMessage(event: "#subscribe", cid: cid, data: ChannelMessage(channel: channel, data: %* "")))
  let response = "subscribe proc cid: " & $cid
  return response

proc pong(sc: ScClient): void =
  echo "pong"
  discard sc.send("#2")

proc handshake(sc: ScClient): Future[string] {.async.} = 
  sc.emit(%* AsyncMessage(event: "#handshake", cid: cid, data: %* ""))
  let str = await sc.receiveString()
  return str

proc handleMessages(sc: ScClient) {.async.} =
  while true:
        var message = await sc.receiveString()
        if message == "#1":
            sc.pong()
        elif message == "":
          discard
        else:
          let j = parseJson(message)
          if (j{"event"}.getStr() == "#publish"):
            sc.emit(%* ChannelPublish(event: "#publish", data: ChannelMessage(channel: "nim-test2", data: MessageData(%* "\"{pong\": true}"))))
            ## let channelMessage = to(j["data"], ChannelMessage)
            ## channels.get(channelMessage.channel).write(channelMessage)
            echo j

proc newScClient*(url: string): Future[ScClient] {.async.} =
  echo "Start SC"
  let sc = await newWebSocket(url)
  echo "Got SC - handshake"
  echo await sc.handshake()
  asyncCheck handleMessages(sc)
  discard sc.subscribe("nim-test")
  return sc
 
let sc = waitFor newScClient("wss://webrtsi.com/socketcluster/")

runForever()
  