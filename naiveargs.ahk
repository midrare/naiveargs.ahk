; naiveargs.ahk
; An argument parser for autohotkey
; Last modified: 2023/12/08

; Copyright (c) 2023 midrare
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.


Class NaiveArguments {
    __New(Positionals, Named, Counted, Remaining) {
        this.Positionals := Positionals
        this.NameToValue := Named
        this.NameToCount := Counted
        this.Remaining := Remaining
    }

    GetPositionals() {
        Return this.Positionals
    }

    GetRemaining() {
        Return this.Remaining
    }

    GetCount(Name) {
        If (!this.NameToCount.Has(Name)) {
            Return 0
        }
        Return this.NameToCount[Name]
    }

    GetParam(Name) {
        If (!this.NameToValue.Has(Name)) {
            Return
        }
        Return this.NameToValue[Name]
    }
}


NaiveParseArguments(Args) {
    Args_ := Args.Clone()

    PHASE_POSITIONAL := 0
    PHASE_FLAGS := 1
    PHASE_REMAINING := 2

    Positionals := Array()
    NameToValue := Map()
    NameToCount := Map()
    Remaining := Array()

    Phase := PHASE_POSITIONAL

    While (Args_.Length > 0) {
        Arg := Args_.RemoveAt(1)

        If (Phase <= PHASE_POSITIONAL) {
            If (Arg ~= "^(--?|/)") {
                Phase := PHASE_FLAGS
            } Else {
                Positionals.Push(Arg)
            }
        }

        If (Phase == PHASE_FLAGS) {
            Match := {}
            If (Arg ~= "^(--?|/)[^:=]+[:=].+") {
                RegExMatch(Arg, "(?:--?|/)([^:=]+)[:=](.+)", &Match)
                Name := Match[1]
                Value := Match[2]
                NameToValue[Name] := Value
            } Else If (Arg != "--"
                    && Args_.Length > 0
                    && !(Args_[1] ~= "^(--?[^-]|/.|--$)")) {
                RegExMatch(Arg, "(?:--?|/)(.+)", &Match)
                Name := Match[1]
                While (Args_.Length > 0
                        && !(Args_[1] ~= "^(--?[^-]|/.|--$)")) {
                    Value := Args_.RemoveAt(1)
                    If (!NameToValue.Has(Name)) {
                        NameToValue[Name] := Value
                    } Else {
                        If (!IsObject(NameToValue[Name])) {
                            NameToValue[Name] := [ NameToValue[Name] ]
                        }
                        NameToValue[Name].Push(Value)
                    }
                }
            } Else If (Arg ~= "^(?:^--?|/)") {
                RegExMatch(Arg, "(?:--?|/)(.+)", &Match)
                Name := Match[1]
                If (!NameToCount.Has(Name)) {
                    NameToCount[Name] := 0
                }
                NameToCount[Name] := NameToCount[Name] + 1
            }
        }

        If ((Phase < PHASE_REMAINING) && (Arg == "--")) {
            Phase := PHASE_REMAINING
        } Else If (Phase == PHASE_REMAINING) {
            Remaining.Push(Arg)
        }
    }

    Return NaiveArguments(Positionals, NameToValue, NameToCount, Remaining)
}

