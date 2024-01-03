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
        #data3: seq[set[uint8]]

proc randValue(): uint8 =
    uint8(rand(8) + 1)

proc randIndex(): uint8 =
    uint8(rand(8))

proc getVal1(self: SudokuIndividual, col: uint8, row: uint8): uint8 =
    self.data1[(row * 9) + col]

proc getVal2(self: SudokuIndividual, col: uint8, row: uint8): uint8 =
    self.data2[(row * 9) + col]

proc setVal2(self: var SudokuIndividual, col: uint8, row: uint8, val: uint8) =
    self.data2[(row * 9) + col] = val

proc checkRow(self: SudokuIndividual, row: uint8): uint8 =
    result = 0 # Number of errors
    var inUse: set[uint8]

    for col in 0'u8..8:
        let n = self.getVal2(col, row)
        if (n == 0) or (n in inUse):
            inc(result)
        else:
            inUse.incl(n)

proc checkCol(self: SudokuIndividual, col: uint8): uint8 =
    result = 0 # Number of errors
    var inUse: set[uint8]

    for row in 0'u8..8:
        let n = self.getVal2(col, row)
        if (n == 0) or (n in inUse):
            inc(result)
        else:
            inUse.incl(n)

proc checkBlock(self: SudokuIndividual, i: uint8, j: uint8): uint8 =
    result = 0 # Number of errors
    var inUse: set[uint8]

    for u in 0'u8..2:
        for v in 0'u8..2:
            let n = self.getVal2(i + u, j + v)
            if (n == 0) or (n in inUse):
                inc(result)
            else:
                inUse.incl(n)

proc randomEmptyPosition(self: SudokuIndividual): (uint8, uint8) =
    var col = randIndex()
    var row = randIndex()

    while self.getVal1(col, row) != 0:
        col = randIndex()
        row = randIndex()

    return (col, row)

proc randomEmptyCol(self: SudokuIndividual, row: uint8): uint8 =
    result = randIndex()

    while self.getVal1(result, row) != 0:
        result = randIndex()

proc randomEmptyRow(self: SudokuIndividual, col: uint8): uint8 =
    result = randIndex()

    while self.getVal1(col, result) != 0:
        result = randIndex()

proc swapValues(self: var SudokuIndividual, col1: uint8, row1: uint8, col2: uint8, row2: uint8) =
    let v1 = self.getVal2(col1, row1)
    let v2 = self.getVal2(col2, row2)

    self.setVal2(col1, row1, v2)
    self.setVal2(col2, row2, v1)

proc colInUse(self: SudokuIndividual, col: uint8): set[uint8] =
    result = {}
    for row in 0'u8..8:
        let n = self.getVal2(col, row)
        if n > 0:
            result.incl(n)

proc rowInUse(self: SudokuIndividual, row: uint8): set[uint8] =
    result = {}
    for col in 0'u8..8:
        let n = self.getVal2(col, row)
        if n > 0:
            result.incl(n)

proc blockInUse(self: SudokuIndividual, col: uint8, row: uint8): set[uint8] =
    result = {}
    let i = (col div 3'u8) * 3'u8
    let j = (row div 3'u8) * 3'u8

    for u in 0'u8..2:
        for v in 0'u8..2:
            let n = self.getVal2(i + u, j + v)
            if n > 0:
                result.incl(n)

method naMutate*(self: var SudokuIndividual) =
    # Pick a random position:
    let (col, row) = self.randomEmptyPosition()

    # Pick a random mutation operation:
    let operation = rand(4)

    case operation
    of 0:
        # Set random value:
        self.setVal2(col, row, randValue())
    of 1:
        # Swap in row:
        let col2 = self.randomEmptyCol(row)
        self.swapValues(col, row, col2, row)
    of 2:
        # Swap in col:
        let row2 = self.randomEmptyRow(col)
        self.swapValues(col, row, col, row2)
    of 3:
        # Swap two random positions:
        let (col2, row2) = self.randomEmptyPosition()
        self.swapValues(col, row, col2, row2)
    of 4:
        # Swap multiple random positions:
        let counter = rand(7) + 3

        for _ in 0..counter:
            let (col1, row1) = self.randomEmptyPosition()
            let (col2, row2) = self.randomEmptyPosition()
            self.swapValues(col1, row1, col2, row2)
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

