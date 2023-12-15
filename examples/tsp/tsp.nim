## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutinary algorithms.
##
## This file contains the TSP (traveling salesman problem) example for narvin.
##


# Nim std imports
import std/logging

from std/strformat import fmt
from os import fileExists

# Local imports
import ../../src/narvin

import tsp_individual

when isMainModule:
    let ncConfig = ncLoadConfig("config.ini")

    let naConfig = naConfigFromCmdLine()

    # Best fitness with city_positions1: 325.1787170723113
    # Possible good limit: 330.0
    #
    # Best fitness with city_positions2: 8243.128981516997
    # Possible good limit: 8300.0
    let tsp = loadTSP("city_positions2.txt")

    if naConfig.serverMode:
        let logger = newFileLogger("tsp_server.log", fmtStr=verboseFmtStr)
        ncInitLogger(logger, 2)

        ncInfo("Starting server")
        let dataProcessor = naInitPopulationServerDP(
            tsp, naConfig
        )
        ncInitServer(dataProcessor, ncConfig)
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
            tsp, naConfig
        )
        ncInitNode(dataProcessor, ncConfig)
        ncRunNode()

