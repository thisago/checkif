{.experimental: "codeReordering".}
from std/os import fileExists, dirExists, execShellCmd
from std/strutils import `%`, contains, toLowerAscii

type
  FileCond* {.pure.} = enum
    exists, dataHas, dataIs
  DirCond* {.pure.} = enum
    exists

proc tryReadFile(file: string): string =
  try:
    readFile file
  except IOError:
    ""


proc checkFile(
  condition: FileCond;
  paths: seq[string];
  invert = false;
  min = 0;
  str = "";
  caseInsensitive = false;
  then = "";
  `else` = ""
): int =
  ## Check if expression is meet in a file
  ## 
  ## If `then` or `else` was provided, the return code will be of the command
  proc check(path: string; str = ""): bool =
    proc txt(s: string): string =
      if caseInsensitive: s.toLowerAscii
      else: s
    case condition:
    of FileCond.exists:
      fileExists path
    of FileCond.dataHas:
      str.txt in path.tryReadFile.txt
    of FileCond.dataIs:
      str.txt == path.tryReadFile.txt

  checkCondition()

proc `not`(x: int): int =
  if x == 0: 1 else: 0

proc checkDir(
  condition: DirCond;
  paths: seq[string];
  invert = false;
  min = 0;
  then = "";
  `else` = ""
): int =
  ## Check if expression is meet in a directory
  ## 
  ## If `then` or `else` was provided, the return code will be of the command
  proc check(path: string; str = ""): bool =
    case condition:
    of DirCond.exists:
      dirExists path

  checkCondition()

template checkCondition: untyped {.dirty.} =
  result = 1

  if paths.len == 0:
    quit "Provide the paths", 64

  when condition is FileCond:
    if condition in {dataHas, dataIs}:
      if str.len == 0:
        quit "Provide the text to verify", 64
  
  when condition is DirCond:
    const str = ""

  var meet = 0
  for path in paths:
    let res = path.check str
    if res:
      inc meet

  block:
    echo meet
    echo paths.len
    if min > 0:
      if meet < min:
        break
    else:
      if meet < paths.len:
        break
    result = 0

  if invert:
    result = not result

  if result == 0:
    if then.len > 0:
      result = execShellCmd then
  else:
    if `else`.len > 0:
      result =  execShellCmd `else`

proc checkCommand(
  commands: seq[string];
  then = "";
  `else` = "";
  stopOnError = true
): int =
  ## Run the `then` if `cmd` runs ok, else runs `else`
  result = 0
  for command in commands:
    let res = execShellCmd command
    if res != 0:
      result = res
      if stopOnError:
        break

  if result == 0:
    if then.len > 0:
      result = execShellCmd then
  else:
    if `else`.len > 0:
      result = execShellCmd `else`

when isMainModule:
  import pkg/cligen
  from std/strutils import join
  proc condOpts(xs: typedesc[enum]): string =
    var res: seq[string]
    for x in xs:
      res.add $x
    result = res.join " or "
  const
    fileConds = condOpts FileCond
    dirConds = condOpts DirCond
  dispatchMulti(
    [
      checkFile,
      cmdName = "file",
      short = {
        "invert": 'n',
        "caseInsensitive": 'i',
      },
      
      help = {
        "condition": "The file check condition. Can be one of: " & fileConds,
        "paths": "The files to check, can be any quantity",
        "invert": "Invert result",
        "min": "Minimum succeeded checks",
        "str": "The text to be searched",
        "then": "The command to be run on success",
        "else": "The command to be run on error",
        "caseInsensitive": "Ignore uppercase and lowercase",
      }
    ],
    [
      checkDir,
      cmdName = "dir",
      short = {
        "invert": 'n',
      },
      help = {
        "condition": "The dir check condition. Can be one of: " & dirConds,
        "paths": "The files to check, can be any quantity",
        "invert": "Invert result",
        "min": "Minimum succeeded checks",
        "then": "The command to be run on success",
        "else": "The command to be run on error",
      }
    ],
    [
      checkCommand,
      cmdName = "command",
      short = {
      },
      help = {
        "then": "The command to be run on success",
        "else": "The command to be run on error",
        "stopOnError": "If some error occur in `commands` it will stop",
      }
    ],
  )
