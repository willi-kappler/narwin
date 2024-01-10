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

from std/math import hypot
from std/random import rand, shuffle
from std/strutils import split, parseFloat
from std/strformat import fmt
from std/algorithm import sort, nextPermutation

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

proc naCheckPermutations(self: var TSPIndividual, indices: var seq[int]) =
        let values = @[
            self.data[indices[0]],
            self.data[indices[1]],
            self.data[indices[2]],
            self.data[indices[3]],
            self.data[indices[4]]
        ]

        let numOfValues = values.high

        var bestFitness = self.naCalculateFitness2()
        var bestPermutation = indices

        indices.sort()

        while true:
            for i in 0..numOfValues:
                self.data[indices[i]] = values[i]

            let fitness = self.naCalculateFitness2()
            if fitness < bestFitness:
                bestFitness = fitness
                bestPermutation = indices

            if not indices.nextPermutation():
                break

        for i in 0..numOfValues:
            self.data[bestPermutation[i]] = values[i]

method naMutate*(self: var TSPIndividual) =
    let last = self.data.high
    var i = rand(last)
    var j = rand(last)

    # Ensure that i != j
    while i == j:
        j = rand(last)

    if i > j:
        swap(i, j)

    # Choose a random mutation operation
    let operation = rand(6)

    case operation
    of 0:
        # Very simple and dumb mutation:
        # just swap two positions

        swap(self.data[i], self.data[j])
    of 1:
        # Rotate left

        let tmp = self.data[i]
        for k in i..<j:
            self.data[k] = self.data[k+1]
        self.data[j] = tmp
    of 2:
        # Rotate right

        let tmp = self.data[j]
        for k in i..<j:
            let l = i + j - k - 1
            self.data[l+1] = self.data[l]
        self.data[i] = tmp
    of 3:
        # Reverse order

        let d = j - i

        for k in 0..<d:
            let u = i+k
            let v = j-k
            if u > v:
                break
            swap(self.data[u], self.data[v])
    of 4:
        # Swap two parts

        # Select random length
        let limit = min(last - j, j - i - 1)
        var d = rand(limit)

        for k in 0..d:
            swap(self.data[i+k], self.data[j+k])
    of 5:
        # Swap positions along a line of indidices

        for k in countup(i, j, 2):
            if k + 1 <= last:
                swap(self.data[k], self.data[k + 1])
    of 6:
        if rand(100) == 0:
            # This is CPU intensive, so don't do it too often.
            # Take 5 random positions and find the best order (permutation):
            var indices = @[i, j, rand(last), rand(last), rand(last)]

            # The indices must be unique:
            while (indices[0] == indices[2]) or
                (indices[1] == indices[2]):
                indices[2] = rand(last)

            while (indices[0] == indices[3]) or
                (indices[1] == indices[3]) or
                (indices[2] == indices[3]):
                indices[3] = rand(last)

            while (indices[0] == indices[4]) or
                (indices[1] == indices[4]) or
                (indices[2] == indices[4]) or
                (indices[3] == indices[4]):
                indices[4] = rand(last)

            self.naCheckPermutations(indices)
        else:
            swap(self.data[i], self.data[j])
    of 7:
        if rand(100) == 0:
            # This is CPU intensive, so don't do it too often.
            i = rand(last - 5)

            var indices = @[i, i + 1, i + 2, i + 3, i + 4]

            self.naCheckPermutations(indices)
        else:
            swap(self.data[i], self.data[j])
    else:
        raise newException(ValueError, fmt("Unknown mutation operation: {operation}"))

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

