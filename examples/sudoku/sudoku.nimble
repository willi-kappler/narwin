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
    exec "./sudoku --server &"
    exec "sleep 5"

    # Start seven nodes
    exec "./sudoku -p=200 -i=100000 -k=1 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=1 --reset &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=2 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=3 --dt=0.01 --amplitude=2.0 --base=2.0 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=4 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=5 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=6 --limitfactor=1.01 &"

task runSudoku2, "Runs the Sudoku example":
    #exec "nim c sudoku.nim"
    exec "nim c -d:release sudoku.nim"
    exec "./sudoku --server &"
    exec "sleep 5"

    # Start eight nodes
    exec "./sudoku -p=200 -i=100000 -k=2 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=2 --reset &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=3 --dt=0.01 --amplitude=4.0 --base=4.0 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=3 --dt=0.001 --amplitude=4.0 --base=4.0 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=3 --dt=0.01 --amplitude=8.0 --base=8.0 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=3 --dt=0.001 --amplitude=8.0 --base=8.0 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=6 --limitfactor=1.01 &"
    exec "sleep 1"

    exec "./sudoku -p=200 -i=100000 -k=6 --limitfactor=1.001 &"

task cleanSudoku, "Clean up after calculation":
    exec "rm -f sudoku"
    exec "rm -f *.log"
    exec "rm -f *.json"

