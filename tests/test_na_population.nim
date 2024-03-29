# Nim std imports
import std/json
import std/jsonutils
from std/fenv import maximumPositiveValue

# External imports
import num_crunch

# Local imports
import narwin/na_config
import narwin/na_individual
import narwin/na_population
import util

type
    TestIndividual* = ref object of NAIndividual
        data: string

    FakeRandom = object
        i: uint32
        values: seq[string]

var fakeStrings = FakeRandom(i: 0, values: @[
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

proc makeConfig: NAConfiguration =
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

proc test1_init() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test1")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    let population = naInitPopulation(individual1, config1, initPopulation)

    assertValues(population[0'u32], "v1", 2.0)
    assertValues(population[1'u32], "v22", 3.0)
    assertValues(population[2'u32], "v333", 4.0)
    assertValues(population[3'u32], "Test1", 5.0)
    assertValues(population[4'u32], "v999999999", 10.0)

    assert uint32(population.population.len()) == config1.populationSize

    assert population.populationSize == config1.populationSize
    assert population.numOfIterations == config1.numOfIterations
    assert population.numOfMutations == config1.numOfMutations
    assert population.acceptNewBest == config1.acceptNewBest
    assert population.resetPopulation == config1.resetPopulation
    assert population.targetFitness == config1.targetFitness
    assert population.bestIndex == 0
    assert population.bestFitness == maximumPositiveValue(float64)
    assert population.worstIndex == 0
    assert population.worstFitness == 0.0

proc test2_failSize() =
    var config1 = makeConfig()
    config1.populationSize = 0
    var individual1 = TestIndividual(data: "Test2")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)

    doAssertRaises AssertionDefect:
        let population = naInitPopulation(individual1, config1, initPopulation)

proc test3_failIteration() =
    var config1 = makeConfig()
    config1.numOfIterations = 0
    var individual1 = TestIndividual(data: "Test3")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)

    doAssertRaises AssertionDefect:
        let population = naInitPopulation(individual1, config1, initPopulation)

proc test4_failMutation() =
    var config1 = makeConfig()
    config1.numOfMutations = 0
    var individual1 = TestIndividual(data: "Test4")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)

    doAssertRaises AssertionDefect:
        let population = naInitPopulation(individual1, config1, initPopulation)

proc test5_randomIndex() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test5")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    let population = naInitPopulation(individual1, config1, initPopulation)

    for _ in 0..<100:
        let i = population.naGetRandomIndex()
        assert i >= 0
        assert i <= (config1.populationSize - 1)

proc test6_findIndividual() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test6")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    var population = naInitPopulation(individual1, config1, initPopulation)

    individual1.data = "a12345"
    individual1.fitness = 6.0
    population[0] = individual1

    individual1.data = "a1234567890"
    individual1.fitness = 11.0
    population[3] = individual1

    population.naFindWorstIndividual()
    assert population.worstIndex == 3
    assert population.worstFitness == 11.0

    individual1.data = "aa1234567890"
    individual1.fitness = 12.0
    population[4] = individual1

    population.naFindBestAndWorstIndividual()
    assert population.bestIndex == 1
    assert population.bestFitness == 3.0
    assert population.worstIndex == 4
    assert population.worstFitness == 12.0

    assert uint32(population.population.len()) == config1.populationSize
    assert population.populationSize == config1.populationSize
    assert population.numOfIterations == config1.numOfIterations
    assert population.numOfMutations == config1.numOfMutations
    assert population.acceptNewBest == config1.acceptNewBest
    assert population.resetPopulation == config1.resetPopulation
    assert population.targetFitness == config1.targetFitness

proc test7_resetPopulation() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test7")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

    population.naResetPopulation()

    assertValues(population[0'u32], "v666666", 7.0)
    assertValues(population[1'u32], "v7777777", 8.0)
    assertValues(population[2'u32], "v55555", 6.0)
    assertValues(population[3'u32], "v88888888", 9.0)
    assertValues(population[4'u32], "vvvvvvvvvvv", 11.0)

    population.naSort()

    assertValues(population[0'u32], "v55555", 6.0)
    assertValues(population[1'u32], "v666666", 7.0)
    assertValues(population[2'u32], "v7777777", 8.0)
    assertValues(population[3'u32], "v88888888", 9.0)
    assertValues(population[4'u32], "vvvvvvvvvvv", 11.0)

    assert uint32(population.population.len()) == config1.populationSize
    assert population.populationSize == config1.populationSize
    assert population.numOfIterations == config1.numOfIterations
    assert population.numOfMutations == config1.numOfMutations
    assert population.acceptNewBest == config1.acceptNewBest
    assert population.resetPopulation == config1.resetPopulation
    assert population.targetFitness == config1.targetFitness
    assert population.bestIndex == 0
    assert population.bestFitness == maximumPositiveValue(float64)
    assert population.worstIndex == 0
    assert population.worstFitness == 0.0

proc test8_resetOrAccept() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test8")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

proc test9_replaceWorst() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test9")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

proc test10_clone() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test10")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

proc test11_index1() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test11")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

proc test12_index2() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test12")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

proc test13_index3() =
    let config1 = makeConfig()
    var individual1 = TestIndividual(data: "Test13")
    individual1.fitness = 5
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)


when isMainModule:
    test1_init()
    test2_failSize()
    test3_failIteration()
    test4_failMutation()
    test5_randomIndex()
    test6_findIndividual()
    test7_resetPopulation()





