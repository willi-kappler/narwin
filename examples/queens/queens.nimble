# Package
version       = "0.1.0"
author        = "Willi Kappler"
description   = "Distributed Queens with nim"
license       = "MIT"
srcDir        = "src"
bin           = @["queens"]

# Dependencies
requires "nim >= 2.0.0"

# Tasks
task checkAll, "run 'nim check' on all source files":
    exec "nim check queens_individual.nim"
    exec "nim check queens.nim"

task runQueens, "Runs the Queens example":
    #exec "nim c queens.nim"
    exec "nim c -d:release queens.nim"
    exec "./queens --server &"
    exec "sleep 5"

    # Start four nodes
    exec "./queens -m=2 -p=200 -i=100000 &"
    exec "sleep 1"

    exec "./queens -m=2 -p=200 -i=100000 --reset &"
    exec "sleep 1"

    exec "./queens -m=10 -p=20 -i=100000 &"
    exec "sleep 1"

    exec "./queens -m=20 -p=20 -i=100000 &"


task cleanTSP, "Clean up after calculation":
    exec "rm -f queens"
    exec "rm -f *.log"
    exec "rm -f *.json"

