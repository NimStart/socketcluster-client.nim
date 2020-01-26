import socketcluster, autome/autome, chronos, futurestream, json

type
  RemoteAction = object
    t: string
    x, y: int32


let sc = waitFor newScClient("wss://webrtsi.com/socketcluster/")
let mouseChannel = sc.subscribe("mouse")

for act in mouseChannel:
  let action = act.to(RemoteAction)
  echo action
  case action.t
  of "move":
    mouse.move(action.x, action.y)
  of "click":
    mouse.click(action.x, action.y)
  else: discard

runForever()
  