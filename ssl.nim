import httpclient, base64, random

var c = newHttpClient()
var secStr = newString(16)
for i in 0 ..< secStr.len:
  secStr[i] = char rand(255)
  
let secKey = base64.encode(secStr)

c.headers = newHttpHeaders({
  "Connection": "Upgrade",
  "Upgrade": "websocket",
  "Sec-WebSocket-Version": "13",
  "Sec-WebSocket-Key": secKey,
  "Sec-WebSocket-Extensions": "client_max_window_bits"
})

echo c.get("wss://webrtsi.com/socketcluster/").headers