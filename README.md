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
#         |--vvv--|------------------vvv---------------------|---vvv--
> demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
```

 1. Parse positionals.
    Arguments not prefixed with `/`, `-`, or `--` are added to the list of positionals (i.e. the array in `.Positionals`. This continues until a prefixed arg is encountered or all arguments are exhausted.
 2. Parse named params.
    An argument prefixed with `/`, `-`, or `--` is considered a param name. Upon encountering a param name, its seen count (i.e. the value returned by `.Count(ParamName)`) is increased by one. Immediately following a param name, arg(s) without this prefix are considered a value associated with the param name; the value is appended to the associated array (i.e. accessed by `.Param(ParamName)` or `.Params(ParamName)`). This continues until `--` (full argument, not a prefix) is encountered or all arguments are exhausted.
 3. Gather remaining args.
    Upon encountering a bare `--` argument, all remaining arguments are added to an array (i.e. the array in`.Remaining`) and the arguments list is considered exhausted. (The `--` itself is not added.)


### Using the parser
Import **naiveargs.ahk** and parse your arguments using `NaiveParseArguments(A_Args)`, which returns a `NaiveArguments` object.

```ahk
#include "%A_ScriptDir%/naiveargs.ahk"

; no setup!
Args := NaiveParseArguments(A_Args)
```

**Get positionals using `.Positionals`.** If there are no positionals, this returns `[]`. Action-style params such as `install`, `uninstall` that set the "mode" for your script should be implemented this way.

```ahk
;          vvvvvvv
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
Args.Positionals
;   -> ["install"]
```

**Check flags using `.Count(ParamName)`.** If the param name is not present, this returns `0`. Params that enable (e.g. `--dry-run`), disable (e.g. `--no-clobber`), or increment something (e.g. `-v`, `-q`) should be implemented this way.

```ahk
;                  vvvvvvvvvvvvvvv
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
Args.Count("v") + Args.Count("verbose")
;   -> 3

;                  (no -q or --quiet given)
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
Args.Count("q") + Args.Count("quiet")
;   -> 0
```

**Get the first value of a named param using `.Param(ParamName)`.** If the param name is not found, this returns `""`. **To get all values, use `.Params(ParamName)` (notice the "s").** If the param name is not found, this returns `[]`. Params that consist of a key-value(s) pair (e.g. `--output-dir DIR`, `--add-files a.txt b.txt c.txt`) should be implemented this way.

```ahk
;                                  vvvvvvvvvv v
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
Args.Param("requires")
;   -> "a"

;                                  vvvvvvvvvv vvvvv
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
Args.Params("requires")
;   -> ["a", "b", "c"]
```

**Get arguments after `--` using `.Remaining`.** (This excludes the `--` itself.) If there are no remaining args, this returns `[]`. Arguments that should not be handled by the arg parser should be implemented this way.

```ahk
;                                                             vv vvvvv
; demo.ahk install -v -v --verbose --requires a b c --dry-run -- x y z
Args.Remaining
;   -> ["x", "y", "z"]
```
