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

    var tmpIndividual = self.population.naClone(0)

    self.population.naResetOrAcepptBest(inputData)

    # Pick a random individual and randomize it:
    self.population.naRandomizeAny()

    for i in 0..<self.population.numOfIterations:
        for j in 0..<self.population.populationSize:
            # Find the worst individual of this iteration:
            self.population.findWorstIndividual()

            tmpIndividual = self.population.naClone(j)

            # And mutate it:
            for _ in 0..<self.population.naGetNumberOfMutations():
                tmpIndividual.naMutate()
            # Calculate the new fitness for the mutated individual:
            tmpIndividual.naCalculateFitness()

            # If the mutated individual is better than the worst
            # it gets overwritten (killed) by the better one:
            if tmpIndividual.fitness < self.population.worstFitness:
                self.population[self.population.worstIndex] = tmpIndividual.naClone()
                if tmpIndividual.fitness <= self.population.targetFitness:
                    ncDebug(fmt("Early exit at i: {i}"))
                    break

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP2*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP2 =
    ncDebug("naInitPopulationNodeDP2")

    var population = naInitPopulation(individual, config)
    population.population = newSeq[NAIndividual](config.populationSize)

    result = NAPopulationNodeDP2(population: population)
    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()

    # Initialize the population with random individuals:
    for i in 1..<config.populationSize:
        result.population[i] = individual.naNewRandomIndividual()

