
# Nim std imports
import std/json
import std/jsonutils
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import narwin/na_config
import narwin/na_individual

type
    TestIndividual* = ref object of NAIndividual
        data*: string

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
        "v4444"
    ])

proc nextRandomValue(): string =
    result = fakeStrings.values[fakeStrings.i]
    inc(fakeStrings.i)
    if fakeStrings.i > uint32(fakeStrings.values.high):
        fakeStrings.i = 0

method naMutate*(self: var TestIndividual) =
    self.data = nextRandomValue()

method naRandomize*(self: var TestIndividual) =
    self.data = nextRandomValue()

method naCalculateFitness*(self: var TestIndividual) =
    self.fitness = float64(self.data.len())

method naClone*(self: TestIndividual): NAIndividual =
    result = TestIndividual(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: TestIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var TestIndividual, data: seq[byte]) =
    self = ncFromBytes(data, TestIndividual)

method naToJSON*(self: TestIndividual): JsonNode =
    self.toJson()

method naFromJSON*(self: TestIndividual, data: JsonNode): NAIndividual =
    return data.jsonTo(TestIndividual)

proc assertValues*(individual: NAIndividual, data: string, fitness: float64) =
    let j1 = individual.naToJSON()
    let j2 = %* {"data": data, "fitness": fitness}
    let msg = fmt("\n----------\nJSON not equal:\nleft: {j1}\nright: {j2}\n----------\n")

    assert(j1 == j2, msg)

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

