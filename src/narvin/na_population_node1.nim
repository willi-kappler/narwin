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
from std/algorithm import sort

# External imports
import num_crunch

# Local imports
import na_config
import na_individual

type
    NAPopulationNodeDP1 = ref object of NCNodeDataProcessor
        population: seq[NAIndividual]
        populationSize: uint32
        numOfMutations: uint32
        numOfIterations: uint32
        acceptNewBest: bool
        resetPopulation: bool
        targetFitness: float64

proc naSort(self: var NAPopulationNodeDP1) =
    self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
        return cmp(a.fitness, b.fitness)

method ncProcessData(self: var NAPopulationNodeDP1, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    let offset = self.populationSize

    if self.resetPopulation:
        ncDebug("Reset the whole population to random values")
        for i in 0..<self.populationSize:
            self.population[i].naRandomize()
            self.population[i].naCalculateFitness()
    elif self.acceptNewBest:
        let tmpIndividual = self.population[0].naFromBytes(inputData)
        ncDebug(fmt("Accept individual from server with fitness: {tmpIndividual.fitness}"))
        self.population[offset - 2] = tmpIndividual.naClone()

    for i in 0..<self.numOfIterations:
        for j in 0..<self.populationSize:
            # Save all individuals of the current population.
            # Those will not be mutated.
            # This overwrites all the individuals above self.populationSize.
            # They will not survive and die.
            self.population[j + offset] = self.population[j].naClone()

            # Now mutate all individuals of the current active population:
            for k in 0..<self.numOfMutations:
                self.population[j].naMutate()
            # Calculate the new fitness for the mutated individual:
            self.population[j].naCalculateFitness()

        # The last individual will be totally random.
        # This helps a bit to escape a local minimum.
        self.population[offset - 1].naRandomize()
        self.population[offset - 1].naCalculateFitness()

        # Sort the whole population (new and old) by fitness:
        # All individuals that are not fit enough will be moved to position
        # above self.populationSize and will be overwritten in the next iteration.
        self.naSort()

        if self.population[0].fitness < self.targetFitness:
            break

    let fitness = self.population[0].fitness
    ncDebug(fmt("Best fitness in this run: {fitness}"))

    return self.population[0].naToBytes()

proc naInitPopulationNodeDP1*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP1 =

    ncDebug(fmt("Population size: {config.populationSize}"))
    ncDebug(fmt("Number of mutations: {config.numOfMutations}"))
    ncDebug(fmt("Number of iterations: {config.numOfIterations}"))

    assert config.populationSize >= 5
    assert config.numOfMutations > 0
    assert config.numOfIterations > 0

    # Init random number generator
    randomize()

    result = NAPopulationNodeDP1(population: newSeq[NAIndividual](2 * config.populationSize))

    result.populationSize = config.populationSize
    result.numOfMutations = config.numOfMutations
    result.numOfIterations = config.numOfIterations
    result.targetFitness = config.targetFitness

    if config.resetPopulation:
        result.acceptNewBest = false
    else:
        result.acceptNewBest = config.acceptNewBest

    result.resetPopulation = config.resetPopulation

    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()

    # Initialize the population with random individuals:
    for i in 1..<(2 * config.populationSize):
        result.population[i] = individual.naNewRandomIndividual()

    result.naSort()

