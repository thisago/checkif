from std/os import fileExists, dirExists
from std/strutils import `%`, contains

type
  CheckKind* {.pure.} = enum
    file, dir
  CheckCondition* {.pure.} = enum
    exists, contentHave, contentIs

proc tryReadFile(file: string): string =
  try:
    readFile file
  except IOError:
    ""


proc cli_checkif(
  kind: CheckKind;
  condition: CheckCondition;
  paths: seq[string];
  invert = false;
  min = 0;
  print = false;
  str = ""
): int =
  ## Check if expression is meet
  proc getPrintText: string =
    result =
      case kind:
      of file: "File \"$1\""
      of dir: "Directory \"$1\""

    if invert: result.add " not"
    result.add(
      case condition:
      of exists: " exists"
      of contentHave: " content have"
      of contentIs: " content is")
    result.add ": $2"

  result = 1
  if paths.len == 0:
    echo "Provide paths"
    return

  if condition in {contentHave, contentIs}:
    if str.len == 0:
      quit "Provide the verification string"
  
  if print:
    echo "Configs:"
    if min > 0: echo "  Minimum succeeds: ", min
    else: echo "  All must be true"
    if invert: echo "  The result will be inverted"
    echo ""

  var printText = getPrintText()
  proc check(path: string; str = ""): bool =
    case condition:
    of exists:
      case kind:
      of file: fileExists path
      of dir: dirExists path
    of contentHave:
      case kind:
      of file: str in path.tryReadFile
      else: raise newException(ValueError, "Cannot check if dir content have a string")
    of contentIs:
      case kind:
      of file: str == path.tryReadFile
      else: raise newException(ValueError, "Cannot check if dir content is a string")
  var meet = 0
  for path in paths:
    let res = path.check str
    if print:
      echo printText % [path, $res]
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
    if result == 0:
      result = 1
    else:
      result = 0

template checkif*(args: varargs[untyped]): untyped =
  cli_checkif(args) == 0

when isMainModule:
  import pkg/cligen
  dispatch(
    cli_checkif,
    cmdName = "checkif",
    short = {
      "invert": 'n'
    },
    help = {
      "min": "Minimum succeeded checks",
      "invert": "Invert result",
    }
  )
