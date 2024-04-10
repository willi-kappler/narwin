

# External imports
import num_crunch

# Local imports
import narwin/na_config
import narwin/na_individual
import narwin/na_population_node1
import util

proc test1() =
    var config1 = makeConfig()
    config1.resetPopulation = true
    config1.numOfIterations = 1
    var individual1 = TestIndividual(data: "Test1")
    individual1.fitness = 5.0
    let binaryIndividual1 = individual1.naToBytes()

    var population: NCNodeDataProcessor = naInitPopulationNodeDP1(individual1, config1)
    let binaryIndividual2 = population.ncProcessData(binaryIndividual1)

    assertValues(binaryIndividual2, "v", 1.0)

when isMainModule:
    test1()

