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
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import ../../src/narwin

type
    SudokuIndividual* = ref object of NAIndividual
        data1: seq[uint8]
        data2: seq[uint8]

proc randValue(): uint8 =
    random(8) + 1

proc getVal1(self: SudokuIndividual, i: uint8, j: uint8): uint8 =
    self.data1[(j * 9) + i]

proc getVal2(self: SudokuIndividual, i: uint8, j: uint8): uint8 =
    self.data2[(j * 9) + i]

proc setVal2(self: var SudokuIndividual, i: uint8, j: uint8, val: uint8) =
    self.data2[(j * 9) + i] = val

method naMutate*(self: var SudokuIndividual) =

    # Pick a random position:
    var i = rand(8)
    var j = rand(8)

    while self.getVal1(i, j) =! 0:
        i = rand(8)
        j = rand(8)

    # Select a random operation:
    let operation = rand(1)

    case operation
    of 0:
        # Set it to a random value:
        self.setVal2(i, j, randValue())
    of 1:
        var i1 = 0
        var i2 = 0
        var j1 = 0
        var j2 = 0

        if j == 0:
            j1 = 8
            j2 = 1
        elif j == 8:
            j1 = 7
            j2 = 0
        else:
            j1 = j - 1
            j2 = j + 1

        if i == 0:
            i1 = 8
            i2 = 1
        elif i == 8:
            i1 = 7
            i2 = 0
        else:
            i1 = i - 1
            i2 = i + 1


        var v = randValue()

        while true:
            if self.getVal2(i, j1) != v and
               self.getVal2(i, j2) != v and
               self.getVal2(i1, j) != v and
               self.getVal2(i2, j) != v:
                   break

            v = randValue()

        self.setVal2(i, j, v)

    else:
        raise newException(ValueError, fmt("Unknown mutation operation: {operation}"))


method naRandomize*(self: var SudokuIndividual) =
    let last = self.data1.high

    for i in 0..last:
        if self.data1[i] == 0:
            self.data2[i] = randValue()

method naCalculateFitness*(self: var SudokuIndividual) =
    discard

method naClone*(self: SudokuIndividual): NAIndividual =
    result = SudokuIndividual(data1: self.data1, data2: self.data2)
    result.fitness = self.fitness

method naToBytes*(self: SudokuIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var SudokuIndividual, data: seq[byte]) =
    self = ncFromBytes(data, SudokuIndividual)

method naToJSON*(self: SudokuIndividual): JsonNode =
    self.toJson()

proc newPuzzle*(): SudokuIndividual =
    let data = @[
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,

        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,

        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   0, 0, 0,   0, 0, 0
        ]

    result = SudokuIndividual(data1: data, data2: data)

