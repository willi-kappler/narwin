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
    exec "./tsp --server -p=200 -t=8000.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=10000 -k=2 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 -m=20 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=2 --reset &"


# Try out each population type individually:
# (the target is set to 0.0 to let it run forever)

task runTSPAll, "Runs the TSP example":
    # Start the server:
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=200 -t=0.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=100000 -k=1 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=1 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.01 --amplitude=1000.0 --base=8500.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.001 --amplitude=1000.0 --base=8500.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=4 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=5 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=5 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=6 --limitfactor=1.01 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=6 --limitfactor=1.001 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=7 --maxreset=10000 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=200000 -k=7 --maxreset=20000 &"

task runTSP1, "Runs the TSP example":
    # Start the server:
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=200 -t=0.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=100000 -k=1 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=1 -m=20 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=1 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=1000000 -k=1 --reset &"

task runTSP3, "Runs the TSP example":
    # Start the server:
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=200 -t=0.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.001 --amplitude=1000.0 --base=8000.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.001 --amplitude=3000.0 --base=10000.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.002 --amplitude=1000.0 --base=8000.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.002 --amplitude=3000.0 --base=10000.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.004 --amplitude=1000.0 --base=8000.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.004 --amplitude=3000.0 --base=10000.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.008 --amplitude=1000.0 --base=8000.0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=3 --dt=0.008 --amplitude=3000.0 --base=10000.0 &"

task runTSP4, "Runs the TSP example":
    # Start the server:
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=200 -t=0.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=100000 -k=4 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=4 --reset &"

task runTSP5, "Runs the TSP example":
    # Start the server:
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=200 -t=0.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=10000 -k=5 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=5 -m=20 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=5 --reset &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=100000 -k=5 --reset &"

task runTSP6, "Runs the TSP example":
    # Start the server:
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=200 -t=0.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=10000 -k=6 --limitfactor=1.01 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=6 --limitfactor=1.01 -m=20 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=6 --limitfactor=1.005 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=6 --limitfactor=1.001 &"

task runTSP7, "Runs the TSP example":
    # Start the server:
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=200 -t=0.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=100000 -k=7 --maxreset=10000 -m=10 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=200000 -k=7 --maxreset=20000 -m=10 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=300000 -k=7 --maxreset=30000 -m=10 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=400000 -k=7 --maxreset=40000 -m=10 &"

task runTSPOp, "Runs the TSP example":
    # Start the server:
    exec "nim c -d:release tsp.nim"
    exec "./tsp --server -p=200 -t=0.0 &"
    exec "sleep 5"

    # Start some nodes:
    exec "./tsp -p=200 -i=10000 -k=2 --operations=0 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 --operations=1 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 --operations=2 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 --operations=3 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 --operations=4 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=10000 -k=2 --operations=5 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=1000 -k=2 --operations=6 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=1000 -k=2 --operations=7 &"
    exec "sleep 1"

    exec "./tsp -p=200 -i=1000 -k=2 --operations=8 &"
    exec "sleep 1"

task cleanTSP, "Clean up after calculation":
    exec "rm -f tsp"
    exec "rm -f *.log"
    exec "rm -f *.json"

