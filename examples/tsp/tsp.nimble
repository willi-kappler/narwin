# Package
version       = "0.1.0"
author        = "Willi Kappler"
description   = "Distributed TSP with nim"
license       = "MIT"
srcDir        = "src"
bin           = @["tsp"]

# Dependencies
requires "nim >= 2.0.0"

# Tasks
task checkAll, "run 'nim check' on all source files":
    exec "nim check tsp_individual.nim"
    exec "nim check tsp.nim"

task runTSP, "Runs the TSP example":
    #exec "nim c tsp.nim"
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server &"
    exec "sleep 5"

    # Start three nodes
    exec "./tsp -p=200 -i=100000 -k=1 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=2 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=3 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=4 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=5 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=6 &"

task cleanTSP, "Clean up after calculation":
    exec "rm -f tsp"
    exec "rm -f *.log"
    exec "rm -f *.json"

