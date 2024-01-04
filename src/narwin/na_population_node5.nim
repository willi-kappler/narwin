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
    NAPopulationNodeDP5 = ref object of NCNodeDataProcessor
        population: NAPopulation
        fitnessLimit: float64
        fitnessRate: float64

method ncProcessData(self: var NAPopulationNodeDP5, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual = self.population.naClone(0)

    self.population.naResetOrAcepptBest(inputData)

    if self.population.resetPopulation:
        self.fitnessLimit = self.population[0].fitness

    # Pick a random individual and randomize it:
    self.population.naRandomizeAny()

    for i in 0..<self.population.numOfIterations:
        let j = self.population.naGetRandomIndex()
        tmpIndividual = self.population.naClone(j)

        # And mutate it:
        for k in 0..<self.population.naGetNumberOfMutations():
            tmpIndividual.naMutate()
        # Calculate the new fitness for the mutated individual:
        tmpIndividual.naCalculateFitness()

        # If the mutated individual is better than the original
        # it gets overwritten (killed) by the better one:
        if tmpIndividual.fitness < self.fitnessLimit:
            self.population[j] = tmpIndividual.naClone()
            if tmpIndividual.fitness <= self.population.targetFitness:
                ncDebug(fmt("Early exit at i: {i}"))
                break

            self.fitnessLimit = self.fitnessLimit * self.fitnessRate

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    ncDebug(fmt("Fitness factor: {self.fitnessLimit}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP5*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP5 =
    ncDebug("naInitPopulationNodeDP5")

    var population = naInitPopulation(individual, config)
    population.population = newSeq[NAIndividual](config.populationSize)

    result = NAPopulationNodeDP5(population: population)
    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()

    result.fitnessLimit = result.population[0].fitness

    assert config.fitnessRate < 1.0
    result.fitnessRate = config.fitnessRate

    # Initialize the population with random individuals:
    for i in 1..<config.populationSize:
        result.population[i] = individual.naNewRandomIndividual()

