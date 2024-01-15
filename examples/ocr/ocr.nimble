# Package
version       = "0.1.0"
author        = "Willi Kappler"
description   = "Distributed Queens with nim"
license       = "MIT"
srcDir        = "src"
bin           = @["ocr"]

# Dependencies
requires "nim >= 2.0.0"

# Tasks
task checkAll, "run 'nim check' on all source files":
    exec "nim check ocr_individual.nim"
    exec "nim check ocr.nim"

task runOCR, "Runs the OCR example":
    #exec "nim c ocr.nim"
    exec "nim c -d:release ocr.nim"
    exec "./ocr --server &"
    exec "sleep 5"

    # Start one nodes
    exec "./ocr -p=200 -i=10000 -k=1 &"

task cleanOCR, "Clean up after calculation":
    exec "rm -f ocr"
    exec "rm -f *.log"
    exec "rm -f *.json"

