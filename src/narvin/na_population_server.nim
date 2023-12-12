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

method ncIsFinished(self: var NAPopulationServerDP): bool =
    let fitness = self.population[0].naGetFitness()
    return fitness <= self.targetFitness

method ncGetInitData(self: var NAPopulationServerDP[T]): seq[byte] =
    @[]

method ncGetNewData(self: var NAPopulationServerDP[T], n: NCNodeID): seq[byte] =
    # Pick a random individual from the current population of best
    # individuals and return it to the node.
    # (avoid to get stuck in a local minimum)
    let last = self.population.high
    let i = rand(last)
    return ncToBytes(self.population[i])

method ncCollectData(self: var NAPopulationServerDP[T], n: NCNodeID, data: seq[byte]) =
    let last = self.population.high
    let individual = ncFromBytes(data, T)
    let fitness = individual.naGetFitness()
    let leastFitness = self.population[last].naGetFitness()
    let bestFitness = self.population[0].naGetFitness()

    # Overwrite (kill) the least fit individual with the new best
    # individual from the node population:
    if fitness < leastFitness:
        if fitness != bestFitness:
            self.population[last] = individual

            ncInfo(fmt("New individual added to the population, fitness: {fitness}"))
            ncInfo(fmt("Current best fitness: {bestFitness}"))

            # Sort population by fitness:
            self.population.sort do (a: T, b: T) -> int:
                let fa = a.naGetFitness()
                let fb = b.naGetFitness()
                return cmp(fa, fb)

method ncMaybeDeadNode(self: var NAPopulationServerDP[T], n: NCNodeID) =
    discard

method ncSaveData(self: var NAPopulationServerDP[T]) =
    let outFile = open(self.resultFilename, mode = fmWrite)
    # Get the optimal solution:
    # And turn it into a JSON object:
    let converted = %self.population[0]
    # Write it out into a file:
    outFile.write($converted)
    outFile.close()

proc naInitPopulationServerDP*[T](
        individual: T,
        resultFilename: string,
        targetFitness: float64 = 0.0,
        populationSize: uint32 = 10
        ): NAPopulationServerDP[T] =

    assert populationSize >= 5

    result = NAPopulationServerDP[T](population: newSeq[T](populationSize))

    result.targetFitness = targetFitness
    result.resultFilename = resultFilename

    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()
    for i in 1..<populationSize:
        result.population[i] = individual.naNewRandomIndividual()

