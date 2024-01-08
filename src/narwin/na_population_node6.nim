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
    NAPopulationNodeDP6 = ref object of NCNodeDataProcessor
        population: NAPopulation
        bestFitness: float64

method ncProcessData(self: var NAPopulationNodeDP6, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual = self.population.naClone(0)
    let populationSize = float64(self.population.populationSize)
    let limitFactor = rand(4.0) + 1.0

    self.population.naResetOrAcepptBest(inputData)

    block iterations:
        for i in 0..<self.population.numOfIterations:
            let numberOfMutations = self.population.naGetNumberOfMutations()

            for j in 0..<self.population.populationSize:
                let fitnessLimit = self.bestFitness * (1.0 + (float64(j) * limitFactor / populationSize))
                tmpIndividual = self.population.naClone(j)

                for _ in 0..<numberOfMutations:
                    tmpIndividual.naMutate()

                tmpIndividual.naCalculateFitness()

                if tmpIndividual.fitness < fitnessLimit:
                    self.population[j] = tmpIndividual.naClone()
                elif tmpIndividual.fitness < self.population[j].fitness:
                    self.population[j] = tmpIndividual.naClone()

                if tmpIndividual.fitness <= self.population.targetFitness:
                    ncDebug(fmt("Early exit at i: {i}"))
                    break iterations

                if tmpIndividual.fitness < self.bestFitness:
                    self.bestFitness = tmpIndividual.fitness
                    if j > 0:
                        self.population[j] = tmpIndividual.naClone()

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[self.population.bestIndex].naToBytes()

proc naInitPopulationNodeDP6*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP6 =
    ncDebug("naInitPopulationNodeDP6")

    var population = naInitPopulation(individual, config)
    population.population = newSeq[NAIndividual](config.populationSize)

    result = NAPopulationNodeDP6(population: population)
    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()
    result.bestFitness = result.population[0].fitness

    # Initialize the population with random individuals:
    for i in 1..<config.populationSize:
        result.population[i] = individual.naNewRandomIndividual()

