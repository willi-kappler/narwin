## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the node code from num_crunch.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##

# Nim std imports
#import std/json

from std/strformat import fmt
from std/random import randomize, rand
from std/algorithm import sort
from std/fenv import maximumPositiveValue

# External imports
import num_crunch

# Local imports
import na_config
import na_individual

type
    NAPopulation* = object
        population*: seq[NAIndividual]
        populationSize*: uint32
        numOfIterations*: uint32
        acceptNewBest*: bool
        resetPopulation*: bool
        targetFitness*: float64

        bestIndex*: uint32
        bestFitness*: float64
        worstIndex*: uint32
        worstFitness*: float64
        operations*: seq[uint32]

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

proc naResetPopulation*(self: var NAPopulation) =
    ncDebug("Reset the whole population to random values")
    for i in 0..<self.populationSize:
        self.population[i].naRandomize()
        self.population[i].naCalculateFitness()

proc naResetOrAcepptBest*(self: var NAPopulation, inputData: seq[byte]) =
    if self.resetPopulation:
        self.naResetPopulation()
    elif self.acceptNewBest:
        self.population[0].naFromBytes(inputData)
        ncDebug(fmt("Accept individual from server with fitness: {self.population[0].fitness}"))

proc naClone*(self: NAPopulation, index: uint32): NAIndividual =
    self.population[index].naClone()

proc `[]`*(self: var NAPopulation, index: uint32): var NAIndividual =
    self.population[index]

proc `[]=`*(self: var NAPopulation, index: uint32, individual: NAIndividual) =
    self.population[index] = individual.naClone()

proc naLoadIntoPosition*(self: var NAPopulation, fileName: string, index: int) =
    let individual = self.population[0].naLoadData(fileName)
    self.population[index] = individual.naclone()

proc naInitPopulation*(individual: NAIndividual, config: NAConfiguration, initPopulation: seq[NAIndividual]): NAPopulation =
    ncDebug(fmt("Population size: {config.populationSize}"))
    ncDebug(fmt("Number of iterations: {config.numOfIterations}"))
    ncDebug(fmt("Target fitness: {config.targetFitness}"))
    ncDebug(fmt("Reset population: {config.resetPopulation}"))
    ncDebug(fmt("Accept new best from server: {config.acceptNewBest}"))

    assert config.populationSize > 1
    assert config.numOfIterations > 0

    # Init random number generator
    randomize()

    result.populationSize = config.populationSize
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
    result.operations = config.operations
    result.population = initPopulation

    let fileName = config.loadIndividual
    if fileName.len() > 0:
        ncDebug(fmt("Load individual from file: {fileName}"))

        let newIndividual = individual.naLoadData(fileName)
        result.population[0] = newIndividual

        ncDebug(fmt("With fitness: {newIndividual.fitness}"))
    else:
        result.population[0] = individual.naClone()
        result.population[0].naCalculateFitness()

    # Initialize the population with random individuals:
    for i in 1..result.population.high:
        result.population[i] = individual.naNewRandomIndividual()

    result.naSort()

