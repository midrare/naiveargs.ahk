; naiveargs.ahk
; An argument parser for autohotkey
; Last modified: 2024/04/20

; Copyright (c) 2024 midrare
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


#Requires AutoHotkey >=2.0

Class NaiveArguments {
    __New(Positionals, Named, Counted, Remaining) {
        this.Positionals := Positionals || Array()
        this.NameToValues := Named || Map()
        this.NameToCount := Counted || Map()
        this.Remaining := Remaining || Array()
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
        If (!this.NameToValues.Has(Name)
                || this.NameToValues[Name].Length <= 0) {
            Return
        }
        Return this.NameToValues[Name][1]
    }

    GetParams(Name) {
        if (!this.NameToValues.Has(Name)) {
            Return []
        }
        Return this.NameToValues[Name]
    }
}


NaiveParseArguments(Args) {
    Args_ := Args.Clone()

    PHASE_POSITIONAL := 0
    PHASE_FLAGS := 1
    PHASE_REMAINING := 2
    RE_PREFIX_EQ := "^(?!--$)(?:--?|/)([^:=]+)[:=](.+)"
    RE_PREFIX := "^(?!--$)(?:--?|/)(.+)"

    Positionals := Array()
    NameToValues := Map()
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

        ; TODO handle --no-aaa flags
        If (Phase == PHASE_FLAGS) {
            Name := ""
            Value := unset

            Match := {}
            If (RegExMatch(Arg, RE_PREFIX_EQ, &Match) > 0) {
                Name := Match[1]
                Value := Match[2]
            } Else If (RegExMatch(Arg, RE_PREFIX, &Match) > 0) {
                Name := Match[1]
            }

            If (Name && StrLen(Name) > 0) {
                If (!NameToCount.Has(Name)) {
                    NameToCount[Name] := 0
                }
                NameToCount[Name] := NameToCount[Name] + 1

                If (!NameToValues.Has(Name)) {
                    NameToValues[Name] := []
                }

                If (IsSet(Value)) {
                    NameToValues[Name].Push(Value)
                }

                While (Args_.Length > 0) {
                    If (Args_[1] == "--" || Args_[1] ~= RE_PREFIX) {
                        Break
                    }

                    Value := Args_.RemoveAt(1)
                    NameToValues[Name].Push(Value)
                }
            }
        }

        If ((Phase < PHASE_REMAINING) && (Arg == "--")) {
            Phase := PHASE_REMAINING
        } Else If (Phase == PHASE_REMAINING) {
            Remaining.Push(Arg)
        }
    }

    Return NaiveArguments(Positionals, NameToValues, NameToCount, Remaining)
}

