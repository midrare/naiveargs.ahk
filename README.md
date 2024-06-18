# naiveargs.ahk
**Parse command-line arguments in AutoHotkey with zero setup.**

## Usage
**naiveargs.ahk** is different from traditional arg parsers; there is no schema that the parser validates the input against. Instead, all inputs are valid, and the parser infers the schema from the inputs.

Put `naiveargs.ahk` in the same folder as your main script, then import it using `#include "%A_ScriptDir%/naiveargs.ahk"`.  
<sub>Optional: install using [ahkpm](https://ahkpm.dev/)</sub>  

Parse your arguments using `ParseArguments(A_Args)`, which returns a `NaiveArguments` object.

```ahk
#include "%A_ScriptDir%/naiveargs.ahk"
Args := ParseArguments(A_Args)
```

Get your parsed arguments by calling the methods on the returned object.

```bash
#        positionals      flags & named params          remaining
#
> demo.ahk install -v -v  --dir "c:/" --requires a b c -- x y z
#           ^        ^         ^                ^           ^
#           |        |         |                |           |
#   Args.Positionals | Args.Param("dir")        |     Args.Remaining
#                    |                          |
#              Args.Count("v")       Args.Params("requires")
#                                              ^
```

### How parsing works
Argument parsing proceeds through a sequence of heuristic-based stages.

 1. Parse positionals.
    An argument encountered is added to the list of positionals (i.e. the array in `Args.Positionals`. This continues until an arg prefixed with `/`, `-`, or `--` is encountered or all arguments are exhausted.
 2. Parse named params.
    An argument prefixed with `/`, `-`, or `--` is considered a param name. Upon encountering a param name, its seen count (i.e. the value returned by `.Count(ParamName)`) is increased by one. Any un-prefixed args following a param name are considered a value and is appended to the corresponding array (i.e. `Args.Param(ParamName)` or `Args.Params(ParamName)`). This continues until `--` (full argument, not a prefix) is encountered or all arguments are exhausted.
 3. Gather remaining args.
    All remaining arguments are added to an array (i.e. `Args.Remaining`) and the arguments list is considered exhausted. The `--` itself is not added.


### Detailed usage
```ahk
#include "%A_ScriptDir%/naiveargs.ahk"
Args := ParseArguments(A_Args)
```

**`Args.Positionals`**  
This contains an array of strings. If there are no positionals, this contains `[]`. Action-style params such as `install`, `uninstall` that set the "mode" for your script should be implemented this way.


**`Args.Count("verbose")`**  
This returns an int, the number of times of the given param name has been encountered. To be considered a param name, an argument must be prefixed with `/`, `-`, or `--`. If the param name is not present, this returns `0`. Params that enable (e.g. `--dry-run`), disable (e.g. `--no-clobber`), or increment something (e.g. `-v`, `-q`) should be implemented this way.

```ahk
If ((Args.Count("v") + Args.Count("verbose")) > 0) {
    ; print verbose stuff
}
```

**`Args.Param("file") and Args.Params("file")`**  
`Args.Param("file")` returns the first value for the param name `--file`. If the param name is not present, this returns `""`. A default value can be specified with `Args.Param("file", "c:/log.txt")`, which will be returned if the param name was not found. If `unset` is provided as the default value, the parser will throw an exception if not found.

```ahk
If (Args.Param("file")) {
    ProcessFile(Args.Param("file"))
}
```

`Args.Params("file")` (extra s) returns all values for the param name `--file`. If the param name is not present or no values were given, this returns `[]`. A default value can be specified with `Args.Params("file", ["c:/log.txt"])`, which will be returned if the param name was not found. If `unset` is provided as the default value, the parser will throw an exception if not found.

```ahk
For (FileName in Args.Params("file")) {
    ProcessFile(FileName)
}
```

**`Args.Remaining`**  
This returns an array of strings. All arguments after a `--` (full argument, not param name prefix) are collected in ths array, excluding the `--` itself. If there are no remaining args, this returns `[]`.

```ahk
If (Args.Remaining.Length > 0) {
    ; do your own processing
}
```
