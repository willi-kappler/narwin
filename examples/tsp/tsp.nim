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
from system import quit
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

    quit()

when isMainModule:
    var runServer = false
    let config = ncLoadConfig("config.ini")

    var cmdParser = initOptParser()
    while true:
        cmdParser.next()
        case cmdParser.kind:
        of cmdEnd:
            break
        of cmdShortOption, cmdLongOption:
            if cmdParser.key == "server":
                runServer = true
            else:
                showHelpAndQuit()
        of cmdArgument:
            showHelpAndQuit()

    let tsp = loadTSP("city_positions1.txt")

    if runServer:
        let logger = newFileLogger("tsp_server.log", fmtStr=verboseFmtStr)
        ncInitLogger(logger, 2)

        ncInfo("Starting server")
        let dataProcessor = naInitPopulationServerDP(tsp, "best_result.json")
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
        let dataProcessor = naInitPopulationNodeDP(tsp, numOfIterations = 1000000, populationSize = 20)
        ncInitNode(dataProcessor, config)
        ncRunNode()

