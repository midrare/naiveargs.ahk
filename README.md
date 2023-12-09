# naiveargs.ahk
**Parse command-line arguments in AutoHotkey with zero setup.**

## Usage
```ahk2
#Requires AutoHotKey >=2.0
#include "%A_ScriptDir%/naiveargs.ahk"

; no setup. everything is inferred from the actual
; arguments passed. every arg starting with
; /, -, or -- is a param name ; the next arg, if
; there is one, is its value
Args := NaiveParseArguments(A_Args)

; counting flags (as int)
; e.g main.ahk -v -v --verbose -> 3
Verbosity := Args.GetCount("v") + Args.GetCount("verbose")

; get single value (as string)
; e.g. main.ahk --foo "a" -> "a"
Value := Args.GetParam("foo")

; get repeatable values (as Array)
; e.g. main.ahk --foo "a" --foo "b" --foo "c"
;      -> [ "a", "b", "c" ]
Values := Args.GetParam("foo")

; get remaining args (as Array)
; e.g. main.ahk --foo "a" --foo "b" "x" "y" "z"
;      -> [ "x", "y", "z" ]
Remaining := Args.GetRemaining()
```
