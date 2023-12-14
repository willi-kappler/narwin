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
    var i = 0
    var j = 0
    let last = self.data.high

    # find a position with a queen:
    while true:
        i = rand(last)
        if self.data[i] == 1:
            break

    # Find a position without queen:
    while true:
        j = rand(last)
        if self.data[j] == 0:
            break

    # Move the queen to a new empty position
    swap(self.data[i], self.data[j])

method naRandomize*(self: var QueensIndividual) =
    shuffle(self.data)

method naCalculateFitness*(self: var QueensIndividual) =
    # Fitness means here: number of queen-collisions
    var collisions = 0
    var queens1 = 0
    var queens2 = 0

    for i in 0..<8:
        queens1 = 0
        queens2 = 0
        for j in 0..<8:
            # Check rows:
            if self.data[(i * 8) + j] == 1:
                inc(queens1)
            # Check columns:
            if self.data[(j * 8) + i] == 1:
                inc(queens2)

        collisions += (queens1 - 1)
        collisions += (queens2 - 1)




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
            1,1,1,1,1,1,1,1,
            0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0
        ])

