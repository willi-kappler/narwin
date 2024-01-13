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

# External imports
import num_crunch

# Local imports
import na_config
import na_individual
import na_population

type
    NAPopulationNodeDP4 = ref object of NCNodeDataProcessor
        population: NAPopulation
        population2: seq[NAIndividual]
        population3: seq[NAIndividual]

method ncProcessData(self: var NAPopulationNodeDP4, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual: NAIndividual

    self.population.naResetOrAcepptBest(inputData)

    # The second and third population get only reset once when processing the data:
    for i in 0..<self.population.populationSize:
        self.population2[i] = self.population[i].naClone()
        self.population3[i] = self.population[i].naClone()

    block iterations:
        for i in 0..<self.population.numOfIterations:
            for j in 0..<self.population.populationSize:
                # Mutate and check first population:
                tmpIndividual = self.population.naClone(j)
                tmpIndividual.naMutate(self.population.operations)
                tmpIndividual.naCalculateFitness()

                if tmpIndividual < self.population[j]:
                    self.population[j] = tmpIndividual

                # Mutate and check second population:
                tmpIndividual = self.population2[j].naClone()
                tmpIndividual.naMutate(self.population.operations)
                tmpIndividual.naCalculateFitness()

                if tmpIndividual < self.population[j]:
                    self.population[j] = tmpIndividual

                # Mutate and check third population:
                self.population3[j].naMutate(self.population.operations)
                self.population3[j].naCalculateFitness()

                if self.population3[j] < self.population[j]:
                    self.population[j] = self.population3[j]

                if self.population[j] <= self.population.targetFitness:
                    ncDebug(fmt("Early exit at i: {i}"))
                    break iterations

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP4*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP4 =
    ncDebug("naInitPopulationNodeDP4")

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP4(population: population)

    result.population2 = newSeq[NAIndividual](config.populationSize)
    result.population3 = newSeq[NAIndividual](config.populationSize)

