## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutionary algorithms.
##
## This file contains some utility functions for testing.
##

# Nim std imports
import std/json
import std/jsonutils
from std/strformat import fmt
from std/random import rand

# External imports
import num_crunch

# Local imports
import narwin/na_config
import narwin/na_individual

type
    TestIndividual1* = ref object of NAIndividual
        data*: string

    TestIndividual2* = ref object of NAIndividual
        data*: seq[uint8]

    FakeRandom = object
        i*: uint32
        values: seq[string]

var fakeStrings* = FakeRandom(i: 0, values: @[
        "v22",
        "v1",
        "v999999999",
        "v333",
        "v666666",
        "v7777777",
        "v55555",
        "v88888888",
        "vvvvvvvvvvv",
        "v4444",
        "v"
    ])

proc nextRandomValue(): string =
    result = fakeStrings.values[fakeStrings.i]
    inc(fakeStrings.i)
    if fakeStrings.i > uint32(fakeStrings.values.high):
        fakeStrings.i = 0

# TestIndividual1:
method naMutate*(self: var TestIndividual1) =
    self.data = nextRandomValue()

method naRandomize*(self: var TestIndividual1) =
    self.data = nextRandomValue()

method naCalculateFitness*(self: var TestIndividual1) =
    self.fitness = float64(self.data.len())

method naClone*(self: TestIndividual1): NAIndividual =
    result = TestIndividual1(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: TestIndividual1): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var TestIndividual1, data: seq[byte]) =
    self = ncFromBytes(data, TestIndividual1)

method naToJSON*(self: TestIndividual1): JsonNode =
    self.toJson()

method naFromJSON*(self: TestIndividual1, data: JsonNode): NAIndividual =
    return data.jsonTo(TestIndividual1)

# TestIndividual2:
method naMutate*(self: var TestIndividual2) =
    let i = rand(self.data.len - 1)
    self.data[i] = uint8(rand(1))

method naRandomize*(self: var TestIndividual2) =
    for i in 0..<self.data.len:
        self.data[i] = uint8(rand(1))

method naCalculateFitness*(self: var TestIndividual2) =
    var c = 0

    for i in 0..<self.data.len:
        if self.data[i] == 0:
            inc(c)

    self.fitness = float64(c)

method naClone*(self: TestIndividual2): NAIndividual =
    result = TestIndividual2(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: TestIndividual2): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var TestIndividual2, data: seq[byte]) =
    self = ncFromBytes(data, TestIndividual2)

method naToJSON*(self: TestIndividual2): JsonNode =
    self.toJson()

method naFromJSON*(self: TestIndividual2, data: JsonNode): NAIndividual =
    return data.jsonTo(TestIndividual2)

# Test helper functions
proc assertValues*(individual: NAIndividual, data: string, fitness: float64) =
    let j1 = individual.naToJSON()
    let j2 = %* {"data": data, "fitness": fitness}
    let msg = fmt("\n----------\nJSON not equal:\nleft: {j1}\nright: {j2}\n----------\n")

    assert(j1 == j2, msg)

proc assertValues*(binaryIndividual: seq[byte], data: string, fitness: float64) =
    var individual: NAIndividual = TestIndividual1()
    individual.naFromBytes(binaryIndividual)
    assertValues(individual, data, fitness)

proc assertValues*(individual: NAIndividual, data: seq[uint8], fitness: float64) =
    let j1 = individual.naToJSON()
    let j2 = %* {"data": data, "fitness": fitness}
    let msg = fmt("\n----------\nJSON not equal:\nleft: {j1}\nright: {j2}\n----------\n")

    assert(j1 == j2, msg)

proc assertValues*(binaryIndividual: seq[byte], data: seq[uint8], fitness: float64) =
    var individual: NAIndividual = TestIndividual2()
    individual.naFromBytes(binaryIndividual)
    assertValues(individual, data, fitness)

proc makeConfig*: NAConfiguration =
    result.serverMode = false
    result.targetFitness = 0.0
    result.resultFilename = ""
    result.saveNewFitness = true
    result.sameFitness = false
    result.shareOnyBest = false

    result.populationSize = 5
    result.numOfIterations = 10
    result.numOfMutations = 2
    result.acceptNewBest = true
    result.resetPopulation = false
    result.populationKind = 1

    result.dt = 0.001
    result.amplitude = 1.0
    result.base = 1.0
    result.limitFactor = 1.01

    result.loadIndividual = ""

