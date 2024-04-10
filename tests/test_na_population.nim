# Nim std imports
import std/json
import std/jsonutils
from std/fenv import maximumPositiveValue

# External imports
import num_crunch

# Local imports
import narwin/na_individual
import narwin/na_population
import util

proc test1_init() =
    let config1 = makeConfig()
    var individual1 = TestIndividual1(data: "Test1")
    individual1.fitness = 5.0
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
    var individual1 = TestIndividual1(data: "Test2")
    individual1.fitness = 5.0
    let initPopulation = newSeq[NAIndividual](config1.populationSize)

    doAssertRaises AssertionDefect:
        let population = naInitPopulation(individual1, config1, initPopulation)

proc test3_failIteration() =
    var config1 = makeConfig()
    config1.numOfIterations = 0
    var individual1 = TestIndividual1(data: "Test3")
    individual1.fitness = 5.0
    let initPopulation = newSeq[NAIndividual](config1.populationSize)

    doAssertRaises AssertionDefect:
        let population = naInitPopulation(individual1, config1, initPopulation)

proc test4_failMutation() =
    var config1 = makeConfig()
    config1.numOfMutations = 0
    var individual1 = TestIndividual1(data: "Test4")
    individual1.fitness = 5.0
    let initPopulation = newSeq[NAIndividual](config1.populationSize)

    doAssertRaises AssertionDefect:
        let population = naInitPopulation(individual1, config1, initPopulation)

proc test5_randomIndex() =
    let config1 = makeConfig()
    var individual1 = TestIndividual1(data: "Test5")
    individual1.fitness = 5.0
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    let population = naInitPopulation(individual1, config1, initPopulation)

    for _ in 0..<100:
        let i = population.naGetRandomIndex()
        assert i >= 0
        assert i <= (config1.populationSize - 1)

proc test6_findIndividual() =
    let config1 = makeConfig()
    var individual1 = TestIndividual1(data: "Test6")
    individual1.fitness = 5.0
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
    var individual1 = TestIndividual1(data: "Test7")
    individual1.fitness = 5.0
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
    var individual1 = TestIndividual1(data: "Test8")
    individual1.fitness = 5.0
    let binaryIndividual1 = individual1.naToBytes()
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)
    population.resetPopulation = true

    population.naResetOrAcepptBest(binaryIndividual1)

    assertValues(population[0'u32], "v666666", 7.0)
    assertValues(population[1'u32], "v7777777", 8.0)
    assertValues(population[2'u32], "v55555", 6.0)
    assertValues(population[3'u32], "v88888888", 9.0)
    assertValues(population[4'u32], "vvvvvvvvvvv", 11.0)

    population.resetPopulation = false

    population.naResetOrAcepptBest(binaryIndividual1)

    assertValues(population[0'u32], "Test8", 5.0)
    assertValues(population[1'u32], "v7777777", 8.0)
    assertValues(population[2'u32], "v55555", 6.0)
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

proc test9_replaceWorst() =
    let config1 = makeConfig()
    var individual1 = TestIndividual1(data: "Test9")
    individual1.fitness = 3.5
    let binaryIndividual1 = individual1.naToBytes()
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

    population.naReplaceWorst(binaryIndividual1)

    assertValues(population[0'u32], "v1", 2.0)
    assertValues(population[1'u32], "v22", 3.0)
    assertValues(population[2'u32], "v333", 4.0)
    assertValues(population[3'u32], "v666666", 7.0)
    assertValues(population[4'u32], "Test9", 3.5)

    assert uint32(population.population.len()) == config1.populationSize
    assert population.populationSize == config1.populationSize
    assert population.numOfIterations == config1.numOfIterations
    assert population.numOfMutations == config1.numOfMutations
    assert population.acceptNewBest == config1.acceptNewBest
    assert population.resetPopulation == config1.resetPopulation
    assert population.targetFitness == config1.targetFitness
    assert population.bestIndex == 0
    assert population.bestFitness == maximumPositiveValue(float64)
    assert population.worstIndex == 3
    assert population.worstFitness == 5.0

proc test10_clone() =
    let config1 = makeConfig()
    var individual1 = TestIndividual1(data: "Test10")
    individual1.fitness = 6.0
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

    let indi0 = population.naClone(0)
    assertValues(indi0, "v1", 2.0)

    let indi1 = population.naClone(1)
    assertValues(indi1, "v22", 3.0)

    let indi2 = population.naClone(2)
    assertValues(indi2, "v333", 4.0)

    let indi3 = population.naClone(3)
    assertValues(indi3, "Test10", 6.0)

    let indi4 = population.naClone(4)
    assertValues(indi4, "v999999999", 10.0)

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

proc test11_index() =
    let config1 = makeConfig()
    var individual1 = TestIndividual1(data: "Test11")
    individual1.fitness = 5.0
    let initPopulation = newSeq[NAIndividual](config1.populationSize)
    fakeStrings.i = 0
    var population = naInitPopulation(individual1, config1, initPopulation)

    assertValues(population[0'u32], "v1", 2.0)
    assertValues(population[1'u32], "v22", 3.0)
    assertValues(population[2'u32], "v333", 4.0)
    assertValues(population[3'u32], "Test11", 6.0)
    assertValues(population[4'u32], "v999999999", 10.0)

    population[0'u32].fitness = 9.72
    assertValues(population[0'u32], "v1", 9.72)

    individual1.data = "Aziza"
    individual1.fitness = 97.2

    population[1'u32] = individual1
    assertValues(population[1'u32], "Aziza", 97.2)

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

when isMainModule:
    test1_init()
    test2_failSize()
    test3_failIteration()
    test4_failMutation()
    test5_randomIndex()
    test6_findIndividual()
    test7_resetPopulation()
    test8_resetOrAccept()
    test9_replaceWorst()
    test10_clone()
    test11_index()

