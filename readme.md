# checkif

A easy to use CLI tool that allows you make advanced checking (specially on Windows)

## Why

The windows CMD (at least Win 7) is very inconsistent:

- Commands that runs if previous was success or not (`a && b || c`) works just in a batch file
- Cannot check inline in a CMD
  - If text exists in /is the content
  - File/dir exists
  - Check multiple files and expect at least some succeeds

## Help

### Base

```
Usage:
  checkif {SUBCMD}  [sub-command options & parameters]
where {SUBCMD} is one of:
  help     print comprehensive or per-cmd help
  file     Check if expression is meet in a file
  dir      Check if expression is meet in a directory
  command  Run the `then` if `cmd` runs ok, else runs `else`

checkif {-h|--help} or with no args at all prints this message.
checkif --help-syntax gives general cligen syntax help.
Run "checkif {help SUBCMD|SUBCMD --help}" to see help for just SUBCMD.
Run "checkif help" to get *comprehensive* help.
```

### File

```
Usage:
  file [REQUIRED,optional-params] The files to check, can be any quantity
Check if expression is meet in a file

If `then` or `else` was provided, the return code will be of the command
Options:
  -h, --help                                 print this cligen-erated help
  --help-syntax                              advanced: prepend,plurals,..
  -c=, --condition=      FileCond  REQUIRED  The file check condition. Can be one of: exists or dataHas or dataIs or dataNum
  -n, --invert           bool      false     Invert result
  -m=, --min=            int       0         Minimum succeeded checks
  -s=, --str=            string    ""        The text to be searched
  -i, --caseInsensitive  bool      false     Ignore uppercase and lowercase
  -t=, --then=           string    ""        The command to be run on success
  -e=, --else=           string    ""        The command to be run on error
  -l, --headless         bool      false     If some error occur in `commands` it will stop
  --moreThan=            float     0.0       Configure the `dataNum` maximum acceptable number (default: maximum number)
  --lessThan=            float     inf       Configure the `dataNum` minimum acceptable number (default: 0)
  --stripNum             bool      false     Removes everything that isn't digits from file data
```

### Dir

```
Usage:
  dir [REQUIRED,optional-params] The files to check, can be any quantity
Check if expression is meet in a directory

If `then` or `else` was provided, the return code will be of the command
Options:
  -h, --help                            print this cligen-erated help
  --help-syntax                         advanced: prepend,plurals,..
  -c=, --condition=  DirCond  REQUIRED  The dir check condition. Can be one of: exists
  -n, --invert       bool     false     Invert result
  -m=, --min=        int      0         Minimum succeeded checks
  -t=, --then=       string   ""        The command to be run on success
  -e=, --else=       string   ""        The command to be run on error
  --headless         bool     false     If some error occur in `commands` it will stop
```

### Command

```
Usage:
  command [optional-params] [commands: string...]
Run the `then` if `cmd` runs ok, else runs `else`
Options:
  -h, --help                        print this cligen-erated help
  --help-syntax                     advanced: prepend,plurals,..
  -t=, --then=       string  ""     The command to be run on success
  -e=, --else=       string  ""     The command to be run on error
  -s, --stopOnError  bool    true   If some error occur in `commands` it will stop
  --headless         bool    false  If some error occur in `commands` it will stop
```

## TODO

- [ ] Add info to readme

## License

MIT
