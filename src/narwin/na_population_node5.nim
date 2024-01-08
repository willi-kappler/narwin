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
        limitTop: float64
        limitBottom: float64

method ncProcessData(self: var NAPopulationNodeDP5, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual = self.population.naClone(0)
    var bestIndividual = self.population.naClone(0)
    var limitCounter: uint32 = 0

    self.population.naResetOrAcepptBest(inputData)

    if self.population.resetPopulation:
        self.fitnessLimit = self.population[0].fitness

    # Pick a random individual and randomize it:
    self.population.naRandomizeAny()

    block iterations:
        for i in 0..<self.population.numOfIterations:
            let numberOfMutations = self.population.naGetNumberOfMutations()

            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)

                # And mutate it:
                for _ in 0..<numberOfMutations:
                    tmpIndividual.naMutate()
                # Calculate the new fitness for the mutated individual:
                tmpIndividual.naCalculateFitness()

                if tmpIndividual.fitness < self.fitnessLimit:
                    self.population[j] = tmpIndividual.naClone()
                elif tmpIndividual.fitness < self.population[j].fitness:
                    self.population[j] = tmpIndividual.naClone()

                if tmpIndividual.fitness < bestIndividual.fitness:
                    bestIndividual = tmpIndividual.naClone()
                    if tmpIndividual.fitness <= self.population.targetFitness:
                        ncDebug(fmt("Early exit at i: {i}"))
                        break iterations

            self.fitnessLimit = self.fitnessLimit - self.fitnessRate

            if (self.fitnessLimit < self.limitBottom):
                self.fitnessLimit = self.limitTop
                inc(limitCounter)

    ncDebug(fmt("Limit counter: {limitCounter}"))
    ncDebug(fmt("Best fitness: {bestIndividual.fitness}"))
    ncDebug(fmt("Fitness limit: {self.fitnessLimit}"))

    return bestIndividual.naToBytes()

proc naInitPopulationNodeDP5*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP5 =
    ncDebug("naInitPopulationNodeDP5")

    var population = naInitPopulation(individual, config)
    population.population = newSeq[NAIndividual](config.populationSize)

    result = NAPopulationNodeDP5(population: population)
    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()

    result.fitnessLimit = result.population[0].fitness

    assert config.fitnessRate > 0.0
    result.fitnessRate = config.fitnessRate

    assert (config.limitTop > config.limitBottom) and (config.limitBottom > 0.0)
    result.limitTop = config.limitTop
    result.limitBottom = config.limitBottom

    # Initialize the population with random individuals:
    for i in 1..<config.populationSize:
        result.population[i] = individual.naNewRandomIndividual()

