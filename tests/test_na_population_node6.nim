


# Nim std imports
from std/random import randomize

# External imports
import num_crunch

# Local imports
import narwin/na_config
import narwin/na_individual
import narwin/na_population_node6
import util

proc test1() =
    var config1 = makeConfig()
    config1.resetPopulation = true
    config1.numOfIterations = 1
    var individual1 = TestIndividual1(data: "Test1")
    individual1.fitness = 5.0
    let binaryIndividual1 = individual1.naToBytes()

    var population: NCNodeDataProcessor = naInitPopulationNodeDP6(individual1, config1)
    let binaryIndividual2 = population.ncProcessData(binaryIndividual1)

    assertValues(binaryIndividual2, "v", 1.0)

proc test2() =
    var config1 = makeConfig()
    config1.resetPopulation = true
    config1.numOfIterations = 40
    let data: seq[uint8] = @[0,0,0,0,0,0,0,0,0,0]
    var individual1 = TestIndividual2(data: data)
    individual1.fitness = 5.0
    let binaryIndividual1 = individual1.naToBytes()

    var population: NCNodeDataProcessor = naInitPopulationNodeDP6(individual1, config1)
    let binaryIndividual2 = population.ncProcessData(binaryIndividual1)

    assertValues(binaryIndividual2, @[1'u8,1,1,1,1,1,1,1,1,1], 0.0)

when isMainModule:
    # Init random number generator
    randomize()

    test1()
    test2()

