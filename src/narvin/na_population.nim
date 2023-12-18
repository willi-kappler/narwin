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
from fenv import maximumPositiveValue


# External imports
import num_crunch

# Local imports
import na_config
import na_individual

type
    NAPopulation* = object
        population*: seq[NAIndividual]
        populationSize*: uint32
        numOfMutations*: uint32
        numOfIterations*: uint32
        acceptNewBest*: bool
        resetPopulation*: bool
        targetFitness*: float64

        bestIndex*: uint32
        bestFitness*: float64
        worstIndex*: uint32
        worstFitness*: float64

proc findWorstIndividual*(self: var NAPopulation) =
    self.worstFitness = self.population[0].fitness
    self.worstIndex = 0

    for i in 1..<self.populationSize:
        let currentFitness = self.population[i].fitness
        if currentFitness > self.worstFitness:
            self.worstFitness = currentFitness
            self.worstIndex = i

proc findBestAndWorstIndividual*(self: var NAPopulation) =
    self.bestFitness = self.population[0].fitness
    self.bestIndex = 0
    self.worstFitness = self.population[0].fitness
    self.worstIndex = 0

    for i in 1..<self.populationSize:
        let currentFitness = self.population[i].fitness
        if currentFitness < self.bestFitness:
            self.bestFitness = currentFitness
            self.bestIndex = i
        elif currentFitness > self.worstFitness:
            self.worstFitness = currentFitness
            self.worstIndex = i

proc naSort*(self: var NAPopulation) =
    self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
        return cmp(a.fitness, b.fitness)

proc naInitPopulation*(individual: NAIndividual, config: NAConfiguration): NAPopulation =

    ncDebug(fmt("Population size: {config.populationSize}"))
    ncDebug(fmt("Number of mutations: {config.numOfMutations}"))
    ncDebug(fmt("Number of iterations: {config.numOfIterations}"))

    assert config.populationSize >= 5
    assert config.numOfMutations > 0
    assert config.numOfIterations > 0

    # Init random number generator
    randomize()

    result.populationSize = config.populationSize
    result.numOfMutations = config.numOfMutations
    result.numOfIterations = config.numOfIterations
    result.targetFitness = config.targetFitness

    if config.resetPopulation:
        result.acceptNewBest = false
    else:
        result.acceptNewBest = config.acceptNewBest

    result.resetPopulation = config.resetPopulation

    result.bestIndex = 0
    result.bestFitness = maximumPositiveValue(float64)
    result.worstIndex = 0
    result.worstFitness = 0.0

