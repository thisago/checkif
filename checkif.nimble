# Package

version       = "0.3.0"
author        = "Thiago Navarro"
description   = "A CLI tool to check files (and registry in Windows)"
license       = "MIT"
srcDir        = "src"
bin           = @["checkif"]
binDir = "build"


# Dependencies

requires "nim >= 1.6.4"
requires "cligen"
