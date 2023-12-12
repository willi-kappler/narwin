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
import na_individual
import na_population

type
    NAPopulationNodeDP = ref object of NCNodeDataProcessor
        population: NAPopulation

method ncProcessData(self: var NAPopulationNodeDP, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    self.population.naSetNewBestIndividualBytes(inputData)

    self.population.naRun()

    return self.population.naGetBestIndividualBytes()

proc naInitPopulationNodeDP*(individual: NAIndividual): NAPopulationNodeDP =
    return NAPopulationNodeDP(population: naInitPopulation(individual))

