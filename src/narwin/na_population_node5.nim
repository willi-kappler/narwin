## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the node code from num_crunch.
##
## This Nim library allows you to write programs using evolutionary algorithms.
##

# Nim std imports
import std/deques

from std/strformat import fmt
from std/random import randomize, rand

# External imports
import num_crunch

# Local imports
import na_config
import na_individual

type
    NAPopulationNodeDP5 = ref object of NCNodeDataProcessor
        population: Deque[NAIndividual]
        reset: bool
        acceptNewBest: bool
        resetPopulation: bool
        populationSize: uint32
        numOfIterations: uint32
        numOfMutations: uint32
        targetFitness: float64

method ncProcessData(self: var NAPopulationNodeDP5, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual: NAIndividual

    if self.resetPopulation:
        ncDebug("Reset the whole population to a random state.")
        for i in 0..<self.populationSize:
            self.population[i].naRandomize()
            self.population[i].naCalculateFitness()
    elif self.acceptNewBest:
        tmpIndividual = self.population[0].naClone()
        tmpIndividual.naFromBytes(inputData)
        if tmpIndividual < self.population[0]:
            self.population.addFirst(tmpIndividual.naClone())
            ncDebug(fmt("Accept individual from server with fitness: {tmpIndividual.fitness}"))
            ncDebug(fmt("Previous fitness: {self.population[1].fitness}"))
            # Remove last (worst) individual:
            self.population.shrink(fromLast = 1)

    block iterations:
        for i in 0..<self.numOfIterations:
            for _ in 0..<self.populationSize:
                let index = rand(int(self.populationSize) - 1)

                tmpIndividual = self.population[index].naClone()

                for _ in 0..<self.numOfMutations:
                    tmpIndividual.naMutate()
                    tmpIndividual.naCalculateFitness()

                    # Move the best one to the first position:
                    if tmpIndividual < self.population[0]:
                        self.population.addFirst(tmpIndividual.naClone())

                        #ncDebug(fmt("pop[0]: {self.population[0].fitness}, pop[1]: {self.population[1].fitness}"))

                        if tmpIndividual <= self.targetFitness:
                            ncDebug(fmt("Early exit at i: {i}"))
                            break iterations

                        # Remove last (worst) individual:
                        self.population.shrink(fromLast = 1)

    ncDebug(fmt("Best fitness: {self.population[0].fitness}, worst fitness: {self.population[^1].fitness}"))

    return self.population[0].naToBytes()


proc naInitPopulationNodeDP5*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP5 =
    ncInfo("naInitPopulationNodeDP5")
    ncInfo("Push the best on onto the front of the queue. Remove the last (worst) one.")

    ncDebug(fmt("Population size: {config.populationSize}"))
    ncDebug(fmt("Number of iterations: {config.numOfIterations}"))
    ncDebug(fmt("Number of mutations: {config.numOfMutations}"))
    ncDebug(fmt("Target fitness: {config.targetFitness}"))
    ncDebug(fmt("Reset population: {config.resetPopulation}"))
    ncDebug(fmt("Accept new best from server: {config.acceptNewBest}"))

    randomize()

    assert config.populationSize > 1
    assert config.numOfIterations > 0
    assert config.numOfMutations > 0

    result = NAPopulationNodeDP5()

    result.populationSize = config.populationSize
    result.numOfIterations = config.numOfIterations
    result.numOfMutations = config.numOfMutations
    result.targetFitness = config.targetFitness

    if config.resetPopulation:
        result.acceptNewBest = false
    else:
        result.acceptNewBest = config.acceptNewBest

    result.resetPopulation = config.resetPopulation

    result.population = initDeque[NAIndividual](int(config.populationSize))

    for _ in 0..<config.populationSize:
        result.population.addLast(individual.naNewRandomIndividual())


