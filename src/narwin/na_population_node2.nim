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
from std/algorithm import sort

# External imports
import num_crunch

# Local imports
import na_config
import na_individual
import na_population

type
    NAPopulationNodeDP2 = ref object of NCNodeDataProcessor
        population: NAPopulation

method ncProcessData(self: var NAPopulationNodeDP2, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    self.population.naResetOrAcepptBest(inputData)

    let last = self.population.populationSize
    let offset1 = last
    let offset2 = offset1 + last
    let offset3 = offset2 + last
    let offset4 = offset3 + last

    for i in 0..<self.population.numOfIterations:
        for j in 0..<last:
            self.population[j + offset1] = self.population[j]
            self.population[j + offset1].naMutate()
            self.population[j + offset1].naCalculateFitness()

            self.population[j + offset2] = self.population[j]
            self.population[j + offset2].naMutate()
            self.population[j + offset2].naMutate()
            self.population[j + offset2].naCalculateFitness()

            self.population[j + offset3] = self.population[j]
            self.population[j + offset3].naMutate()
            self.population[j + offset3].naMutate()
            self.population[j + offset3].naMutate()
            self.population[j + offset3].naCalculateFitness()

            self.population[j + offset4] = self.population[j]
            self.population[j + offset4].naMutate()
            self.population[j + offset4].naMutate()
            self.population[j + offset4].naMutate()
            self.population[j + offset4].naMutate()
            self.population[j + offset4].naCalculateFitness()

        self.population.naSort()

        if self.population[0] <= self.population.targetFitness:
            ncDebug(fmt("Early exit at i: {i}"))
            break

    ncDebug(fmt("Best fitness: {self.population[0].fitness}, worst fitness: {self.population[last - 1].fitness}"))

    return self.population[0].naToBytes()

proc naInitPopulationNodeDP2*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP2 =
    ncInfo("naInitPopulationNodeDP2")
    ncInfo("The best individual is at index 0, mutate multiple times and sort population by fitness.")
    ncInfo("The worst individuals are overwritten.")

    let initPopulation = newSeq[NAIndividual](5 * config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP2(population: population)

