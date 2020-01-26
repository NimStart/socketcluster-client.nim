## This module contains useful procs that can be used to automate boring GUI
## tasks.
##
## Concept: contexts
## ------------------------
## The ``autome`` namespace contains several variables available for you:
## `mouse<#mouse>`_ and `keyboard<#keyboard>`_. They are called
## ``mouse context`` and ``keyboard context`` correspondingly. To use mouse or
## keyboard procs, you must pass these variables in them or create your
## own context.
##
## .. code-block:: nim
##   move(mouse, 640, 480) # move mouse to 640, 480
##   # .. or ..
##   mouse.move(640, 480)
##
## All of mouse or keyboard procs returns same context they have received,
## so you can ``chain`` procs of same context:
##
## .. code-block:: nim
##   mouse
##     .move(640, 480)
##     .click()
##     .move(123, 321)
##
## There are methods that are not bound to specific context, but accept
## them to not break proc chaining (`wait<#wait>`_ proc for example).

{.deadCodeElim: on.}

import winlean

type
  KeyboardCtx* = ref object ## represents keyboard context.
  MouseCtx* = ref object ## represents mouse context.
    perActionWaitTime: int32
  Point* {.pure, final.} = tuple ## represents point on the screen.
    x: int32
    y: int32
 

include private/imports
include private/common
include private/mouse
include private/keyboard
