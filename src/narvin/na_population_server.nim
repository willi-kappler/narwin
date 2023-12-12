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

# Local imports
import na_individual

type
    NAPopulationServerDP* = ref object of NCServerDataProcessor
        population: seq[NAIndividual]
        targetFitness: float64
        resultFilename: string

method ncIsFinished(self: var NAPopulationServerDP): bool =
    return self.population[0].fitness <= self.targetFitness

method ncGetInitData(self: var NAPopulationServerDP): seq[byte] =
    @[]

method ncGetNewData(self: var NAPopulationServerDP, n: NCNodeID): seq[byte] =
    # Pick a random individual from the current population of best
    # individuals and return it to the node.
    # (avoid to get stuck in a local minimum)
    let last = self.population.high
    let i = rand(last)
    return self.population[i].naToBytes()

method ncCollectData(self: var NAPopulationServerDP, n: NCNodeID, data: seq[byte]) =
    let last = self.population.high
    let individual = self.population[0].naFromBytes(data)
    let fitness = individual.fitness

    # Overwrite (kill) the least fit individual with the new best
    # individual from the node population:
    if fitness < self.population[last].fitness:
        if fitness != self.population[0].fitness:
            self.population[last] = individual

            ncInfo(fmt("New individual added to the population, fitness: {fitness}"))
            ncInfo(fmt("Current best fitness: {self.population[0].fitness}"))

            # Sort population by fitness:
            self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
                return cmp(a.fitness, b.fitness)

method ncMaybeDeadNode(self: var NAPopulationServerDP, n: NCNodeID) =
    discard

method ncSaveData(self: var NAPopulationServerDP) =
    let outFile = open(self.resultFilename, mode = fmWrite)
    # Get the optimal solution:
    # And turn it into a JSON object:
    let converted = self.population[0].naToJSON()
    # Write it out into a file:
    outFile.write($converted)
    outFile.close()

proc naInitPopulationServerDP*(
        individual: NAIndividual,
        resultFilename: string,
        targetFitness: float64 = 0.0,
        populationSize: uint32 = 10
        ): NAPopulationServerDP =

    assert populationSize >= 5

    result = NAPopulationServerDP(population: newSeq[NAIndividual](populationSize))

    result.targetFitness = targetFitness
    result.resultFilename = resultFilename

    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()
    for i in 1..<populationSize:
        result.population[i] = individual.naNewRandomIndividual()

