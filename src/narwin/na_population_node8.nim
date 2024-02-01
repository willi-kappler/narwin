## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the node code from num_crunch.
##
## This Nim library allows you to write programs using evolutionary algorithms.
##

# Nim std imports
from std/strformat import fmt
from std/random import rand

# External imports
import num_crunch

# Local imports
import na_config
import na_individual
import na_population

type
    NAPopulationNodeDP8 = ref object of NCNodeDataProcessor
        population: NAPopulation

proc checkTwoIndividuals(self: var NAPopulationNodeDP8) =
    let u = self.population.naGetRandomIndex()
    var v = self.population.naGetRandomIndex()

    while u == v:
        v = self.population.naGetRandomIndex()

    if self.population[u] < self.population[v]:
        self.population[v] = self.population[u]
    elif self.population[v] < self.population[u]:
        self.population[u] = self.population[v]

method ncProcessData(self: var NAPopulationNodeDP8, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual: NAIndividual

    self.population.naResetOrAcepptBest(inputData)

    block iterations:
        for i in 0..<self.population.numOfIterations:
            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)

                for _ in 0..<self.population.numOfMutations:
                    tmpIndividual.naMutate()
                    tmpIndividual.naCalculateFitness()

                    if tmpIndividual < self.population[j]:
                        self.population[j] = tmpIndividual
                        if tmpIndividual <= self.population.targetFitness:
                            ncDebug(fmt("Early exit at i: {i}"))
                            break iterations

            self.checkTwoIndividuals()

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP8*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP8 =
    ncInfo("naInitPopulationNodeDP8")
    ncInfo("Mutate a clone and if it's better keep it. The best one is at position 0")

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP8(population: population)

