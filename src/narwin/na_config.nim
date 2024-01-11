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
from std/strutils import parseUint, parseFloat
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
        numOfMutations*: uint32
        numOfIterations*: uint32
        acceptNewBest*: bool
        resetPopulation*: bool
        populationKind*: uint8
        fixedMutation*: bool
        fitnessRate*: float64
        limitTop*: float64
        limitBottom*: float64
        operations*: seq[uint32]

proc naShowHelpAndQuit*() =
    let path = getAppFilename()
    let name = splitPath(path)[1]

    echo("Use --server to start in 'server mode' otherwise start in 'node mode':")
    echo(fmt("{name}: this starts in 'node mode' and tries to connect to the server"))
    echo(fmt("{name} --server: this starts in 'server mode' and waits for nodes to connect"))
    echo("-t [float64]: target fitness (0.0)")
    echo("--file: output filename for the result (optimal solution)")
    echo("--samefitness: allow individuals with the same fitness in the global population (false)")
    echo("--sharebest: only share the best individual with the other nodes instead of randomly pick one (true)")
    # TODO: option for save new fitness

    echo("-p [uint32]: population size (10)")
    echo("-m [uint32]: number of mutations per iteration (10)")
    echo("-i [uint32]: number of iterations (1000)")
    echo("-k [uint8]: population kind (0)")
    echo("--reset: before each run randomize the whole population (false)")
    echo("--fixedmutation: use a fixed number of mutations for each iteration (false)")
    echo("--fitnessrate [float64]: the rate at which the fitness limit is decreased (0.999)")
    echo("--limittop [float64]: the top limit for oscilating limit (10.0)")
    echo("--limitbottom [float64]: the top limit for oscilating limit (1.0)")

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
    result.numOfMutations = 10
    result.numOfIterations = 1000
    result.acceptNewBest = true
    result.resetPopulation = false
    result.populationKind = 0
    result.fixedMutation = false
    result.fitnessRate = 0.1
    result.limitTop = 10.0
    result.limitBottom = 1.0
    result.operations = @[]

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
            elif cmdParser.key == "m":
                result.numOfMutations = uint32(parseUint(cmdParser.val))
            elif cmdParser.key == "i":
                result.numOfIterations = uint32(parseUint(cmdParser.val))
            elif cmdParser.key == "reset":
                result.resetPopulation = true
            elif cmdParser.key == "samefitness":
                result.sameFitness = true
            elif cmdParser.key == "sharebest":
                result.shareOnyBest = true
            elif cmdParser.key == "fixedmutation":
                result.fixedMutation = true
            elif cmdParser.key == "fitnessrate":
                result.fitnessRate = parseFloat(cmdParser.val)
            elif cmdParser.key == "limittop":
                result.limitTop = parseFloat(cmdParser.val)
            elif cmdParser.key == "limitbottom":
                result.limitBottom = parseFloat(cmdParser.val)
            elif cmdParser.key == "k":
                result.populationKind = uint8(parseUint(cmdParser.val))
            else:
                naShowHelpAndQuit()
        of cmdArgument:
            naShowHelpAndQuit()

