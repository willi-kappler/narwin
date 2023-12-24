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

from std/math import hypot
from std/random import rand, shuffle
from std/strutils import split, parseFloat
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import ../../src/narwin

type
    QueensIndividual* = ref object of NAIndividual
        data: seq[(uint8, uint8)] # (row, column)

proc randPos(): uint8 =
    uint8(rand(7) + 1)

method naMutate*(self: var QueensIndividual) =
    let last = self.data.high

    # Select one of the queens randomly:
    let i = rand(last)

    # Choose mutation operation:
    let operation = rand(1)

    case operation
    of 0:
        # Just set a random position:
        self.data[i][0] = randPos()
        self.data[i][1] = randPos()
    of 1:
        # Choose another queen randomly:
        var j = rand(last)

        while i == j:
            # Ensure that both indices are different
            j = rand(last)

        let q1row = self.data[i][0]
        let q1col = self.data[i][1]

        var q2row = randPos()
        var q2col = randPos()

        while q1row == q2row:
            q2row = randPos()
        while q1col == q2col:
            q2col = randPos()

        self.data[j][0] = q2row
        self.data[j][1] = q2col
    else:
        raise newException(ValueError, fmt("Unknown mutation operation: {operation}"))


method naRandomize*(self: var QueensIndividual) =
    shuffle(self.data)

method naCalculateFitness*(self: var QueensIndividual) =
    # Fitness means here: number of queen-collisions:
    # The fewer collisions the better the fitness.

    var rowCollisions = 0
    var colCollisions = 0



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
    result = QueensIndividual(data: @[
        (1, 1),
        (1, 1),
        (1, 1),
        (1, 1),
        (1, 1),
        (1, 1),
        (1, 1),
        (1, 1)
        ])

