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

type
    NAPopulationNodeDP3 = ref object of NCNodeDataProcessor
        population: seq[NAIndividual]
        populationSize: uint32
        numOfMutations: uint32
        numOfIterations: uint32
        acceptNewBest: bool
        resetPopulation: bool
        targetFitness: float64

        bestIndex: uint32
        bestFitness: float64
        worstIndex: uint32
        worstFitness: float64

proc findWorstIndividual(self: var NAPopulationNodeDP3) =
    for i in 0..<self.populationSize:
        let currentFitness = self.population[i].fitness
        if currentFitness > self.worstFitness:
            self.worstFitness = currentFitness
            self.worstIndex = i

proc findBestAndWorstIndividual(self: var NAPopulationNodeDP3) =
    for i in 0..<self.populationSize:
        let currentFitness = self.population[i].fitness
        if currentFitness < self.bestFitness:
            self.bestFitness = currentFitness
            self.bestIndex = i
        elif currentFitness > self.worstFitness:
            self.worstFitness = currentFitness
            self.worstIndex = i

method ncProcessData(self: var NAPopulationNodeDP3, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual = self.population[0].naClone()

    if self.resetPopulation:
        ncDebug("Reset the whole population to random values")
        for i in 0..<self.populationSize:
            self.population[i].naRandomize()
            self.population[i].naCalculateFitness()
    elif self.acceptNewBest:
        tmpIndividual = self.population[0].naFromBytes(inputData)
        ncDebug(fmt("Accept individual from server with fitness: {tmpIndividual.fitness}"))
        self.findWorstIndividual()
        self.population[self.worstIndex] = tmpIndividual.naClone()

    for i in 0..<self.numOfIterations:
        let j = rand(int(self.populationSize - 1))
        tmpIndividual = self.population[j].naClone()

        # And mutate it:
        for k in 0..<self.numOfMutations:
            tmpIndividual.naMutate()
        # Calculate the new fitness for the mutated individual:
        tmpIndividual.naCalculateFitness()

        # If the mutated individual is better than the original
        # it gets overwritten (killed) by the better one:
        if tmpIndividual.fitness < self.population[j].fitness:
            self.population[j] = tmpIndividual
            if tmpIndividual.fitness < self.targetFitness:
                break

    # Find the best and the worst individual at the end:
    self.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.bestFitness}, worst fitness: {self.worstFitness}"))

    return self.population[self.bestIndex].naToBytes()

proc naInitPopulationNodeDP3*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP3 =

    ncDebug(fmt("Population size: {config.populationSize}"))
    ncDebug(fmt("Number of mutations: {config.numOfMutations}"))
    ncDebug(fmt("Number of iterations: {config.numOfIterations}"))

    assert config.populationSize >= 5
    assert config.numOfMutations > 0
    assert config.numOfIterations > 0

    # Init random number generator
    randomize()

    result = NAPopulationNodeDP3(population: newSeq[NAIndividual](config.populationSize))

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
    result.bestIndex = 0
    result.bestFitness = result.population[0].fitness
    result.worstIndex = 0
    result.worstFitness = result.population[0].fitness

    # Initialize the population with random individuals:
    for i in 1..<config.populationSize:
        result.population[i] = individual.naNewRandomIndividual()

