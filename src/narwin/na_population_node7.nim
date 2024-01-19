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
    NAPopulationNodeDP7 = ref object of NCNodeDataProcessor
        population: NAPopulation
        maxReset: uint32
        prevBestFitness: float64

method ncProcessData(self: var NAPopulationNodeDP7, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var resetCounter: uint32 = 0
    var numOfResets: uint32 = 0
    var tmpIndividual: NAIndividual
    var bestIndividual = self.population.naClone(0)
    self.prevBestFitness = 0.0

    block iterations:
        for i in 0..<self.population.numOfIterations:
            # Check if the best fitness hasn't change.
            # If yes it seems this individual is stuck in a local minimum.
            # Reset the whole population then.
            if self.prevBestFitness == self.population[0].fitness:
                inc(resetCounter)
                if resetCounter >= self.maxReset:
                    resetCounter = 0
                    inc(numOfResets)
                    self.prevBestFitness = 0.0
                    self.population.naResetPopulation()
            else:
                self.prevBestFitness = self.population[0].fitness
                resetCounter = 0

            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)

                for _ in 0..<self.population.numOfMutations:
                    tmpIndividual.naMutate(self.population.operations)
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

    ncDebug(fmt("Number of resets: {numOfResets}"))
    ncDebug(fmt("Best individual: {bestIndividual.fitness}"))
    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population[0].fitness}, worst fitness: {self.population.worstFitness}"))

    return bestIndividual.naToBytes()

proc naInitPopulationNodeDP7*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP7 =
    ncDebug("naInitPopulationNodeDP7")

    assert config.maxReset > 10
    ncDebug(fmt("Max reset: {config.maxReset}"))

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP7(population: population)
    result.maxReset = config.maxReset
    result.prevBestFitness = 0.0

