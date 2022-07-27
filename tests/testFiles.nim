from std/os import removeFile
import std/unittest
import checkif

const
  testFile = "testFile.txt"
  testFileText = "Hello world!"

suite "Test file checking":
  setup:
    testFile.writeFile testFileText
  teardown:
    removeFile testFile

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
