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
from std/sequtils import toSeq

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
    var i = randIndex()
    var j = randIndex()

    # Ensure that the value is allowed to change:
    while self.getVal1(i, j) != 0:
        i = randIndex()
        j = randIndex()

    let allNumbers = {1'u8..9}

    let colSet = self.colInUse(i)
    let rowSet = self.rowInUse(j)
    let blockSet = self.blockInUse(i, j)

    let possibleNumbers = toSeq(allNumbers - (colSet + rowSet + blockSet))

    if possibleNumbers.len() == 0:
        self.setVal2(i, j, randValue())
    else:
        let v = possibleNumbers[rand(possibleNumbers.high)]
        self.setVal2(i, j, v)

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

