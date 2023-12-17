# This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This file contains the Queens example for narvin.
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

import queens_individual

when isMainModule:
    var runServer = false
    let ncConfig = ncLoadConfig("config.ini")

    let naConfig = naConfigFromCmdLine()

    let queens = newBoard()

    if runServer:
        let logger = newFileLogger("queens_server.log", fmtStr=verboseFmtStr)
        ncInitLogger(logger, 2)

        ncInfo("Starting server")
        let dataProcessor = naInitPopulationServerDP(queens, naConfig)
        ncInitServer(dataProcessor, ncConfig)
        ncRunServer()
    else:
        var nameCounter = 1
        var logFilename = ""

        while true:
            logFilename = fmt("queens_node{nameCounter}.log")

            if fileExists(logFilename):
                nameCounter += 1
                continue
            else:
                break

        let logger = newFileLogger(logFilename, fmtStr=verboseFmtStr)
        ncInitLogger(logger, 2)

        let dataProcessor = naGetPopulationNodeDP(queens, naConfig)
        ncInitNode(dataProcessor, ncConfig)
        ncRunNode()

