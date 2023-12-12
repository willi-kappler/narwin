# This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the NAIndividual code from narvin for the TSP example.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##


# Nim std imports
import std/json

from std/math import hypot
from std/random import rand, shuffle
from std/strutils import split, parseFloat

type
    TSPIndividual* = object
        data: seq[(float64, float64)]
        fitness: float64

proc naMutate*(self: var TSPIndividual) =
    # Very simple and dumb mutation:
    # just swap two positions

    let last = self.data.high
    let i = rand(last)
    let j = rand(last)

    swap(self.data[i], self.data[j])

proc naRandomize*(self: var TSPIndividual) =
    shuffle(self.data)

proc naCalculateFitness*(self: var TSPIndividual) =
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

    self.fitness = length

proc naClone*(self: TSPIndividual): TSPIndividual =
    return TSPIndividual(data: self.data)

proc naNewRandomIndividual*(self: TSPIndividual): TSPIndividual =
    result = self.naClone()
    result.naRandomize()
    result.naCalculateFitness()

proc naGetFitness*(self: TSPIndividual): float64 =
    self.fitness

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

