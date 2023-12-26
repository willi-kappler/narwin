# This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the NAIndividual code from narwin for the TSP example.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##


# Nim std imports
import std/json
import std/jsonutils

from std/random import rand, shuffle
#from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import ../../src/narwin

type
    sudokuIndividual* = ref object of NAIndividual
        data: seq[uint8]

method naMutate*(self: var sudokuIndividual) =
    discard

method naRandomize*(self: var sudokuIndividual) =
    shuffle(self.data)

method naCalculateFitness*(self: var sudokuIndividual) =
    discard

method naClone*(self: sudokuIndividual): NAIndividual =
    result = sudokuIndividual(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: sudokuIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var sudokuIndividual, data: seq[byte]) =
    self = ncFromBytes(data, sudokuIndividual)

method naToJSON*(self: sudokuIndividual): JsonNode =
    self.toJson()

proc newPuzzle*(): sudokuIndividual =
    result = sudokuIndividual(data: @[
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,

        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,

        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0
        ])

