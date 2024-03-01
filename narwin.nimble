# Package
version       = "0.1.0"
author        = "Willi Kappler"
description   = "Evolutionary algorithms with Nim"
license       = "MIT"
srcDir        = "src"

# Dependencies
requires "nim >= 2.0.0"
requires "num_crunch >= 0.1.0"
#requires ""

# Tasks
task testAll, "Run all test cases in tests/":
    #exec "testament --print --verbose c /"
    exec "testament c /"
    # to run only one test file: testament p "tests/test_na_population.nim"

task checkAll, "run 'nim check' on all source files":
    cd "src/"
    exec "nim check narwin.nim"

    cd "narwin/"
    exec "nim check na_config.nim"
    exec "nim check na_individual.nim"
    exec "nim check na_population.nim"
    exec "nim check na_population_node1.nim"
    exec "nim check na_population_node2.nim"
    exec "nim check na_population_node3.nim"
    exec "nim check na_population_node4.nim"
    exec "nim check na_population_node5.nim"
    exec "nim check na_population_node6.nim"
    exec "nim check na_population_node7.nim"
    exec "nim check na_population_server.nim"

    #cd "private/"
    # Check private modules:
    #exec "nim check xxx.nim"

task cleanTests, "Clean log files and binaries in tests/ folder":
    cd "tests/"
    # Delete all log files
    exec "rm -f *.log"
    # Delete all executable files
    exec "find . -type f -perm /u=x -delete"

task runTSP, "Runs the TSP example":
    cd "examples/tsp/"
    exec "nimble runTSP"

task runQueens, "Runs the Queens example":
    cd "examples/queens/"
    exec "nimble runQueens"

task runSudoku, "Runs the Sudoku example":
    cd "examples/sudoku/"
    exec "nimble runSudoku"

task genDoc, "Generate documentation":
    exec "nim doc --project src/narwin.nim"

