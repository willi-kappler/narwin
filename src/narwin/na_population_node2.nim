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
from std/random import rand

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

    let operation = rand(4)
    ncDebug(fmt("Operation: {operation}"))

    case operation
    of 0:
        # Do nothing
        discard
    of 1:
        # Take the individual from the server or reset everything
        self.population.naResetOrAcepptBest(inputData)
    of 2:
        # Reset one random individual
        let i = self.population.naGetRandomIndex()
        self.population[i].naRandomize()
        self.population[i].naCalculateFitness()
    of 3:
        # Replace the worst individual
        self.population.findWorstIndividual()
        var i = self.population.naGetRandomIndex()

        while i == self.population.worstIndex:
            i = self.population.naGetRandomIndex()

        self.population[self.population.worstIndex] = self.population[i]
    of 4:
        # Compare two random individuals
        let i = self.population.naGetRandomIndex()
        var j = self.population.naGetRandomIndex()

        while i == j:
            j = self.population.naGetRandomIndex()

        if self.population[i] < self.population[j]:
            self.population[j] = self.population[i]
        elif self.population[j] < self.population[i]:
            self.population[i] = self.population[j]
    else:
        raise newException(ValueError, fmt("Unknown operation: {operation}"))

    block iterations:
        for i in 0..<self.population.numOfIterations:
            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)

                for _ in 0..<self.population.numOfMutations:
                    tmpIndividual.naMutate()
                    tmpIndividual.naCalculateFitness()

                    if tmpIndividual < self.population[j]:
                        self.population[j] = tmpIndividual
                        if tmpIndividual <= self.population.targetFitness:
                            ncDebug(fmt("Early exit at i: {i}"))
                            break iterations

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP2*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP2 =
    ncInfo("naInitPopulationNodeDP2")
    ncInfo("Mutate a clone and if it's better keep it.")

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP2(population: population)

