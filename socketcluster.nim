import websocket, chronos, json, tables, times, strutils, futurestream

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
  
  ChannelStream* = FutureStream[MessageData]

template benchmark(benchmarkName: string, code: untyped) =
    block:
      let t0 = epochTime()
      code
      let elapsed = epochTime() - t0
      let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
      echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

var cid = 1
var responses = initTable[int, AsyncResponse]()
var channels = initTable[string, ChannelStream]()

proc emit*(sc: ScClient, message: JsonNode) =
  echo "Emit: " & $message
  discard sc.send($message)
  
## proc emitAsync* (sc: ScClient, message: JsonNode): Future[AsyncResponse]
  
proc publish*(sc: ScClient, channel: string, data: MessageData): void =
  sc.emit(%* ChannelPublish(event: "#publish", data: ChannelMessage(channel: channel, data: data)))

proc subscribe*(sc: ScClient, channel: string): ChannelStream  = 
  sc.emit(%* SubscribeMessage(event: "#subscribe", cid: cid, data: ChannelMessage(channel: channel, data: %* "")))
  let response = "subscribe proc cid: " & $cid
  channels[channel] = ChannelStream(newFutureStream[MessageData](response))
  return channels[channel]

proc pong(sc: ScClient): void =
  discard sc.send("#2")

proc handshake(sc: ScClient): Future[string] {.async.} = 
  sc.emit(%* AsyncMessage(event: "#handshake", cid: cid, data: %* "{}"))
  cid.inc
  let str = await sc.receiveString()
  return str


proc handleMessages(sc: ScClient) {.async.} =
  while sc.readyState == Open:
        var message = await sc.receiveString()
        if message == "#1" or message == "":
            sc.pong()
        elif message.len() > 0:
          let channelMessage = parseJson(message)
          if channelMessage{"event"}.getStr("event") == "#publish":
            sc.emit(%* ChannelPublish(event: "#publish", data: ChannelMessage(channel: "nim-test2", data: MessageData(%* {"pong": true}))))
            let channelName = channelMessage{"data"}{"channel"}.getStr("channel")
            discard channels[channelName].write(channelMessage{"data"}{"data"})
            echo channelMessage
            

proc newScClient*(url: string): Future[ScClient] {.async.} =
  let sc = await newWebSocket(url)
  benchmark "handshake took: ":
    echo await sc.handshake()
  benchmark "handler took: ":
    asyncCheck handleMessages(sc)
  return sc
