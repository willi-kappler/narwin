# Package
version       = "0.1.0"
author        = "Willi Kappler"
description   = "Distributed Sudoku with nim"
license       = "MIT"
srcDir        = "src"
bin           = @["sudoku"]

# Dependencies
requires "nim >= 2.0.0"

# Tasks
task checkAll, "run 'nim check' on all source files":
    exec "nim check sudoku_individual.nim"
    exec "nim check sudoku.nim"

task runSudoku, "Runs the Sudoku example":
    #exec "nim c sudoku.nim"
    exec "nim c -d:release sudoku.nim"
    #exec "./sudoku --server --samefitness &"
    exec "./sudoku --server &"
    exec "sleep 5"

    # Start four nodes
    exec "./sudoku -m=1 -p=200 -i=10000 -k=0 &"
    exec "sleep 1"

    exec "./sudoku -m=2 -p=200 -i=10000 -k=0 &"
    exec "sleep 1"

    exec "./sudoku -m=4 -p=200 -i=10000 -k=0 &"
    exec "sleep 1"

    exec "./sudoku -m=1 -p=200 -i=100000 -k=0 --reset &"
    exec "sleep 1"

    exec "./sudoku -m=2 -p=200 -i=100000 -k=0 --reset &"
    exec "sleep 1"

    exec "./sudoku -m=4 -p=200 -i=100000 -k=0 --reset &"

task cleanSudoku, "Clean up after calculation":
    exec "rm -f sudoku"
    exec "rm -f *.log"
    exec "rm -f *.json"

