## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the node code from num_crunch.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##

# External imports
import num_crunch

# Local imports
import na_population

type
    NAPopulationNodeDP[T] = ref object of NCNodeDataProcessor
        population: NAPopulation[T]

method ncProcessData(self: var NAPopulationNodeDP[T], inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    let individual = ncFromBytes(inputData, T)
    self.population.naSetNewBestIndividual(individual)

    self.population.naRun()

    let bestIndividual = self.population.naGetBestIndividual()
    return ncToBytes(bestIndividual)

proc naInitPopulationNodeDP*[T](individual: T): NAPopulationNodeDP[T] =
    return NAPopulationNodeDP[T](population: naInitPopulation(individual))

