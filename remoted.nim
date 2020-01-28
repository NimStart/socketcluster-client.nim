import socketcluster, autome/autome, chronos, futurestream, json, fidget, vmath, typography, tables
from os import getAppFilename, splitFile

type
  ActionType {.pure.} = enum 
    move = "move", click = "click", scroll = "scroll", text = "text", disconnect = "disconnect"
  RemoteAction = object
    case event: ActionType
    of ActionType.move, ActionType.click:
      x, y: int32
    of ActionType.scroll:
      delta: int32
    of ActionType.text:
      text: string
    of ActionType.disconnect:
      discard

let mouse = MouseCtx()
let keyboard = KeyboardCtx()

let sc = waitFor newScClient("wss://webrtsi.com/socketcluster/")
let remoteAgentChannel = sc.subscribe(splitFile(getAppFilename()).name & "::remote-control")

fonts["Arial"] = readFontTtf(r"C:\Windows\Fonts\arial.ttf")

drawMain = proc() =
  frame "Message":
    box 0, 0, 283, 200
    constraints cMin, cMin
    fill "#9cf9dd"
    cornerRadius 14
    strokeWeight 1
    rectangle "Textbox":
      box 26, 35, 231, 131
      constraints cMin, cMin
      fill "#ffffff"
      cornerRadius 7
      strokeWeight 1
    text "Agent is currently conncted to your computer":
      box 42, 35, 203, 131
      constraints cMin, cMin
      fill "#000000"
      strokeWeight 1
      font "Arial", 18, 200, 0, 0, 0
      characters "Agent is currently connected to your computer"

       
windowFrame = vec2(283, 200)

try:
  startFidget()
except:
  let
    e = getCurrentException()
    msg = getCurrentExceptionMsg()
  echo "Got exception ", repr(e), " with message ", msg

for remoteAction in remoteAgentChannel:
  try:
    var action = remoteAction.to(RemoteAction)
    if action.event == ActionType.text:
      keyboard.send(action.text)
    elif action.event == ActionType.move:
      mouse.move(action.x, action.y)
    elif action.event == ActionType.click:
      mouse.move(action.x, action.y).click()
    elif action.event == ActionType.scroll:
      mouse.scroll(action.delta)
    elif action.event == ActionType.disconnect:
      remoteAgentChannel.complete()
  except:
    echo "Error parsing message: ", remoteAction, repr(getCurrentException())

echo "Closing"
  