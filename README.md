# naiveargs.ahk
**Parse command-line arguments in AutoHotkey with zero setup.**

## Usage
**naiveargs.ahk** is different from traditional arg parsers; there is no schema that the parser validates the input against. Instead, all inputs are valid, and the parser infers the schema from the inputs.

Put `naiveargs.ahk` in the same folder as your main script, then import it using `#include "%A_ScriptDir%/naiveargs.ahk"`.  
<sub>Optional: install using [ahkpm](https://ahkpm.dev/)</sub>  

### How parsing works
Argument parsing proceeds through a sequence of heuristic-based stages.

```bash
#        positionals         flags & named params              remaining
#            vvv                     vvv                          vvv
> demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
```

 1. If the argument is not prefixed (does not start with `/`, `-`, or `--`), the argument is added to the list of positionals. This continues until a prefixed arg is encountered or all arguments are exhausted.
 2. An argument prefixed with `/`, `-`, or `--` is considered a parameter name. An argument without this prefix is considered a value. Upon encountering a param name, its seen count (i.e. `GetCount(ParamName)`) is increased by one. Upon encountering a value, the value is appended to an array (i.e. `GetParam(ParamName)` or `GetParams(ParamName)`) associated with the param name last encountered. This continues until `--` (full argument, not a prefix) is encountered or all arguments are exhausted.
 3. Upon encountering a bare `--` argument, all remaining arguments are added to an array (i.e. `GetRemaining()`) and the arguments list is considered exhausted. (The `--` itself is not added.)


### Using the parser
Import **naiveargs.ahk** and parse your arguments using `NaiveParseArguments(A_Args)`, which returns a `NaiveArguments` object.

```ahk
#include "%A_ScriptDir%/naiveargs.ahk"

; no setup!
Args := NaiveParseArguments(A_Args)
```

Get positionals using `GetPositionals()`. Action-style params such as `install`, `uninstall` that set the "mode" for your script should be implemented this way.

```ahk
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
;          ^^^^^^^
Args.GetPositionals()  ; -> ["install"]
```

Check flags using `GetCount(ParamName)`. Params that enable (e.g. `--dry-run`), disable (e.g. `--no-clobber`), or increment something (e.g. `-v`, `-q`) should be implemented this way. You can use `GetCount(ParamName)` even if the flag is not in the actual inputs (in this case it will just return `0`).

```ahk
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
;                  ^^^^^^^^^^^^^^^
Args.GetCount("v") + Args.GetCount("verbose")  ; -> 3

; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
Args.GetCount("q") + Args.GetCount("quiet")  ; -> 0
```

Get the first value of a named param using `GetParam(ParamName)`. If the param name is not found, this returns `""`. To get all values, use `GetParams(ParamName)` (notice the "s"). If the param name is not found, this returns `[]`.

```ahk
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
;                                  ^^^^^^^^^^ ^
Args.GetParam("requires")  ; -> "a"

; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
;                                  ^^^^^^^^^^ ^^^^^
Args.GetParams("requires")  ; -> ["a", "b", "c"]
```

All arguments after a `--` are considered remaining args.

```ahk
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
;                                                             ^^ ^^^^^
Args.GetRemaining()  ; -> ["x", "y", "z"]
```

