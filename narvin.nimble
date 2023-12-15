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
    exec "testament --print --verbose c /"

task checkAll, "run 'nim check' on all source files":
    cd "src/"
    exec "nim check narvin.nim"

    cd "narvin/"
    exec "nim check na_config.nim"
    exec "nim check na_individual.nim"
    exec "nim check na_population.nim"
    exec "nim check na_population_node.nim"
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

task genDoc, "Generate documentation":
    exec "nim doc --project src/narvin.nim"

