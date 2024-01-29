# This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the server code from num_crunch.
##
## This Nim library allows you to write programs using evolutionary algorithms.
##

# Nim std imports
import std/json

from std/strformat import fmt
from std/algorithm import sort
from std/random import rand

# External imports
import num_crunch

# Local imports
import na_config
import na_individual


type
    NAPopulationServerDP* = ref object of NCServerDataProcessor
        population: seq[NAIndividual]
        targetFitness: float64
        resultFilename: string
        newFitnessCounter: uint32
        saveNewFitness: bool
        sameFitness: bool
        shareOnyBest: bool

proc naSaveData*(fileName: string, individual: NAIndividual) =
    let outFile = open(fileName, mode = fmWrite)
    # Convert individual into a JSON object:
    let converted = individual.naToJSON()
    # Convert it into a string and write it into a file:
    outFile.write($converted)
    outFile.close()

proc naLoadIntoPosition*(self: var NAPopulationServerDP, fileName: string, index: int) =
    let individual = self.population[0].naLoadData(fileName)
    self.population[index] = individual.naclone()

method ncIsFinished(self: var NAPopulationServerDP): bool =
    return self.population[0] <= self.targetFitness

method ncGetInitData(self: var NAPopulationServerDP): seq[byte] =
    @[]

method ncGetNewData(self: var NAPopulationServerDP, n: NCNodeID): seq[byte] {.gcsafe.} =
    var i = 0

    if not self.shareOnyBest:
        # Pick a random individual from the current population of best
        # individuals and return it to the node.
        # (avoid to get stuck in a local minimum)
        i = rand(self.population.high)

    return self.population[i].naToBytes()

method ncCollectData(self: var NAPopulationServerDP, n: NCNodeID, data: seq[byte]) {.gcsafe.} =
    let last = self.population.high
    var individual = self.population[0].naClone()
    individual.naFromBytes(data)
    let newFitness = individual.fitness
    let bestFitness = self.population[0].fitness

    if newFitness < self.population[last].fitness:
        if not self.sameFitness:
            # Only accept new unique individual:
            for indy in self.population:
                if newFitness == indy.fitness:
                    return

        # Overwrite (kill) the least fit individual with the new best
        # individual from the node population:
        self.population[last] = individual

        ncInfo(fmt("New individual added to the population, fitness: {newFitness}, node: {n}"))

        # Sort population by fitness:
        self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
            return cmp(a.fitness, b.fitness)

        if newFitness < bestFitness:
            ncInfo(fmt("Current best fitness: {bestFitness}"))
            ncInfo(fmt("New best fitness: {newFitness}, node: {n}"))
            ncDebug(fmt("Worst fitness: {self.population[last].fitness}"))

            if self.saveNewFitness:
                naSaveData(fmt("{self.newFitnessCounter}_{self.resultFilename}"), self.population[0])
                inc(self.newFitnessCounter)

method ncMaybeDeadNode(self: var NAPopulationServerDP, n: NCNodeID) =
    # Not needed for narwin
    discard

method ncSaveData(self: var NAPopulationServerDP) {.gcsafe.} =
    naSaveData(self.resultFilename, self.population[0])

proc naInitPopulationServerDP*(
        individual: NAIndividual,
        config: NAConfiguration
        ): NAPopulationServerDP =

    assert config.populationSize >= 5

    result = NAPopulationServerDP(population: newSeq[NAIndividual](config.populationSize))

    result.targetFitness = config.targetFitness
    result.resultFilename = config.resultFilename
    result.saveNewFitness = config.saveNewFitness
    result.sameFitness = config.sameFitness
    result.shareOnyBest = config.shareOnyBest

    let inputFileName = config.loadIndividual

    if inputFileName.len() > 0:
        ncDebug(fmt("Load individual from file: {inputFileName}"))

        let newIndividual = individual.naLoadData(inputFileName)
        result.population[0] = newIndividual.naClone()

        ncDebug(fmt("With fitness: {newIndividual.fitness}"))
    else:
        result.population[0] = individual.naClone()
        result.population[0].naCalculateFitness()

    for i in 1..<config.populationSize:
        result.population[i] = individual.naNewRandomIndividual()

    ncDebug(fmt("Target fitness: {config.targetFitness}"))
    ncDebug(fmt("Population size: {config.populationSize}"))

