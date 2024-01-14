## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutinary algorithms.
##
## This file contains the configuration for the library
##

# Nim std imports
import std/parseopt

from std/strformat import fmt
from std/strutils import parseUint, parseFloat, parseBool
from os import getAppFilename, splitPath

type
    NAConfiguration* = object
        # Server:
        serverMode*: bool
        targetFitness*: float64
        resultFilename*: string
        saveNewFitness*: bool
        sameFitness*: bool
        shareOnyBest*: bool

        # Node:
        populationSize*: uint32
        numOfIterations*: uint32
        acceptNewBest*: bool
        resetPopulation*: bool
        populationKind*: uint8
        operations*: seq[uint32]

        # Population 3:
        dt*: float64
        amplitude*: float64
        base*: float64

        # Population 6:
        limitFactor*: float64

        # Population 7:
        maxReset*: uint32
        maxMutation*: uint32


        # Both:
        loadIndividual*: string

proc naShowHelpAndQuit*() =
    let path = getAppFilename()
    let name = splitPath(path)[1]

    # Server:
    echo("Use --server to start in 'server mode' otherwise start in 'node mode':")
    echo(fmt("{name}: this starts in 'node mode' and tries to connect to the server"))
    echo(fmt("{name} --server: this starts in 'server mode' and waits for nodes to connect"))
    echo("-t [float64]: target fitness (0.0)")
    echo("--file [string]: output filename for the result (optimal solution)")
    echo("--savenewfitness [bool]: If set everytime a new best fintess is found it will be saved (true)")
    echo("--samefitness: allow individuals with the same fitness in the global population (false)")
    echo("--sharebest [bool]: only share the best individual with the other nodes instead of randomly pick one (true)")
    # TODO: option for save new fitness

    # Node:
    echo("-p [uint32]: population size (10)")
    echo("-i [uint32]: number of iterations (1000)")
    echo("-k [uint8]: population kind (0)")
    echo("--reset: before each run randomize the whole population (false)")
    echo("--dt [float64]: Time step for population 3 (0.01)")
    echo("--amplitude [float64]: Amplitude for population 3 (1.0)")
    echo("--base [float64]: Base for population 3 (1.0)")
    echo("--limitfactor [float64]: Factor for limit change for population 6 (1.01)")
    echo("--maxreset [uint32]: maxiumum number of iteration with the same fitness befor randomizing the whole population. For population 7 (100)")
    echo("--maxmutation [uint32]: maxiumum number of mutations to try. For population 7 (100)")

    echo("--loadindividual [string]: loads the given individual into the population (node) or list of best (server)")

    quit()

proc naConfigFromCmdLine*(): NAConfiguration =
    # Default values:
    result.serverMode = false
    result.targetFitness = 0.0
    result.resultFilename = "best_result.json"
    result.saveNewFitness = true
    result.sameFitness = false
    result.shareOnyBest = true

    result.populationSize = 10
    result.numOfIterations = 1000
    result.acceptNewBest = true
    result.resetPopulation = false
    result.populationKind = 1
    result.operations = @[]

    result.dt = 0.001
    result.amplitude = 1.0
    result.base = 1.0
    result.limitFactor = 1.01
    result.maxReset = 100
    result.maxMutation = 10

    result.loadIndividual = ""

    var cmdParser = initOptParser()
    while true:
        cmdParser.next()
        case cmdParser.kind:
        of cmdEnd:
            break
        of cmdShortOption, cmdLongOption:
            if cmdParser.key == "server":
                result.serverMode = true
            elif cmdParser.key == "t":
                result.targetFitness = parseFloat(cmdParser.val)
            elif cmdParser.key == "file":
                result.resultFilename = cmdParser.val
            elif cmdParser.key == "p":
                result.populationSize = uint32(parseUint(cmdParser.val))
            elif cmdParser.key == "i":
                result.numOfIterations = uint32(parseUint(cmdParser.val))
            elif cmdParser.key == "k":
                result.populationKind = uint8(parseUint(cmdParser.val))
            elif cmdParser.key == "reset":
                result.resetPopulation = true
            elif cmdParser.key == "savenewfitness":
                result.saveNewFitness = parseBool(cmdParser.val)
            elif cmdParser.key == "samefitness":
                result.sameFitness = true
            elif cmdParser.key == "sharebest":
                result.shareOnyBest = parseBool(cmdParser.val)
            elif cmdParser.key == "loadindividual":
                result.loadIndividual = cmdParser.val
            elif cmdParser.key == "dt":
                result.dt = parseFloat(cmdParser.val)
            elif cmdParser.key == "amplitude":
                result.amplitude = parseFloat(cmdParser.val)
            elif cmdParser.key == "base":
                result.base = parseFloat(cmdParser.val)
            elif cmdParser.key == "limitfactor":
                result.limitFactor = parseFloat(cmdParser.val)
            elif cmdParser.key == "maxreset":
                result.maxReset = uint32(parseUint(cmdParser.val))
            elif cmdParser.key == "maxmutation":
                result.maxMutation = uint32(parseUint(cmdParser.val))
            else:
                naShowHelpAndQuit()
        of cmdArgument:
            naShowHelpAndQuit()

