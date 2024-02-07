# This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the NAIndividual code from narwin for the TSP example.
##
## This Nim library allows you to write programs using evolutionary algorithms.
##


# Nim std imports
import std/json
import std/jsonutils

from std/random import rand, sample
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import ../../src/narwin

type
    QueensIndividual* = ref object of NAIndividual
        data: seq[(uint8, uint8)] # (row, column)

proc randPos(maxPos: int): uint8 =
    uint8(rand(maxPos) + 1)

proc hasCollision(r1: uint8, c1: uint8, r2: uint8, c2: uint8): bool =
    if r1 == r2:
        return true
    if c1 == c2:
        return true

    let dr = abs(int8(r1) - int8(r2))
    let dc = abs(int8(c1) - int8(c2))

    return dr == dc

proc hasCollision(self: QueensIndividual, index1: uint8, index2: uint8): bool =
    let r1 = self.data[index1][0]
    let c1 = self.data[index1][1]
    let r2 = self.data[index2][0]
    let c2 = self.data[index2][1]

    return hasCollision(r1, c1, r2, c2)

method naMutate*(self: var QueensIndividual) =
    let last = self.data.high

    # Select one of the queens randomly:
    let i = rand(last)

    # Choose mutation operation:
    let operation = uint32(rand(1))

    case operation
    of 0:
        # Just set a random position:
        self.data[i][0] = randPos(last)
        self.data[i][1] = randPos(last)
    of 1:
        # Choose another queen randomly:
        var j = rand(last)

        while i == j:
            # Ensure that both indices are different
            j = rand(last)

        # randomly choose a new position for the first queen:
        var r1 = randPos(last)
        var c1 = randPos(last)

        # Get position of second queen:
        let r2 = self.data[j][0]
        let c2 = self.data[j][1]

        # Ensure that there is no collision:
        while hasCollision(r1, c1, r2, c2):
            r1 = randPos(last)
            c1 = randPos(last)

        # Set the new row and column
        self.data[i][0] = r1
        self.data[i][1] = c1
    else:
        raise newException(ValueError, fmt("Unknown mutation operation: {operation}"))


method naRandomize*(self: var QueensIndividual) =
    let last = self.data.high

    for i in 0..last:
        self.data[i][0] = randPos(last)
        self.data[i][1] = randPos(last)

method naCalculateFitness*(self: var QueensIndividual) =
    # Fitness means here: number of queen-collisions:
    # The fewer collisions the better the fitness.

    let last = self.data.high
    var numOfCollisions = 0

    for i in 0..last:
        for j in (i + 1)..last:
            if self.hasCollision(uint8(i), uint8(j)):
                numOfCollisions += 1

    self.fitness = float64(numOfCollisions)

method naClone*(self: QueensIndividual): NAIndividual =
    result = QueensIndividual(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: QueensIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var QueensIndividual, data: seq[byte]) =
    self = ncFromBytes(data, QueensIndividual)

method naToJSON*(self: QueensIndividual): JsonNode =
    self.toJson()

method naFromJSON*(self: QueensIndividual, data: JsonNode): NAIndividual =
    return data.jsonTo(QueensIndividual)

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

