from std/os import removeFile, removeDir, createDir, `/`
import std/unittest
import checkif

const
  testDir = "testDir"
  testFile = testDir / "testFile.txt"
  testFileText = "Hello world!"

suite "Test exists condition":
  setup:
    createDir testDir
    testFile.writeFile testFileText
  teardown:
    removeFile testFile
    removeDir testDir

  test "File exists":
    check checkif(
      kind = file,
      condition = exists,
      paths = @[testFile],
    )
  test "File not exists":
    removeFile testFile
    check checkif(
      kind = file,
      condition = exists,
      paths = @[testFile],
      invert = true
    )
  test "At least 1 file exists":
    check checkif(
      kind = file,
      condition = exists,
      paths = @[testFile, "invalidFile"],
      min = 1
    )


  test "Dir exists":
    check checkif(
      kind = dir,
      condition = exists,
      paths = @[testDir],
    )
  test "Dir not exists":
    removeDir testDir
    check checkif(
      kind = dir,
      condition = exists,
      paths = @[testDir],
      invert = true
    )
  test "At least 1 dir exists":
    check checkif(
      kind = dir,
      condition = exists,
      paths = @[testDir, "invalidDir"],
      min = 1
    )
