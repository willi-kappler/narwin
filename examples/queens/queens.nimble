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
    exec "./queens -m=10 -p=200 -i=10000 -k=0 &"
    exec "sleep 1"

    exec "./queens -m=20 -p=200 -i=1000 -k=3 &"
    exec "sleep 1"

    exec "./queens -m=10 -p=200 -i=10000 -k=4 --fitnessrate=0.001 --limittop=5.0 --limitbottom=0.1 &"
    exec "sleep 1"

    exec "./queens -m=10 -p=200 -i=10000 -k=5 &"

task cleanQueens, "Clean up after calculation":
    exec "rm -f queens"
    exec "rm -f *.log"
    exec "rm -f *.json"

