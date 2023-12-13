## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module implements a population of a specific amount of individuals.
##
## This Nim library allows you to write programs using evolutionary algorithms.
##

# Nim std imports
from std/algorithm import sort
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import na_individual

type
    NAPopulation* = ref object of RootObj
        population: seq[NAIndividual]
        populationSize: uint32
        numOfMutations: uint32
        numOfIterations: uint32
        acceptNewBest: bool
        resetPopulation: bool

proc naSort(self: var NAPopulation) =
    self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
        return cmp(a.fitness, b.fitness)

proc naInitPopulation*(
        individual: NAIndividual,
        populationSize: uint32 = 10,
        numOfMutations: uint32 = 10,
        numOfIterations: uint32 = 1000,
        acceptNewBest: bool = true,
        resetPopulation: bool = false
        ): NAPopulation =

    assert populationSize >= 5
    assert numOfMutations > 0
    assert numOfIterations > 0

    result = NAPopulation(population: newSeq[NAIndividual](2 * populationSize))

    result.populationSize = populationSize
    result.numOfMutations = numOfMutations
    result.numOfIterations = numOfIterations
    result.acceptNewBest = acceptNewBest
    result.resetPopulation = resetPopulation

    result.population[0] = individual.naClone()
    result.population[0].naCalculateFitness()
    # Initialize the population with random individuals:
    for i in 1..<(2 * populationSize):
        result.population[i] = individual.naNewRandomIndividual()

    result.naSort()

proc naRun*(self: var NAPopulation) =
    let offset = self.populationSize
    let last = self.population.high

    if self.resetPopulation:
        ncDebug("Reset the whole population to random values")
        for i in 0..<self.populationSize:
            self.population[i].naRandomize()

    for i in 0..<self.numOfIterations:
        # Save all individuals of the current population.
        # Those will not be mutated.
        # This overwrites all the individuals above self.populationSize.
        # They will not survive and die.
        for j in 0..<self.populationSize:
            self.population[j + offset] = self.population[j].naClone()

        # Now mutate all individuals of the current active population:
        for j in 0..<self.populationSize:
            for k in 0..<self.numOfMutations:
                self.population[j].naMutate()
            # Calculate the new fitness for the mutated individual:
            self.population[j].naCalculateFitness()

        # The last individual will be totally random.
        # This helps a bit to escape a local mnimum.
        self.population[last].naRandomize()
        self.population[last].naCalculateFitness()

        # Sort the whole population (new and old) by fitness:
        # All individuals that are not fit enough will be moved to position
        # above self.populationSize and will be overwritten in the next iteration.
        self.naSort()

    let fitness = self.population[0].fitness
    ncDebug(fmt("Best fitness in this run: {fitness}"))


proc naGetBestIndividual*(self: NAPopulation): NAIndividual =
    self.population[0]

proc naGetBestIndividualBytes*(self: NAPopulation): seq[byte] =
    self.naGetBestIndividual().naToBytes()

proc naSetNewBestIndividual*(self: var NAPopulation, individual: NAIndividual) =
    if self.acceptNewBest:
        self.population[self.populationSize - 1] = individual

        let fitness = individual.fitness
        ncDebug(fmt("Accept individual from server with fitness: {fitness}"))

proc naSetNewBestIndividualBytes*(self: var NAPopulation, inputData: seq[byte]) =
    let individual = self.population[0].naFromBytes(inputData)
    self.naSetNewBestIndividual(individual)

