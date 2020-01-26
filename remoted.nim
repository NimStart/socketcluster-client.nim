import socketcluster, autome/autome, chronos, futurestream, json

type
  ActionType = enum
    move = "move", click = "click", scroll = "scroll", text = "text"
  RemoteAction = object
    case t: ActionType
    of ActionType.move, ActionType.click:
      x, y: int32
    of ActionType.scroll:
      delta: int32
    of ActionType.text:
      text: string


let mouse = MouseCtx()
let keyboard = KeyboardCtx()

let sc = waitFor newScClient("wss://webrtsi.com/socketcluster/")
let mouseChannel = sc.subscribe("mouse")

for act in mouseChannel:
  try:
    var action = act.to(RemoteAction)
    echo action
    if action.t == ActionType.text:
      keyboard.send(action.text)
    elif action.t == ActionType.move:
      mouse.move(action.x, action.y)
    case action.t
    elif action.t == ActionType.click:
      mouse.move(action.x, action.y).click()
    elif action.t == ActionType.scroll:
      mouse.scroll(action.delta)
  except:
    echo "Error parsing message", act

runForever()
  