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
    NAPopulationNodeDP6 = ref object of NCNodeDataProcessor
        population: NAPopulation
        bestFitness: float64

method ncProcessData(self: var NAPopulationNodeDP6, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual = self.population.naClone(0)

    self.population.naResetOrAcepptBest(inputData)

    var fitnessLimit: float64

    block iterations:
        for i in 0..<self.population.numOfIterations:
            fitnessLimit = self.bestFitness

            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)
                tmpIndividual.naMutate(self.population.operations)
                tmpIndividual.naCalculateFitness()

                if tmpIndividual < fitnessLimit:
                    self.population[j] = tmpIndividual
                elif tmpIndividual < self.population[j]:
                    self.population[j] = tmpIndividual

                if tmpIndividual < self.bestFitness:
                    self.bestFitness = tmpIndividual.fitness
                    if j > 0:
                        self.population[0] = tmpIndividual

                    if tmpIndividual <= self.population.targetFitness:
                        ncDebug(fmt("Early exit at i: {i}, j: {j}"))
                        break iterations

                fitnessLimit = fitnessLimit * 1.1

    ncDebug(fmt("Best limit: {self.bestFitness}"))
    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP6*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP6 =
    ncDebug("naInitPopulationNodeDP6")

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP6(population: population)
    result.bestFitness = result.population[0].fitness

