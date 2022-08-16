# Package

version       = "1.1.0"
author        = "Thiago Navarro"
description   = "A CLI tool to check files (and registry in Windows)"
license       = "MIT"
srcDir        = "src"
bin           = @["checkif"]
binDir = "build"


# Dependencies

requires "nim >= 1.6.4"
requires "cligen"


from std/os import `/`

let file = srcDir / bin[0]

proc defaultSwitch =
  --opt:speed
  --define:release
  --outDir:build

proc posProcess(win = false) =
  echo "strip build/" & bin[0] & (if win: ".exe" else: "") 
  exec "strip build/" & bin[0] & (if win: ".exe" else: "")

task buildRelease, "Builds the release version":
  defaultSwitch()
  setCommand "c", file

task buildWinRelease, "Builds the release version for windows":
  defaultSwitch()
  --define:mingw
  setCommand "c", file


task strip, "Strip executable":
  posProcess()
task stripWin, "Strip windows executable":
  posProcess(true)
