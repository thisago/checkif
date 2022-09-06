{.experimental: "codeReordering".}
from std/os import fileExists, dirExists
from std/strutils import `%`, contains, toLowerAscii, join, strip, AllChars, Digits
from std/osproc import close, startProcess, poDaemon, poStdErrToStdOut,
                       peekExitCode, readLines, poUsePath, poEvalCommand

from pkg/util/forStr import tryParseFloat

type
  FileCond* {.pure.} = enum
    exists, dataHas, dataIs, dataNum
  DirCond* {.pure.} = enum
    exists

proc tryReadFile(file: string): string =
  try:
    readFile file
  except IOError:
    ""

proc execCmd(cmd: string; headless: bool): int =
  ## Executes the command
  result = 1
  var opts = {poStdErrToStdOut, poUsePath, poEvalCommand}
  if headless: opts = opts + {poDaemon}
  try:
    let
      p = startProcess(cmd, options = opts)
      res = readLines p
    echo res[0].join "\t"
    result = res[1]
    close p
  except OSError:
    echo getCurrentExceptionMsg()

proc checkFile(
  condition: FileCond;
  paths: seq[string];
  invert = false;
  min = 0;
  str = "";
  caseInsensitive = false;
  then = "";
  `else` = "";
  headless = false;
  moreThan = 0.0;
  lessThan = high float;
  stripNum = false
): int =
  ## Check if expression is meet in a file
  ## 
  ## If `then` or `else` was provided, the return code will be of the command
  proc check(
    path: string;
    str = "";
    moreThan, lessThan: float;
    stripNum: bool
  ): bool =
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
    of FileCond.dataNum:
      var val = path.tryReadFile
      if stripNum:
        val = val.strip(chars = AllChars - Digits)
      let num = val.tryParseFloat(0)
      num > moreThan and num < lessThan

  checkCondition(file = true)

proc `not`(x: int): int =
  if x == 0: 1 else: 0

proc checkDir(
  condition: DirCond;
  paths: seq[string];
  invert = false;
  min = 0;
  then = "";
  `else` = "";
  headless = false
): int =
  ## Check if expression is meet in a directory
  ## 
  ## If `then` or `else` was provided, the return code will be of the command
  proc check(path: string; str = ""): bool =
    case condition:
    of DirCond.exists:
      dirExists path

  checkCondition()

template checkCondition(file = false): untyped {.dirty.} =
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
    when file:
      let res = path.check(str, moreThan, lessThan, stripNum)
    else:
      let res = path.check str
    if res:
      inc meet

  block:
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
      result = execCmd(then, headless)
  else:
    if `else`.len > 0:
      result = execCmd(`else`, headless)

proc checkCommand(
  commands: seq[string];
  then = "";
  `else` = "";
  stopOnError = true;
  headless = false
): int =
  ## Run the `then` if `cmd` runs ok, else runs `else`
  result = 0

  if commands.len == 0:
    quit "Provide the commands", 64

  for command in commands:
    let res = execCmd(command, headless)
    if res != 0:
      result = res
      if stopOnError:
        break

  if result == 0:
    if then.len > 0:
      result = execCmd(then, headless)
  else:
    if `else`.len > 0:
      result = execCmd(`else`, headless)

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

  const
    help_condition1 = "The "
    help_condition2 = " check condition. Can be one of: "
    help_paths = "The files to check, can be any quantity"
    help_invert = "Invert result"
    help_min = "Minimum succeeded checks"
    help_str = "The text to be searched"
    help_then = "The command to be run on success"
    help_else = "The command to be run on error"
    help_caseInsensitive = "Ignore uppercase and lowercase"
    help_stopOnError = "If some error occur in `commands` it will stop"
    help_headless = "If some error occur in `commands` it will stop"
    help_lessThan = "Configure the `dataNum` minimum acceptable number (default: 0)"
    help_moreThan = "Configure the `dataNum` maximum acceptable number (default: maximum number)"
    help_stripNum = "Removes everything that isn't digits from file data"
    
  dispatchMulti(
    [
      checkFile,
      cmdName = "file",
      short = {
        "invert": 'n',
        "caseInsensitive": 'i',
        "headless": 'l',
      },
      
      help = {
        "condition": help_condition1 & "file" & help_condition2 & fileConds,
        "paths": help_paths,
        "invert": help_invert,
        "min": help_min,
        "str": help_str,
        "then": help_then,
        "else": help_else,
        "caseInsensitive": help_caseInsensitive,
        "headless": help_headless,
        "lessThan": help_lessThan,
        "moreThan": help_moreThan,
        "stripNum": help_stripNum,
      }
    ],
    [
      checkDir,
      cmdName = "dir",
      short = {
        "invert": 'n',
      },
      help = {
        "condition": help_condition1 & "dir" & help_condition2 & dirConds,
        "paths": help_paths,
        "invert": help_invert,
        "min": help_min,
        "then": help_then,
        "else": help_else,
        "headless": help_headless,
      }
    ],
    [
      checkCommand,
      cmdName = "command",
      short = {
      },
      help = {
        "then": help_then,
        "else": help_else,
        "stopOnError": help_stopOnError,
        "headless": help_headless,
      }
    ],
  )
