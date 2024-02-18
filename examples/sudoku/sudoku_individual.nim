# This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the NAIndividual code from narwin for the Sudoku example.
##
## This Nim library allows you to write programs using evolutionary algorithms.
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

proc randomIndex(): uint8 =
    uint8(rand(8))

proc numInCol(self: SudokuIndividual, col: uint8, n: uint8): bool =
    for row in 0'u8..8:
        if self.getValue1(col, row) == n:
            return true

    return false

proc numInRow(self: SudokuIndividual, row: uint8, n: uint8): bool =
    for col in 0'u8..8:
        if self.getValue1(col, row) == n:
            return true

    return false

proc numInBlock(self: SudokuIndividual, i, j: uint8, n: uint8): bool =
    for c in 0'u8..2:
        for r in 0'u8..2:
            if self.getValue1(i + c, j + r) == n:
                return true

    return false

proc randomCol(self: var SudokuIndividual) =
    let col = randomIndex()
    var numbers: seq[uint8] = @[]

    for n in 1'u8..9:
        if self.numInCol(col, n):
            continue
        else:
            numbers.add(n)

    if numbers.len() > 0:
        shuffle(numbers)

        for row in 0'u8..8:
            if self.getValue1(col, row) == 0:
                let n = numbers.pop()
                self.setValue2(col, row, n)

proc randomRow(self: var SudokuIndividual) =
    let row = randomIndex()
    var numbers: seq[uint8] = @[]

    for n in 1'u8..9:
        if self.numInRow(row, n):
            continue
        else:
            numbers.add(n)

    if numbers.len() > 0:
        shuffle(numbers)

        for col in 0'u8..8:
            if self.getValue1(col, row) == 0:
                let n = numbers.pop()
                self.setValue2(col, row, n)

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
                if self.getValue1(col + i, row + j) == 0:
                    let n = numbers.pop()
                    self.setValue2(col + i, row + j, n)

proc randomEmptyPosition1(self: SudokuIndividual): (uint8, uint8) =
    var col = randomIndex()
    var row = randomIndex()

    while self.getValue1(col, row) != 0:
        col = randomIndex()
        row = randomIndex()

    return (col, row)

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

proc randomCell(self: var SudokuIndividual) =
    let (col, row) = self.randomEmptyPosition1()
    let n = self.randomValue2(col, row)
    self.setValue2(col, row, n)

proc randomTriple(self: var SudokuIndividual) =
    let u = uint8(rand(2)) * 3
    let v = uint8(rand(2)) * 3

    let operation = rand(1)
    let index = uint8(rand(2))

    if operation == 0:
        for row in 0'u8..2:
            if self.getValue1(index + u, row + v) == 0:
                let n = randomValue()
                self.setValue2(index + u, row + v, n)
    else:
        for col in 0'u8..2:
            if self.getValue1(col + u, index + v) == 0:
                let n = randomValue()
                self.setValue2(col + u, index + v, n)

proc mutate1(self: var SudokuIndividual) =
    let operation = rand(4)

    if operation == 0:
        self.randomCell()
    elif operation == 1:
        self.randomTriple()
    elif operation == 2:
        self.randomCol()
    elif operation == 3:
        self.randomRow()
    else:
        self.randomBlock()

proc mutate2(self: var SudokuIndividual) =
    self.randomTriple()

method naMutate*(self: var SudokuIndividual) =
    self.mutate1()

proc randomize1(self: var SudokuIndividual) =
    # Initialize with 0:
    for i in 0..self.data1.high:
        self.data2[i] = self.data1[i]

proc randomize2(self: var SudokuIndividual) =
    # Initialize with random values:
    for i in 0..self.data1.high:
            if self.data1[i] == 0:
                self.data2[i] = randomValue()
            else:
                self.data2[i] = self.data1[i]

method naRandomize*(self: var SudokuIndividual) =
    self.randomize2()

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

