## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the node code from num_crunch.
##
## This Nim library allows you to write programs using evolutionary algorithms.
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
        maxReset: uint32
        individualCounter: seq[uint32]
        individualFitness: seq[float64]

method ncProcessData(self: var NAPopulationNodeDP7, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual: NAIndividual
    var bestIndividual = self.population.naClone(0)

    for i in 0..<self.population.populationSize:
        self.individualCounter[i] = 0
        self.individualFitness[i] = self.population[i].fitness

    block iterations:
        for i in 0..<self.population.numOfIterations:
            for j in 0..<self.population.populationSize:
                # Check if the current fitness hasn't changes.
                # If it is still the same reset the individual
                # after the counter is up to the maximum.
                if self.population[j].fitness == self.individualFitness[j]:
                    inc(self.individualCounter[j])
                    if self.individualCounter[j] > self.maxReset:
                        self.individualCounter[j] = 0
                        self.individualFitness[j] = 0.0
                        self.population[j].naRandomize()
                        self.population[j].naCalculateFitness()
                else:
                    self.individualCounter[j] = 0
                    self.individualFitness[j] = self.population[j].fitness

                tmpIndividual = self.population.naClone(j)

                for _ in 0..<self.population.numOfMutations:
                    tmpIndividual.naMutate()
                    tmpIndividual.naCalculateFitness()

                    # The best one is at position 0:
                    if tmpIndividual < self.population[0]:
                        self.population[0] = tmpIndividual
                        if tmpIndividual <= self.population.targetFitness:
                            ncDebug(fmt("Early exit at i: {i}"))
                            break iterations
                        elif tmpIndividual < bestIndividual:
                            bestIndividual = tmpIndividual.naClone()
                    elif tmpIndividual < self.population[j]:
                        self.population[j] = tmpIndividual

    ncDebug(fmt("Best individual: {bestIndividual.fitness}"))
    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population[0].fitness}, worst fitness: {self.population.worstFitness}"))

    return bestIndividual.naToBytes()

proc naInitPopulationNodeDP7*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP7 =
    ncInfo("naInitPopulationNodeDP7")
    ncInfo("The best individual is at index 0, if stuck with the same fitness for too long, each individual will be reset individually.")

    assert config.maxReset > 10
    ncDebug(fmt("Max reset: {config.maxReset}"))

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP7(population: population)
    result.maxReset = config.maxReset

    result.individualCounter = newSeq[uint32](config.populationSize)
    result.individualFitness = newSeq[float64](config.populationSize)

    for i in 0..<config.populationSize:
        result.individualCounter[i] = 0
        result.individualFitness[i] = 0.0

