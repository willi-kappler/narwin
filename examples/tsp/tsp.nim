# This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This file contains the TSP (traveling salesman problem) example for narvin.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##


# Nim std imports
import std/parseopt
import std/logging

from std/strformat import fmt
from std/strutils import parseUint, parseFloat
#from system import quit
from os import getAppFilename, splitPath, fileExists

# Local imports
import ../../src/narvin

import tsp_individual

proc showHelpAndQuit() =
    let path = getAppFilename()
    let name = splitPath(path)[1]

    echo("Use --server to start in 'server mode' otherwise start in 'node mode':")
    echo(fmt("{name} # <- this starts in 'node mode' and tries to connect to the server"))
    echo(fmt("{name} --server # <- this starts in 'server mode' and waits for nodes to connect"))

    echo("-m [uint32] number of mutations per iteration")
    echo("-p [uint32] population size")
    echo("-i [uint32] number of iterations")
    echo("-t [float64] target fitness")
    echo("--reset before each run randomize the whole population")

    quit()

when isMainModule:
    var runServer = false
    let config = ncLoadConfig("config.ini")

    var populationSize: uint32 = 100
    var numOfMutations: uint32 = 10
    var numOfIterations: uint32 = 10000
    var resetPopulation = false
    var targetFitness = 360.0

    var cmdParser = initOptParser()
    while true:
        cmdParser.next()
        case cmdParser.kind:
        of cmdEnd:
            break
        of cmdShortOption, cmdLongOption:
            if cmdParser.key == "server":
                runServer = true
            elif cmdParser.key == "m":
                numOfMutations = uint32(parseUint(cmdParser.val))
            elif cmdParser.key == "p":
                populationSize = uint32(parseUint(cmdParser.val))
            elif cmdParser.key == "i":
                numOfIterations = uint32(parseUint(cmdParser.val))
            elif cmdParser.key == "t":
                targetFitness = parseFloat(cmdParser.val)
            elif cmdParser.key == "reset":
                resetPopulation = true
            else:
                showHelpAndQuit()
        of cmdArgument:
            showHelpAndQuit()

    # Best fitness with this data: 325.1787170723113
    # Possible good limit: 360.0
    let tsp = loadTSP("city_positions1.txt")

    if runServer:
        let logger = newFileLogger("tsp_server.log", fmtStr=verboseFmtStr)
        ncInitLogger(logger, 2)

        ncInfo("Starting server")
        let dataProcessor = naInitPopulationServerDP(
            tsp,
            "best_result.json",
            targetFitness
        )
        ncInitServer(dataProcessor, config)
        ncRunServer()
    else:
        var nameCounter = 1
        var logFilename = ""

        while true:
            logFilename = fmt("tsp_node{nameCounter}.log")

            if fileExists(logFilename):
                nameCounter += 1
                continue
            else:
                break

        let logger = newFileLogger(logFilename, fmtStr=verboseFmtStr)
        ncInitLogger(logger, 2)

        ncInfo("Starting Node")
        let dataProcessor = naInitPopulationNodeDP(
            tsp,
            populationSize,
            numOfMutations,
            numOfIterations,
            true,
            resetPopulation
        )
        ncInitNode(dataProcessor, config)
        ncRunNode()

