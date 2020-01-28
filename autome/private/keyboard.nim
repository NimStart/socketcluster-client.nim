from unicode import runeAt, runes
from strutils import parseEnum

type
  KeyEvent = enum
    Backspace = (8, "Backspace")
    Tab = (9, "Tab")
    Enter = (13, "Enter")
    Control = (17, "Control")
    Alt = (18, "Alt")
    Delete = (46, "Delete")
    Text = (55, "Text")
    Meta = (91, "Meta")

proc initKeykbInput(wVk, wScan: int16, dwFlags: DWORD): KEYBDINPUT {.inline.} =
  KEYBDINPUT(
    kind: INPUT_KEYBOARD,
    wVk: wVk,
    wScan: wScan,
    dwFlags: dwFlags,
    time: 0.DWORD,
    dwExtraInfo: getMessageExtraInfo())

# proc emit*(kb: KeyboardCtx, keys: string): KeyboardCtx {.discardable.} =
#   let
#     keysLen = len(keys)
#   var inputs = cast[array[0..100, KEYBDINPUT]]
#     (alloc(inputStructSize * keysLen))
#   var i = 0
#   for g in 0..(keysLen-1) * 2:
#     #echo "emit"
#     inputs[i] = initKeykbInput(VK_DELETE, 0.int16, 0.DWORD)
#     inputs[i+1] = initKeykbInput(VK_DELETE, 0.int16, KEYEVENTF_KEYUP)
#     i = i + 2
#   let res = sendInput(keysLen.uint, inputs.addr, inputStructSize)
#   dealloc(inputs.addr)
#   assert res == keysLen.uint
#   kb

proc send*(kb: KeyboardCtx, keys: string): KeyboardCtx
    {.sideEffect, discardable.} =
  ## emulates character key presses with characters in `keys` string.
  ## Make sure you have right keyboard layout set up, because this proc
  ## does not send actual characters, but underlying ASCII key codes
  ## associated with characters.
  var input = initKeykbInput(0, 0.int16, 0.DWORD)
  let eventType = parseEnum[KeyEvent](keys, KeyEvent.Text)
  if eventType == KeyEvent.Text:
    for key in runes(keys):
      input.wScan = key.int16
      # echo input.wScan
      input.dwFlags = KEYEVENTF_UNICODE
      discard sendInput(1, input.addr, inputStructSize)
      input.dwFlags = KEYEVENTF_UNICODE or KEYEVENTF_KEYUP
      discard sendInput(1, input.addr, inputStructSize)
  else:
    input.wVk = eventType.int16
    input.dwFlags = 0
    discard sendInput(1, input.addr, inputStructSize)
    input.dwFlags = KEYEVENTF_KEYUP
    discard sendInput(1, input.addr, inputStructSize)
  kb

proc wait*(kb: KeyboardCtx, ms: int32): KeyboardCtx
    {.sideEffect, discardable.} =
  ## stops execution for ``ms`` milliseconds.
  wait(ms)
  kb