## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutionary algorithms.
##
## This module contains the implementation of the node code from num_crunch.
## The NAPopulation structure is used in the various population node implementations:
## NAPopulationNodeDP1, NAPopulationNodeDP2, ...
##

# Nim std imports
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
        ## This structure contains common data that is shared between the dataprocessing populations.
        population*: seq[NAIndividual]
        populationSize*: uint32
        numOfIterations*: uint32
        numOfMutations*: uint32
        acceptNewBest*: bool
        resetPopulation*: bool
        targetFitness*: float64

        bestIndex*: uint32
        bestFitness*: float64
        worstIndex*: uint32
        worstFitness*: float64

proc naGetRandomIndex*(self: NAPopulation): uint32 =
    ## Returns a valid random index for the population.
    let last = int(self.populationSize - 1)
    return uint32(rand(last))

proc naFindWorstIndividual*(self: var NAPopulation) =
    ## Find the individual with the worst fitness and stores the index and the fitness.
    self.worstFitness = self.population[0].fitness
    self.worstIndex = 0

    for i in 1..<self.populationSize:
        let currentFitness = self.population[i].fitness
        if currentFitness > self.worstFitness:
            self.worstFitness = currentFitness
            self.worstIndex = i

proc naFindBestAndWorstIndividual*(self: var NAPopulation) =
    ## Find the individual with the best fitness and find the individual with the worst fitness.
    ## Stores both indices and fitnesses.
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
    ## Sort the whole population by fitness.
    self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
        return cmp(a.fitness, b.fitness)

proc naResetPopulation*(self: var NAPopulation) =
    ## Resets the whole population by totally randomizing all individuals.
    for i in 0..<self.populationSize:
        self.population[i].naRandomize()
        self.population[i].naCalculateFitness()

proc naResetOrAcepptBest*(self: var NAPopulation, inputData: seq[byte]) =
    ## Ether resets the whole population or accepts the new best individual from the server.
    ## The new best individual is stored at index 0.
    if self.resetPopulation:
        ncDebug("Reset the whole population to random values")
        self.naResetPopulation()
    elif self.acceptNewBest:
        self.population[0].naFromBytes(inputData)
        ncDebug(fmt("Accept individual from server with fitness: {self.population[0].fitness}"))

proc naReplaceWorst*(self: var NAPopulation, inputData: seq[byte]) =
    ## Finds the worst individual and replaceses it with the given one.
    self.naFindWorstIndividual()
    self.population[self.worstIndex].naFromBytes(inputData)
    ncDebug(fmt("Accept individual from server with fitness: {self.population[self.worstIndex].fitness}"))

    self.naFindWorstIndividual()
    self.population[self.worstIndex].naRandomize()
    self.population[self.worstIndex].naCalculateFitness()

proc naClone*(self: NAPopulation, index: uint32): NAIndividual =
    ## Clones the individual at the given index.
    self.population[index].naClone()

proc `[]`*(self: var NAPopulation, index: uint32): var NAIndividual =
    ## Mutable index into the population.
    self.population[index]

proc `[]`*(self: NAPopulation, index: uint32): NAIndividual =
    ## Non-mutable index into the population.
    self.population[index]

proc `[]=`*(self: var NAPopulation, index: uint32, individual: NAIndividual) =
    ## Replace the individual at the given index with the given individual.
    self.population[index] = individual.naClone()

proc naLoadIntoPosition*(self: var NAPopulation, fileName: string, index: int) =
    ## Loads an individual from the given file and replaceses the individual at the given index with it.
    let individual = self.population[0].naLoadData(fileName)
    self.population[index] = individual.naclone()

proc naInitPopulation*(individual: NAIndividual, config: NAConfiguration, initPopulation: seq[NAIndividual]): NAPopulation =
    ## Constructor for a new population with the given config.
    ncDebug(fmt("Population size: {config.populationSize}"))
    ncDebug(fmt("Number of iterations: {config.numOfIterations}"))
    ncDebug(fmt("Number of mutations: {config.numOfMutations}"))
    ncDebug(fmt("Target fitness: {config.targetFitness}"))
    ncDebug(fmt("Reset population: {config.resetPopulation}"))
    ncDebug(fmt("Accept new best from server: {config.acceptNewBest}"))

    assert config.populationSize > 1
    assert config.numOfIterations > 0
    assert config.numOfMutations > 0

    # Init random number generator
    randomize()

    result.populationSize = config.populationSize
    result.numOfIterations = config.numOfIterations
    result.numOfMutations = config.numOfMutations
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

