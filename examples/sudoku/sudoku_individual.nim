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
    uint8(rand(8) + 1)

proc randIndex(): uint8 =
    uint8(rand(8))

proc getVal1(self: SudokuIndividual, i: uint8, j: uint8): uint8 =
    self.data1[(j * 9) + i]

proc getVal2(self: SudokuIndividual, i: uint8, j: uint8): uint8 =
    self.data2[(j * 9) + i]

proc setVal2(self: var SudokuIndividual, i: uint8, j: uint8, val: uint8) =
    self.data2[(j * 9) + i] = val

proc checkLineN(self: SudokuIndividual, iStart: uint8, jStart: uint8, iInc: int8, jInc: int8, val: uint8): uint8 =
    var counter = 0'u8
    var i = int8(iStart)
    var j = int8(jStart)

    for _ in 0..8:
        if self.getVal2(uint8(i), uint8(j)) == val:
            inc(counter)
        i += iInc
        j += jInc

    if val == 0:
        return counter
    elif counter > 1:
        return counter - 1
    else:
        return 0

proc checkBlock(self: SudokuIndividual, i: uint8, j: uint8): uint8 =
    result = 0'u8
    var counter = 0'u8

    for n in 0'u8..9'u8:
        counter = 0
        for u in 0'u8..2'u8:
            for v in 0'u8..2'u8:
                if self.getVal2(i + u, j + v) == n:
                    inc(counter)
        if n == 0:
            result += counter
        else:
            if counter > 1:
                result += counter - 1

method naMutate*(self: var SudokuIndividual) =
    # Pick a random position:
    var i = randIndex()
    var j = randIndex()

    # Ensure that the value is allowed to change:
    while self.getVal1(i, j) != 0:
        i = randIndex()
        j = randIndex()

    # Select a random operation:
    let operation = rand(1)

    case operation
    of 0:
        # Set it to a random value:
        self.setVal2(i, j, randValue())
    of 1:
        var i1 = 0'u8
        var i2 = 0'u8
        var j1 = 0'u8
        var j2 = 0'u8

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
        let v1 = self.getVal2(i, j1)
        let v2 = self.getVal2(i, j2)
        let v3 = self.getVal2(i1, j)
        let v4 = self.getVal2(i2, j)

        while true:
            if (v1 != v) and (v2 != v) and (v3 != v) and (v4 != v):
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
    # Fitness means number of errors, the lower the better
    var errors: uint16 = 0

    # Check rows and columns:
    for i in 0'u8..8'u8:
        for n in 0'u8..9'u8:
            errors += self.checkLineN(0, i, 1, 0, n)
            errors += self.checkLineN(i, 0, 0, 1, n)

    # Check diagonals:
    #for n in 0'u8..9'u8:
        #errors += self.checkLineN(0, 0, 1, 1, n)
        #errors += self.checkLineN(8, 0, -1, 1, n)

    # Check each block:
    for i in countup(0'u8, 6'u8, 3'u8):
        for j in countup(0'u8, 6'u8, 3'u8):
            errors += self.checkBlock(i, j)

    self.fitness = float64(errors)

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
    let data: seq[uint8] = @[
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

