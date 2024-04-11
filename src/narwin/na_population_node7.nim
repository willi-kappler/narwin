## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutionary algorithms.
##
## This module contains the implementation of the node code from num_crunch.
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
    NAPopulationNodeDP7 = ref object of NCNodeDataProcessor
        population: NAPopulation
        limitFactor: float64

method ncProcessData(self: var NAPopulationNodeDP7, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual: NAIndividual

    self.population.naReplaceWorst(inputData)

    var fitnessLimit: float64

    block iterations:
        for i in 0..<self.population.numOfIterations:
            fitnessLimit = self.population[0].fitness

            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)

                for _ in 0..<self.population.numOfMutations:
                    tmpIndividual.naMutate()
                    tmpIndividual.naCalculateFitness()

                    if tmpIndividual < fitnessLimit:
                        self.population[j] = tmpIndividual
                    elif tmpIndividual < self.population[j]:
                        self.population[j] = tmpIndividual

                    if tmpIndividual < self.population[0]:
                        self.population[0] = tmpIndividual

                        if tmpIndividual <= self.population.targetFitness:
                            ncDebug(fmt("Early exit at i: {i}, j: {j}"))
                            break iterations

                fitnessLimit = fitnessLimit * self.limitFactor

    # Find the best and the worst individual at the end:
    self.population.naFindBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population[0].fitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[0].naToBytes()

proc naInitPopulationNodeDP7*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP7 =
    ncInfo("naInitPopulationNodeDP7")
    ncInfo("Increase the limit factor by index, best individual is at index 0.")

    assert config.limitFactor > 1.0
    ncDebug(fmt("Limit factor: {config.limitFactor}"))

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP7(population: population)
    result.limitFactor = config.limitFactor


