# This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the server code from num_crunch.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##

# Nim std imports
#import std/options
import std/json

from std/strformat import fmt
from std/algorithm import sort
from std/random import rand

# External imports
import num_crunch

type
    NAPopulationServerDP*[T] = ref object of NCServerDataProcessor
        population: seq[T]
        targetFitness: float64
        resultFilename: string
        newFitnessCounter: uint32
        saveNewFitness: bool

proc naSaveData(fileName: string, individual: NAIndividual) =
    let outFile = open(fileName, mode = fmWrite)
    # Convert individual into a JSON object:
    let converted = individual.naToJSON()
    # Convert it into a string and write it into a file:
    outFile.write($converted)
    outFile.close()

method ncIsFinished(self: var NAPopulationServerDP): bool =
    let fitness = self.population[0].naGetFitness()
    return fitness <= self.targetFitness

method ncGetInitData(self: var NAPopulationServerDP[T]): seq[byte] =
    @[]

method ncGetNewData(self: var NAPopulationServerDP, n: NCNodeID): seq[byte] {.gcsafe.} =
    # Pick a random individual from the current population of best
    # individuals and return it to the node.
    # (avoid to get stuck in a local minimum)
    let last = self.population.high
    let i = rand(last)
    return ncToBytes(self.population[i])

method ncCollectData(self: var NAPopulationServerDP, n: NCNodeID, data: seq[byte]) {.gcsafe.} =
    let last = self.population.high
    let individual = self.population[0].naFromBytes(data)
    let newFitness = individual.fitness
    let bestFitness = self.population[0].fitness

    if newFitness < self.population[last].fitness:
        for indy in self.population:
            # Only accept new unique individual
            if newFitness == indy.fitness:
                return

        # Overwrite (kill) the least fit individual with the new best
        # individual from the node population:
        self.population[last] = individual

        ncInfo(fmt("New individual added to the population, fitness: {newFitness}"))

        # Sort population by fitness:
        self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
            return cmp(a.fitness, b.fitness)

        if newFitness < bestFitness:
            ncInfo(fmt("Current best fitness: {bestFitness}"))
            ncInfo(fmt("New best fitness: {newFitness}"))

            if self.saveNewFitness:
                naSaveData(fmt("{self.newFitnessCounter}_{self.resultFilename}"), self.population[0])

            inc(self.newFitnessCounter)

method ncMaybeDeadNode(self: var NAPopulationServerDP, n: NCNodeID) =
    # Not needed for narvin
    discard

method ncSaveData(self: var NAPopulationServerDP) {.gcsafe.} =
    naSaveData(self.resultFilename, self.population[0])

proc naInitPopulationServerDP*[T](
        individual: T,
        resultFilename: string,
        targetFitness: float64 = 0.0,
        populationSize: uint32 = 10,
        saveNewFitness: bool = true
        ): NAPopulationServerDP =

    assert populationSize >= 5

    result = NAPopulationServerDP[T](population: newSeq[T](populationSize))

    result.targetFitness = targetFitness
    result.resultFilename = resultFilename
    result.saveNewFitness = saveNewFitness

    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()
    for i in 1..<populationSize:
        result.population[i] = individual.naNewRandomIndividual()

