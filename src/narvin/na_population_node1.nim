## This module is part of narvin: https://github.com/willi-kappler/narvin
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
    NAPopulationNodeDP1 = ref object of NCNodeDataProcessor
        population: NAPopulation

method ncProcessData(self: var NAPopulationNodeDP1, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    let offset = self.population.populationSize

    if self.population.resetPopulation:
        ncDebug("Reset the whole population to random values")
        for i in 0..<self.population.populationSize:
            self.population.population[i].naRandomize()
            self.population.population[i].naCalculateFitness()
    elif self.population.acceptNewBest:
        let tmpIndividual = self.population.population[0].naFromBytes(inputData)
        ncDebug(fmt("Accept individual from server with fitness: {tmpIndividual.fitness}"))
        self.population.population[offset - 2] = tmpIndividual.naClone()

    for i in 0..<self.population.numOfIterations:
        for j in 0..<self.population.populationSize:
            # Save all individuals of the current population.
            # Those will not be mutated.
            # This overwrites all the individuals above self.populationSize.
            # They will not survive and die.
            self.population.population[j + offset] = self.population.population[j].naClone()

            # Now mutate all individuals of the current active population:
            for k in 0..<self.population.numOfMutations:
                self.population.population[j].naMutate()
            # Calculate the new fitness for the mutated individual:
            self.population.population[j].naCalculateFitness()

        # The last individual will be totally random.
        # This helps a bit to escape a local minimum.
        self.population.population[offset - 1].naRandomize()
        self.population.population[offset - 1].naCalculateFitness()

        # Sort the whole population (new and old) by fitness:
        # All individuals that are not fit enough will be moved to position
        # above self.populationSize and will be overwritten in the next iteration.
        self.population.naSort()

        if self.population.population[0].fitness <= self.population.targetFitness:
            ncDebug(fmt("Early exit at i: {i}"))
            break

    let fitness = self.population.population[0].fitness
    ncDebug(fmt("Best fitness in this run: {fitness}"))

    return self.population.population[0].naToBytes()

proc naInitPopulationNodeDP1*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP1 =
    var population = naInitPopulation(individual, config)
    population.population = newSeq[NAIndividual](2 * config.populationSize)

    result = NAPopulationNodeDP1(population: population)
    result.population.population[0] = individual.naClone()
    result.population.population[0].naCalculateFitness()

    # Initialize the population with random individuals:
    for i in 1..<(2 * config.populationSize):
        result.population.population[i] = individual.naNewRandomIndividual()

    result.population.naSort()

