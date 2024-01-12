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
from std/random import rand

# External imports
import num_crunch

# Local imports
import na_config
import na_individual
import na_population

type
    NAPopulationNodeDP4 = ref object of NCNodeDataProcessor
        population: NAPopulation
        bestFitness: float64
        limitCounterEnd: uint32

method ncProcessData(self: var NAPopulationNodeDP4, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual1 = self.population.naClone(0)
    var tmpIndividual2 = self.population.naClone(0)
    var tmpIndividual3 = self.population.naClone(0)
    var original = self.population.naClone(0)

    var limitActive = false

    var limitCounter: uint32 = 0
    let limitFactor = rand(4.0) + 1.0
    var limitFitness: float64 = self.bestFitness * limitFactor

    ncDebug(fmt("Limit factor: {limitFactor}"))

    self.population.naResetOrAcepptBest(inputData)

    # Pick a random individual and randomize it:
    self.population.naRandomizeAny()

    block iterations:
        for i in 0..<self.population.numOfIterations:
            if limitActive:
                for j in 0..<self.population.populationSize:
                    tmpIndividual1 = self.population.naClone(j)

                    for _ in 0..<self.population.numOfMutations:
                        tmpIndividual1.naMutate(self.population.operations)

                    tmpIndividual1.naCalculateFitness()

                    if tmpIndividual1 < limitFitness:
                        self.population[j] = tmpIndividual1
            else:
                for j in 0..<self.population.populationSize:
                    original = self.population.naClone(j)
                    tmpIndividual1 = self.population.naClone(j)
                    tmpIndividual2 = self.population.naClone(j)
                    tmpIndividual3 = self.population.naClone(j)

                    for _ in 0..<self.population.numOfMutations:
                        # Mutate all three:
                        tmpIndividual1.naMutate(self.population.operations)
                        tmpIndividual2.naMutate(self.population.operations)
                        tmpIndividual3.naMutate(self.population.operations)

                        # Calculate the new fitness for the mutated individuals:
                        tmpIndividual1.naCalculateFitness()
                        tmpIndividual2.naCalculateFitness()
                        tmpIndividual3.naCalculateFitness()

                        # Check if any is better than the current one:
                        # If the mutated individual is better than the original
                        # it gets overwritten (killed) by the better one:
                        if tmpIndividual1 < self.population[j]:
                            self.population[j] = tmpIndividual1
                        if tmpIndividual2 < self.population[j]:
                            self.population[j] = tmpIndividual2
                        if tmpIndividual3 < self.population[j]:
                            self.population[j] = tmpIndividual3

                        # Reset first and second individual:
                        if self.population[j] < tmpIndividual1:
                            tmpIndividual1 = self.population[j].naClone()
                        tmpIndividual2 = original.naClone()

                    if self.population[j] <= self.population.targetFitness:
                        ncDebug(fmt("Early exit at i: {i}"))
                        break iterations

                    if self.population[j] < self.bestFitness:
                        self.bestFitness = self.population[j].fitness

            inc(limitCounter)

            if limitCounter > self.limitCounterEnd:
                limitCounter = 0
                limitFitness = self.bestFitness * limitFactor
                limitActive = not limitActive

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Limit fitness: {limitFitness}"))
    ncDebug(fmt("Bist fitness 2: {self.bestFitness}"))
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP4*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP4 =
    ncDebug("naInitPopulationNodeDP4")

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP4(population: population)

    result.limitCounterEnd = result.population.numOfIterations div 5
    if result.limitCounterEnd < 5:
        result.limitCounterEnd = 5

    result.bestFitness = result.population[0].fitness

