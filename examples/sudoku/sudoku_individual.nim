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

from std/random import rand, shuffle, sample
from std/strformat import fmt
#from std/sequtils import toSeq

# External imports
import num_crunch

# Local imports
import ../../src/narwin

type
    SudokuIndividual* = ref object of NAIndividual
        data1: seq[uint8]
        data2: seq[uint8]

proc getValue1(self: SudokuIndividual, col, row: uint8): uint8 =
    self.data1[(row * 9) + col]

proc getValue2(self: SudokuIndividual, col, row: uint8): uint8 =
    self.data2[(row * 9) + col]

proc setValue2(self: var SudokuIndividual, col, row, val: uint8) =
    self.data2[(row * 9) + col] = val

proc checkPos(self: SudokuIndividual, col, row: uint8, inUse: var set[uint8]): uint8 =
    let n = self.getValue2(col, row)
    if (n == 0) or (n in inUse):
        return 1
    else:
        inUse.incl(n)
        return 0

proc checkLine(self: SudokuIndividual, col, row, colInc, rowInc: uint8): uint8 =
    result = 0 # Number of errors
    var inUse: set[uint8]
    var c = col
    var r = row

    for _ in 0..8:
        result += self.checkPos(c, r, inUse)
        c = c + colInc
        r = r + rowInc

proc checkRow(self: SudokuIndividual, row: uint8): uint8 =
    self.checkLine(0, row, 1, 0)

proc checkCol(self: SudokuIndividual, col: uint8): uint8 =
    self.checkLine(col, 0, 0, 1)

proc checkBlock(self: SudokuIndividual, i, j: uint8): uint8 =
    result = 0 # Number of errors
    var inUse: set[uint8]

    for u in 0'u8..2:
        for v in 0'u8..2:
            result += self.checkPos(i + u, j + v, inUse)

proc calculateFitness2(self: SudokuIndividual): float64 =
    # Fitness means number of errors, the lower the better
    var errors: uint16 = 0

    # Check rows:
    for row in 0'u8..8:
        errors += self.checkRow(row)

    # Check column:
    for col in 0'u8..8:
        errors += self.checkCol(col)

    # Check each block:
    for i in countup(0'u8, 6'u8, 3'u8):
        for j in countup(0'u8, 6'u8, 3'u8):
            errors += self.checkBlock(i, j)

    return float64(errors)

proc randomValue(): uint8 =
    uint8(rand(8) + 1)

proc randomIndex(): uint8 =
    uint8(rand(8))

method naMutate*(self: var SudokuIndividual) =
    let col = randomIndex()
    let row = randomIndex()

    var colInUse: set[uint8]
    var rowInUse: set[uint8]
    var j: uint8
    var n: uint8

    for i in 0'u8..8:
        let nc = self.getValue1(col, i)
        let nr = self.getValue1(i, row)

        if nc > 0:
            colInUse.incl(nc)
        if nr > 0:
            rowInUse.incl(nr)

    var numbers: seq[uint8] = @[1, 2, 3, 4, 5, 6, 7, 8, 9]
    shuffle(numbers)

    if self.getValue1(col, row) == 0:
        # Set value in (col, row)
        for n in numbers:
            if n in colInUse:
                continue
            if n in rowInUse:
                continue
            self.setValue2(col, row, n)
            colInUse.incl(n)
            rowInUse.incl(n)
            break

    # Set values in col:
    shuffle(numbers)
    j = 0
    for i in 0'u8..8:
        if i != row:
            if self.getValue1(col, i) == 0:
                n = numbers[j]
                while n in colInUse:
                    inc(j)
                    n = numbers[j]
                self.setValue2(col, i, n)
                inc(j)

    # Set values in row:
    shuffle(numbers)
    j = 0
    for i in 0'u8..8:
        if i != col:
            if self.getValue1(i, row) == 0:
                n = numbers[j]
                while n in rowInUse:
                    inc(j)
                    n = numbers[j]
                self.setValue2(i, row, n)
                inc(j)

method naRandomize*(self: var SudokuIndividual) =
    # Initialize with random values:
    for i in 0..self.data1.high:
        if self.data1[i] == 0:
            self.data2[i] = randomValue()
        else:
            self.data2[i] = self.data1[i]

method naCalculateFitness*(self: var SudokuIndividual) =
    self.fitness = self.calculateFitness2()

method naClone*(self: SudokuIndividual): NAIndividual =
    result = SudokuIndividual(
        data1: self.data1,
        data2: self.data2,
    )
    result.fitness = self.fitness

method naToBytes*(self: SudokuIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var SudokuIndividual, data: seq[byte]) =
    self = ncFromBytes(data, SudokuIndividual)

method naToJSON*(self: SudokuIndividual): JsonNode =
    self.toJson()

method naFromJSON*(self: SudokuIndividual, data: JsonNode): NAIndividual =
    return data.jsonTo(SudokuIndividual)

proc newPuzzle*(): SudokuIndividual =
    let data: seq[uint8] = @[
        0, 3, 0,   0, 0, 0,   0, 0, 0,
        0, 0, 0,   1, 9, 5,   0, 0, 0,
        0, 0, 8,   0, 0, 0,   0, 6, 0,

        8, 0, 0,   0, 6, 0,   0, 0, 0,
        4, 0, 0,   8, 0, 0,   0, 0, 1,
        0, 0, 0,   0, 2, 0,   0, 0, 0,

        0, 6, 0,   0, 0, 0,   2, 8, 0,
        0, 0, 0,   4, 1, 9,   0, 0, 5,
        0, 0, 0,   0, 0, 0,   0, 7, 0
        ]

    result = SudokuIndividual(data1: data, data2: data)

