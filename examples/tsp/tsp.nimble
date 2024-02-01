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
    # Start the server:
    #exec "nim c tsp.nim"
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=10 -t=7900.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=20000 -k=1 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=20000 -k=1 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=20000 -k=1 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=20000 -k=1 --reset &"

task runTSPX, "Runs the TSP example":
    # Start the server:
    #exec "nim c tsp.nim"
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=100 -t=7900.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=10000 -k=2 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=20000 -k=2 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=30000 -k=2 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=40000 -k=2 &"

task cleanTSP, "Clean up after calculation":
    exec "rm -f tsp"
    exec "rm -f *.log"
    exec "rm -f *.json"

