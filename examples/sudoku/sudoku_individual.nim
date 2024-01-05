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

proc decIndex(i: uint8): uint8 =
    if i == 0:
        return 8
    else:
        return i - 1

proc incIndex(i: uint8): uint8 =
    if i == 8:
        return 0
    else:
        return i + 1

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

proc reset(self: var SudokuIndividual) =
    self.data2 = self.data1

proc hasFreePlace(self: SudokuIndividual): bool =
    result = false

    for v in self.data2:
        if v == 0:
            result = true
            break

proc randomEmptyPosition1(self: SudokuIndividual): (uint8, uint8) =
    var col = randomIndex()
    var row = randomIndex()

    while self.getValue1(col, row) != 0:
        col = randomIndex()
        row = randomIndex()

    return (col, row)

proc randomEmptyPosition2(self: SudokuIndividual): (uint8, uint8) =
    var col = randomIndex()
    var row = randomIndex()

    while self.getValue2(col, row) != 0:
        col = randomIndex()
        row = randomIndex()

    return (col, row)

proc isValid(self: SudokuIndividual, col, row, n: uint8): bool =
    for col2 in 0'u8..8:
        if self.getValue1(col2, row) == n:
            return false

    for row2 in 0'u8..8:
        if self.getValue1(col, row2) == n:
            return false

    let col2 = (col div 3) * 3
    let row2 = (row div 3) * 3

    for u in 0'u8..2:
        for v in 0'u8..2:
            if self.getValue1(col2 + u, row2 + v) == n:
                return false

    return true

proc getValidNumber(self: SudokuIndividual, col, row: uint8): uint8 =
    var numbers: seq[uint8] = @[1, 2, 3, 4, 5, 6, 7, 8, 9]
    shuffle(numbers)

    for n in numbers:
        if self.isValid(col, row, n):
            return n

    return 0

proc randomValue2(self: SudokuIndividual, col, row: uint8): uint8 =
    let c1 = decIndex(col)
    let c2 = incIndex(col)
    let r1 = decIndex(row)
    let r2 = incIndex(row)

    let v1 = self.getValue2(col, r1)
    let v2 = self.getValue2(col, r2)
    let v3 = self.getValue2(c1, row)
    let v4 = self.getValue2(c2, row)

    result = randomValue()

    while (result == v1) or (result == v2) or (result == v3) or (result == v4):
        result = randomValue()

proc swapValues(self: var SudokuIndividual, col1, row1, col2, row2: uint8) =
    let v1 = self.getValue2(col1, row1)
    let v2 = self.getValue2(col2, row2)

    self.setValue2(col1, row1, v2)
    self.setValue2(col2, row2, v1)

proc incValue(self: var SudokuIndividual, col, row: uint8) =
    let n = self.getValue2(col, row)

    if n == 9:
        self.setValue2(col, row, 1)
    else:
        self.setValue2(col, row, n + 1)

proc decValue(self: var SudokuIndividual, col, row: uint8) =
    let n = self.getValue2(col, row)

    if n <= 1:
        self.setValue2(col, row, 9)
    else:
        self.setValue2(col, row, n - 1)

proc swapInCol(self: var SudokuIndividual, col, row1: uint8) =
    var row2 = randomIndex()

    while self.getValue1(col, row2) != 0:
        row2 = randomIndex()

    self.swapValues(col, row1, col, row2)

proc swapInRow(self: var SudokuIndividual, col1, row: uint8) =
    var col2 = randomIndex()

    while self.getValue1(col2, row) != 0:
        col2 = randomIndex()

    self.swapValues(col1, row, col2, row)

method naMutate*(self: var SudokuIndividual) =
    let (col, row) = self.randomEmptyPosition1()

    const maxOperation = 6
    let operation = rand(maxOperation)

    case operation
    of 0:
        self.setValue2(col, row, randomValue())
    of 1:
        self.setValue2(col, row, self.randomValue2(col, row))
    of 2:
        self.incValue(col, row)
    of 3:
        self.decValue(col, row)
    of 4:
        self.swapInCol(col, row)
    of 5:
        self.swapInRow(col, row)
    of maxOperation:
        let (col2, row2) = self.randomEmptyPosition1()
        self.swapValues(col, row, col2, row2)
    else:
        raise newException(ValueError, fmt("Unknown mutation operation: {operation}"))

method naRandomize*(self: var SudokuIndividual) =
    for i in 0..self.data1.high:
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

