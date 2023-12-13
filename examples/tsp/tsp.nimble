# Package
version       = "0.1.0"
author        = "Willi Kappler"
description   = "Distributed TSP with nim"
license       = "MIT"
srcDir        = "src"
bin           = @["tsp"]

# Dependencies
requires "nim >= 2.0.0"
#requires "num_crunch >= 0.1.0"
#requires "https://github.com/willi-kappler/num_crunch#head"

# Tasks
task checkAll, "run 'nim check' on all source files":
    exec "nim check tsp_individual.nim"
    exec "nim check tsp.nim"

task runTSP, "Runs the TSP example":
    #exec "nim c tsp.nim"
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -t=330.0 &"
    exec "sleep 5"

    # Start four nodes
    exec "./tsp -m=2 -p=200 -i=100000 &"
    exec "sleep 1"

    exec "./tsp -m=2 -p=200 -i=100000 --reset &"
    exec "sleep 1"

    exec "./tsp -m=10 -p=20 -i=100000 &"
    exec "sleep 1"

    exec "./tsp -m=20 -p=20 -i=100000 &"


task cleanTSP, "Clean up after calculation":
    exec "rm -f tsp"
    exec "rm -f *.log"
    exec "rm -f *.json"

