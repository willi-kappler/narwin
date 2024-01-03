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

from std/random import rand, sample
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

proc randomValue(): uint8 =
    uint8(rand(8) + 1)

proc randomIndex(): uint8 =
    uint8(rand(8))

proc incIndex(n: uint8): uint8 =
    if n == 8:
        return 0
    else:
        return n + 1

proc decIndex(n: uint8): uint8 =
    if n == 0:
        return 8
    else:
        return n - 1

proc getFreeNumber(inUse: set[uint8]): uint8 =
    let numbers: set[uint8] = {1..9}
    let freeNumbers = numbers - inUse

    if freeNumbers.card() == 0:
        return randomValue()
    else:
        return sample(freeNumbers)

proc getValue1(self: SudokuIndividual, col: uint8, row: uint8): uint8 =
    self.data1[(row * 9) + col]

proc getValue2(self: SudokuIndividual, col: uint8, row: uint8): uint8 =
    self.data2[(row * 9) + col]

proc setValue2(self: var SudokuIndividual, col: uint8, row: uint8, val: uint8) =
    self.data2[(row * 9) + col] = val

proc checkPos(self: SudokuIndividual, col: uint8, row: uint8, inUse: var set[uint8]): uint8 =
    let n = self.getValue2(col, row)
    if (n == 0) or (n in inUse):
        return 1
    else:
        inUse.incl(n)
        return 0

proc checkLine(self: SudokuIndividual, col: uint8, row: uint8, colInc: uint8, rowInc: uint8): uint8 =
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

proc checkBlock(self: SudokuIndividual, i: uint8, j: uint8): uint8 =
    result = 0 # Number of errors
    var inUse: set[uint8]

    for u in 0'u8..2:
        for v in 0'u8..2:
            result += self.checkPos(i + u, j + v, inUse)

proc randomEmptyPosition(self: SudokuIndividual): (uint8, uint8) =
    var col = randomIndex()
    var row = randomIndex()

    while self.getValue1(col, row) != 0:
        col = randomIndex()
        row = randomIndex()

    return (col, row)

proc randomCol(self: SudokuIndividual, row: uint8): uint8 =
    var col = randomIndex()

    while self.getValue1(col, row) != 0:
        col = randomIndex()

proc randomRow(self: SudokuIndividual, col: uint8): uint8 =
    var row = randomIndex()

    while self.getValue1(col, row) != 0:
        row = randomIndex()

proc swapValues(self: var SudokuIndividual, col1, row1, col2, row2: uint8) =
    let v1 = self.getValue2(col1, row1)
    let v2 = self.getValue2(col2, row2)

    self.setValue2(col1, row1, v2)
    self.setValue2(col2, row2, v1)

proc numInCol(self: SudokuIndividual, col: uint8): set[uint8] =
    for row in 0'u8..8:
        let n = self.getValue2(col, row)
        if n > 0:
            result.incl(n)

proc numInRow(self: SudokuIndividual, row: uint8): set[uint8] =
    for col in 0'u8..8:
        let n = self.getValue2(col, row)
        if n > 0:
            result.incl(n)

proc numInBlock(self: SudokuIndividual, col: uint8, row: uint8): set[uint8] =
    let c = (col div 3) * 3
    let r = (row div 3) * 3

    for u in 0'u8..2:
        for v in 0'u8..2:
            let n = self.getValue2(c + u, r  + v)
            if n > 0:
                result.incl(n)

proc determineValue(self: var SudokuIndividual, col: uint8, row: uint8) =

    let colInUse = self.numInCol(col)
    let rowInUse = self.numInRow(row)
    let blockInUse = self.numInBlock(col, row)

    let v = getFreeNumber(colInUse + rowInUse + blockInUse)
    self.setValue2(col, row, v)

method naMutate*(self: var SudokuIndividual) =
    let (col, row) = self.randomEmptyPosition()
    let operation = rand(9)

    case operation
    of 0:
        self.setValue2(col, row, randomValue())
    of 1:
        let n = rand(9) + 1

        for _ in 0..n:
            let col2 = self.randomCol(row)
            self.swapValues(col, row, col2, row)
    of 2:
        let n = rand(9) + 1

        for _ in 0..n:
            let row2 = self.randomRow(col)
            self.swapValues(col, row, col, row2)
    of 3:
        let n = rand(9) + 1

        for _ in 0..n:
            let (col1, row1) = self.randomEmptyPosition()
            let (col2, row2) = self.randomEmptyPosition()
            self.swapValues(col1, row1, col2, row2)
    of 4:
        let col1 = decIndex(col)
        let col2 = incIndex(col)
        let row1 = decIndex(row)
        let row2 = incIndex(row)

        var inUse: set[uint8]

        inUse.incl(self.getValue2(col, row1))
        inUse.incl(self.getValue2(col, row2))
        inUse.incl(self.getValue2(col1, row))
        inUse.incl(self.getValue2(col2, row))

        let v = getFreeNumber(inUse)
        self.setValue2(col, row, v)
    of 5:
        if self.getValue2(col, row) > 0:
            self.setValue2(col, row, 0)
    of 6:
        let colInUse = self.numInCol(col)
        let v = getFreeNumber(colInUse)
        self.setValue2(col, row, v)
    of 7:
        let rowInUse = self.numInRow(row)
        let v = getFreeNumber(rowInUse)
        self.setValue2(col, row, v)
    of 8:
        let blockInUse = self.numInBlock(col, row)
        let v = getFreeNumber(blockInUse)
        self.setValue2(col, row, v)
    of 9:
        self.determineValue(col, row)
    else:
        raise newException(ValueError, fmt("Unknown mutation operation: {operation}"))

method naRandomize*(self: var SudokuIndividual) =
    let last = self.data1.high

    for i in 0..last:
        if self.data1[i] == 0:
            self.data2[i] = randomValue()
        else:
            self.data2[i] = self.data1[i]

method naCalculateFitness*(self: var SudokuIndividual) =
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

