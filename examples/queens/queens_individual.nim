# This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the NAIndividual code from narvin for the TSP example.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##


# Nim std imports
import std/json
import std/jsonutils

from std/math import hypot
from std/random import rand, shuffle
from std/strutils import split, parseFloat
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import ../../src/narvin

type
    QueensIndividual* = ref object of NAIndividual
        data: seq[uint8]

method naMutate*(self: var QueensIndividual) =
    # TODO: implement
    discard

method naRandomize*(self: var QueensIndividual) =
    # TODO: implement
    discard

method naCalculateFitness*(self: var QueensIndividual) =
    # TODO: implement
    discard

method naClone*(self: QueensIndividual): NAIndividual =
    result = QueensIndividual(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: QueensIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: QueensIndividual, data: seq[byte]): NAIndividual =
    ncFromBytes(data, QueensIndividual)

method naToJSON*(self: QueensIndividual): JsonNode =
    self.toJson()

proc newBoard*(): QueensIndividual =
    # TODO:implement
    result = QueensIndividual(data: @[])

