from std/os import fileExists, dirExists
from std/strutils import `%`

type
  CheckKind* {.pure.} = enum
    file, dir
  CheckCondition* {.pure.} = enum
    exists


proc cli_checkif(
  kind: CheckKind;
  condition: CheckCondition;
  paths: seq[string];
  invert = false;
  min = 0;
  print = false
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
      of exists: " exists")
    result.add ": $2"

  result = 1
  if paths.len == 0:
    echo "Provide paths"
    return
  
  if print:
    echo "Configs:"
    if min > 0: echo "  Minimum succeeds: ", min
    else: echo "  All must be true"
    if invert: echo "  The result will be inverted"
    echo ""

  var printText = getPrintText()
  proc check(path: string): bool =
    case condition:
    of exists:
      case kind:
      of file: fileExists path
      of dir: dirExists path

  var meet = 0
  for path in paths:
    let res = check path
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
