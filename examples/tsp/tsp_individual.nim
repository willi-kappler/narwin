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

from std/math import hypot
from std/random import rand, shuffle, sample
from std/strutils import split, parseFloat
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import ../../src/narwin

type
    TSPIndividual* = ref object of NAIndividual
        data: seq[(float64, float64)]

proc naCalculateFitness2(self: var TSPIndividual): float64 =
    var length: float64 = 0.0
    let last = self.data.high

    for i in 1..<last:
        let dx = self.data[i - 1][0] - self.data[i][0]
        let dy = self.data[i - 1][1] - self.data[i][1]
        let d = hypot(dx, dy)
        length += d

    let dx = self.data[0][0] - self.data[last][0]
    let dy = self.data[0][1] - self.data[last][1]
    let d = hypot(dx, dy)
    length += d

    return length

method naMutate*(self: var TSPIndividual) =
    let last = self.data.high
    var i = rand(last)
    var j = rand(last)

    # Ensure that i != j
    while i == j:
        j = rand(last)

    if i > j:
        swap(i, j)

    # Reverse order

    let d = j - i

    for k in 0..<d:
        let u = i+k
        let v = j-k
        if u >= v:
            break
        swap(self.data[u], self.data[v])

method naRandomize*(self: var TSPIndividual) =
    shuffle(self.data)

method naCalculateFitness*(self: var TSPIndividual) =
    self.fitness = self.naCalculateFitness2()

method naClone*(self: TSPIndividual): NAIndividual =
    result = TSPIndividual(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: TSPIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var TSPIndividual, data: seq[byte]) =
    self = ncFromBytes(data, TSPIndividual)

method naToJSON*(self: TSPIndividual): JsonNode =
    self.toJson()

method naFromJSON*(self: TSPIndividual, data: JsonNode): NAIndividual =
    return data.jsonTo(TSPIndividual)

proc loadTSP*(fileName: string): TSPIndividual =
    result = TSPIndividual(data: @[])

    let f = open(fileName)
    var line: string

    while f.read_line(line):
        let values = line.split()
        let x = parseFloat(values[0])
        let y = parseFloat(values[1])
        result.data.add((x, y))

    f.close()

