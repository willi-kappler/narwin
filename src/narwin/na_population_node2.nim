## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the node code from num_crunch.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##

# Nim std imports
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import na_config
import na_individual
import na_population

type
    NAPopulationNodeDP2 = ref object of NCNodeDataProcessor
        population: NAPopulation

method ncProcessData(self: var NAPopulationNodeDP2, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual: NAIndividual

    self.population.naResetOrAcepptBest(inputData)

    block iterations:
        for i in 0..<self.population.numOfIterations:
            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)
                tmpIndividual.naMutate(self.population.operations)
                tmpIndividual.naCalculateFitness()

                # The best one is at position 0:
                if tmpIndividual < self.population[0]:
                    self.population[0] = tmpIndividual
                    if tmpIndividual <= self.population.targetFitness:
                        ncDebug(fmt("Early exit at i: {i}"))
                        break iterations
                elif tmpIndividual < self.population[j]:
                    self.population[j] = tmpIndividual

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP2*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP2 =
    ncDebug("naInitPopulationNodeDP2")

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP2(population: population)

