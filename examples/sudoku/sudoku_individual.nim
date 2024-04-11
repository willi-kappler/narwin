# This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutionary algorithms.
##
## This module contains the implementation of the NAIndividual code from narwin for the Sudoku example.
##


# Nim std imports
import std/json
import std/jsonutils

from std/random import rand, shuffle
#from std/strformat import fmt

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

proc numInBlock(self: SudokuIndividual, i, j: uint8, n: uint8): bool =
    for c in 0'u8..2:
        for r in 0'u8..2:
            if self.getValue1(i + c, j + r) == n:
                return true

    return false

proc randomBlock(self: var SudokuIndividual) =
    let col: uint8 = uint8(rand(2)) * 3
    let row: uint8 = uint8(rand(2)) * 3
    var numbers: seq[uint8] = @[]

    for n in 1'u8..9:
        if self.numInBlock(col, row, n):
            continue
        else:
            numbers.add(n)

    if numbers.len() > 0:
        shuffle(numbers)

        for i in 0'u8..2:
            for j in 0'u8..2:
                let u = col + i
                let v = row + j
                if self.getValue1(u, v) == 0:
                    let n = numbers.pop()
                    self.setValue2(u, v, n)

proc randomTriple(self: var SudokuIndividual) =
    let i = uint8(rand(2)) * 3
    let j = uint8(rand(2)) * 3

    let operation = rand(1)
    let index = uint8(rand(2))

    if operation == 0:
        for row in 0'u8..2:
            let u = index + i
            let v = row + j
            if self.getValue1(u, v) == 0:
                let n = randomValue()
                self.setValue2(u, v, n)
    else:
        for col in 0'u8..2:
            let u = col + i
            let v = index + j
            if self.getValue1(u, v) == 0:
                let n = randomValue()
                self.setValue2(u, v, n)

method naMutate*(self: var SudokuIndividual) =
    let op = rand(1)

    if op == 0:
        self.randomBlock()
    else:
        self.randomTriple()

proc randomize1(self: var SudokuIndividual) =
    # Initialize with random values:
    for i in 0..self.data1.high:
            if self.data1[i] == 0:
                self.data2[i] = randomValue()
            else:
                self.data2[i] = self.data1[i]

method naRandomize*(self: var SudokuIndividual) =
    self.randomize1()

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
        0, 8, 0,   0, 9, 4,   0, 0, 0,
        2, 0, 3,   0, 0, 0,   9, 4, 0,
        0, 0, 0,   0, 0, 2,   1, 0, 3,

        0, 0, 8,   0, 0, 0,   7, 9, 0,
        9, 2, 0,   0, 0, 0,   0, 5, 6,
        0, 7, 6,   0, 0, 0,   3, 0, 0,

        0, 5, 7,   0, 0, 0,   2, 0, 1,
        3, 0, 2,   1, 0, 0,   0, 0, 0,
        0, 0, 0,   2, 6, 0,   0, 3, 0
        ]

    result = SudokuIndividual(data1: data, data2: data)

