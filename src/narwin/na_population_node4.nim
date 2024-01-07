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

method ncProcessData(self: var NAPopulationNodeDP4, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual1 = self.population.naClone(0)
    var tmpIndividual2 = self.population.naClone(0)
    var tmpIndividual3 = self.population.naClone(0)
    var original = self.population.naClone(0)

    var individual1Counter: uint32 = 0
    var individual2Counter: uint32 = 0
    var individual3Counter: uint32 = 0

    self.population.naResetOrAcepptBest(inputData)

    # Pick a random individual and randomize it:
    self.population.naRandomizeAny()

    block iterations:
        for i in 0..<self.population.numOfIterations:
            for j in 0..<self.population.populationSize:
                original = self.population.naClone(j)
                tmpIndividual1 = self.population.naClone(j)
                tmpIndividual2 = self.population.naClone(j)
                tmpIndividual3 = self.population.naClone(j)

                for _ in 0..<self.population.numOfMutations:
                    # Mutate it:
                    tmpIndividual1.naMutate()
                    tmpIndividual2.naMutate()
                    tmpIndividual3.naMutate()
                    # Calculate the new fitness for the mutated individuals:
                    tmpIndividual1.naCalculateFitness()
                    tmpIndividual2.naCalculateFitness()
                    tmpIndividual3.naCalculateFitness()

                    # Check if any is better than the current one:
                    # If the mutated individual is better than the original
                    # it gets overwritten (killed) by the better one:
                    if tmpIndividual1.fitness < self.population[j].fitness:
                        self.population[j] = tmpIndividual1.naClone()
                        inc(individual1Counter)
                    if tmpIndividual2.fitness < self.population[j].fitness:
                        self.population[j] = tmpIndividual2.naClone()
                        inc(individual2Counter)
                    if tmpIndividual3.fitness < self.population[j].fitness:
                        self.population[j] = tmpIndividual3.naClone()
                        inc(individual3Counter)

                    # Reset first and second individual:
                    tmpIndividual1 = self.population[j].naClone()
                    tmpIndividual2 = original.naClone()

                if self.population[j].fitness <= self.population.targetFitness:
                    ncDebug(fmt("Early exit at i: {i}"))
                    break iterations

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))
    ncDebug(fmt("Individual1 counter: {individual1Counter}"))
    ncDebug(fmt("Individual2 counter: {individual2Counter}"))
    ncDebug(fmt("Individual3 counter: {individual3Counter}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP4*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP4 =
    ncDebug("naInitPopulationNodeDP4")

    var population = naInitPopulation(individual, config)
    population.population = newSeq[NAIndividual](config.populationSize)

    result = NAPopulationNodeDP4(population: population)
    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()

    # Initialize the population with random individuals:
    for i in 1..<config.populationSize:
        result.population[i] = individual.naNewRandomIndividual()

