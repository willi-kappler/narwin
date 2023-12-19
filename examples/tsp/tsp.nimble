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
    exec "./tsp --server -t=330.0 &"
    exec "sleep 5"

    # Start 4 nodes
    exec "./tsp -m=2 -p=200 -i=10000 -t=330.00 -k=0 &"
    exec "sleep 1"

    exec "./tsp -m=2 -p=200 -i=1000000 -t=330.00 -k=1 &"
    exec "sleep 1"

    exec "./tsp -m=2 -p=200 -i=1000000 -t=330.00 -k=2 &"
    exec "sleep 1"

    exec "./tsp -m=20 -p=200 -i=100000 -t=330.00 -k=3 &"

task cleanTSP, "Clean up after calculation":
    exec "rm -f tsp"
    exec "rm -f *.log"
    exec "rm -f *.json"

