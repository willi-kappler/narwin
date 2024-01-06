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
        fixedMutation*: bool

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

proc naGetRandomIndex*(self: NAPopulation): uint32 =
    uint32(rand(int(self.populationSize - 1)))

proc naRandomizeSpecific*(self: var NAPopulation, index: uint32) =
    self.population[index].naRandomize()
    self.population[index].naCalculateFitness()

proc naRandomizeAny*(self: var NAPopulation) =
    let index = self.naGetRandomIndex()
    self.naRandomizeSpecific(index)

proc naResetPopulation*(self: var NAPopulation) =
    ncDebug("Reset the whole population to random values")
    for i in 0..<self.populationSize:
        self.population[i].naRandomize()
        self.population[i].naCalculateFitness()

proc naResetOrAcepptBest*(self: var NAPopulation, inputData: seq[byte]) =
    if self.resetPopulation:
        self.naResetPopulation()
    elif self.acceptNewBest:
        let index = self.naGetRandomIndex()
        self.population[index].naFromBytes(inputData)
        ncDebug(fmt("Accept individual from server with fitness: {self.population[index].fitness}"))

proc naGetNumberOfMutations*(self: NAPopulation): uint32 =
    if self.fixedMutation:
        return self.numOfMutations
    else:
        return uint32(rand(int(self.numOfMutations) - 1) + 1)

proc naClone*(self: NAPopulation, index: uint32): NAIndividual =
    self.population[index].naClone()

proc `[]`*(self: var NAPopulation, index: uint32): var NAIndividual =
    self.population[index]

proc `[]=`*(self: var NAPopulation, index: uint32, individual: NAIndividual) =
    self.population[index] = individual.naClone()

proc naInitPopulation*(individual: NAIndividual, config: NAConfiguration): NAPopulation =
    ncDebug(fmt("Population size: {config.populationSize}"))
    ncDebug(fmt("Number of mutations: {config.numOfMutations}"))
    ncDebug(fmt("Number of iterations: {config.numOfIterations}"))
    ncDebug(fmt("Target fitness: {config.targetFitness}"))
    ncDebug(fmt("Reset population: {config.resetPopulation}"))
    ncDebug(fmt("Accept new best from server: {config.acceptNewBest}"))
    ncDebug(fmt("Fixed mutation: {config.fixedMutation}"))
    ncDebug(fmt("Fitness rate: {config.fitnessRate}"))
    ncDebug(fmt("Fitness limit top: {config.limitTop}"))
    ncDebug(fmt("Fitness limit bottom: {config.limitBottom}"))

    assert config.populationSize >= 5
    assert config.numOfMutations > 0
    assert config.numOfIterations > 0

    # Init random number generator
    randomize()

    result.populationSize = config.populationSize
    result.numOfMutations = config.numOfMutations
    result.numOfIterations = config.numOfIterations
    result.targetFitness = config.targetFitness
    result.fixedMutation = config.fixedMutation

    if config.resetPopulation:
        result.acceptNewBest = false
    else:
        result.acceptNewBest = config.acceptNewBest

    result.resetPopulation = config.resetPopulation

    result.bestIndex = 0
    result.bestFitness = maximumPositiveValue(float64)
    result.worstIndex = 0
    result.worstFitness = 0.0

