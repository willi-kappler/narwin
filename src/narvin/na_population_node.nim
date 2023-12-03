## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module just reexports items from other modules.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##

# External imports
import numcrunch

# Local imports
import na_individual
import na_population

type
    NAPopulationNodeDP = ref object of NCNodeDataProcessor
        population: NAPopulation

method ncProcessData(self: var NAPopulationNodeDP, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    let bestIndividual = ncFromBytes(inputData, NAIndividual)

    self.population.naSetNewBestIndividual(bestIndividual)

    self.population.naRun()

    let data = ncToBytes(self.population.naGetBestIndividual())
    return data

proc initPopulationNodeDP*(individual: NAIndividual): NAPopulationNodeDP =
    result.population = naInitPopulation(individual)

