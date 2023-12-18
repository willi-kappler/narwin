## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the node code from num_crunch.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##

# Nim std imports
from std/strformat import fmt
from std/random import randomize, rand

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

    var tmpIndividual = self.population.population[0].naClone()

    if self.population.resetPopulation:
        ncDebug("Reset the whole population to random values")
        for i in 0..<self.population.populationSize:
            self.population.population[i].naRandomize()
            self.population.population[i].naCalculateFitness()
    elif self.population.acceptNewBest:
        tmpIndividual = self.population.population[0].naFromBytes(inputData)
        ncDebug(fmt("Accept individual from server with fitness: {tmpIndividual.fitness}"))
        self.population.findWorstIndividual()
        self.population.population[self.population.worstIndex] = tmpIndividual.naClone()

    for i in 0..<self.population.numOfIterations:
        # Find the worst individual of this iteration:
        self.population.findWorstIndividual()

        # Choose a random individual:
        let j = rand(int(self.population.populationSize - 1))
        tmpIndividual = self.population.population[j].naClone()

        # And mutate it:
        for j in 0..<self.population.numOfMutations:
            tmpIndividual.naMutate()
        # Calculate the new fitness for the mutated individual:
        tmpIndividual.naCalculateFitness()

        # If the mutated individual is better than the worst
        # it gets overwritten (killed) by the better one:
        if tmpIndividual.fitness < self.population.worstFitness:
            self.population.population[self.population.worstIndex] = tmpIndividual.naClone()
            if tmpIndividual.fitness < self.population.targetFitness:
                break

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP2*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP2 =
    var population = naInitPopulation(individual, config)
    population.population = newSeq[NAIndividual](config.populationSize)

    result = NAPopulationNodeDP2(population: population)
    result.population.population[0] = individual.naClone()
    result.population.population[0].naCalculateFitness()

    # Initialize the population with random individuals:
    for i in 1..<config.populationSize:
        result.population.population[i] = individual.naNewRandomIndividual()

