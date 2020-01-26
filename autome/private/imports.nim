import winlean

type
  RECT {.pure, final.} = tuple 
    left, top, right, bottom: int32
  MOUSEINPUT {.pure, final.} = object
    kind: DWORD
    dx: LONG
    dy: LONG
    mouseData: DWORD
    dwFlags: DWORD
    time: DWORD
    dwExtraInfo: pointer
  KEYBDINPUT {.pure, final.} = object
    kind: DWORD
    wVk: int16
    wScan: int16
    dwFlags: DWORD
    time: DWORD
    dwExtraInfo: pointer

const
  inputStructSize = 28
  INPUT_MOUSE = 0
  INPUT_KEYBOARD = 1
  MOUSEEVENTF_ABSOLUTE = 0x8000
  MOUSEEVENTF_LEFTDOWN = 0x0002
  MOUSEEVENTF_LEFTUP = 0x0004
  MOUSEEVENTF_RIGHTDOWN = 0x0008
  MOUSEEVENTF_RIGHTUP = 0x0010
  MOUSEEVENTF_MIDDLEDOWN = 0x0020
  MOUSEEVENTF_MIDDLEUP = 0x0040
  MOUSEEVENTF_WHEEL = 0x0800
  KEYEVENTF_KEYUP = 0x0002
  KEYEVENTF_UNICODE = 0x0004
  KEYEVENTF_SCANCODE = 0X0008
  SWP_NOSIZE = 0x0001.uint32
  SWP_NOMOVE = 0x0002.uint32
  SWP_NOACTIVATE = 0x0010.uint32
  #SW_SHOWNORMAL = 1.uint32
  SW_RESTORE = 9.uint32
  WM_TIMER = 0x0113
  WM_HOTKEY = 0x0312
  HORZRES = 8.int
  VERTRES = 10.int
  #COLOR_WINDOW = 5.Handle

when useWinUnicode:
  type WinString = WideCString ## ``cstring`` when ``useWinAnsi`` defined,
  ## ``WideCString`` otherwise.
else:
  type WinString = cstring ## ``cstring`` when ``useWinAnsi`` defined,
  ## ``WideCString`` otherwise.

# proc newWinString(str: string): WinString =
#   if str == nil:
#     result = nil
#   else:
#     when useWinUnicode:
#       result = newWideCString(str)
#     else:
#       result = cstring(str)

when defined(automestatic):
  {.push callConv: stdcall.} # 1
else:
  {.push callConv: stdcall, dynlib: "kernel32".} # 2


proc sleep(dwMilliseconds: DWORD): void {.importc: "Sleep".}

proc getCurrentThreadId(): DWORD {.importc: "GetCurrentThreadId".}

when not defined(automestatic):
  {.pop.} # 2
  {.push callConv: stdcall, dynlib: "user32".} # 2

proc getCursorPos(lpPoint: ptr POINT): WINBOOL {.importc: "GetCursorPos".}

proc setCursorPos(x: int, y: int): WINBOOL {.importc: "SetCursorPos".}

proc sendInput(nInputs: uint, pInputs: pointer, cbSize: int): uint
  {.importc: "SendInput".}

proc getMessageExtraInfo(): pointer {.importc: "GetMessageExtraInfo".}