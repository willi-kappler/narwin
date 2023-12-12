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

# Local imports
import na_individual

type
    NAPopulation* = object
        population: seq[NAIndividual]
        populationSize: uint32
        numOfMutations: uint32
        numOfIterations: uint32
        acceptNewBest: bool

proc naSort(self: var NAPopulation) =
    self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
        return cmp(a.fitness, b.fitness)

proc naInitPopulation*(
        individual: NAIndividual,
        populationSize: uint32 = 10,
        numOfMutations: uint32 = 10,
        numOfIterations: uint32 = 1000,
        acceptNewBest: bool = true
        ): NAPopulation =

    assert populationSize >= 5
    assert numOfMutations > 0
    assert numOfIterations > 0

    result.populationSize = populationSize
    result.numOfMutations = numOfMutations
    result.numOfIterations = numOfIterations
    result.acceptNewBest = acceptNewBest
    result.population = newSeq[NAIndividual](2 * populationSize)

    result.population[0] = individual.naClone()
    # Initialize the population with random individuals:
    for i in 1..<(2 * populationSize):
        result.population[i] = individual.naNewRandomIndividual()

    result.naSort()

proc naRun*(self: var NAPopulation) =
    let offset = self.populationSize
    let last = self.population.high

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


proc naGetBestIndividual*(self: NAPopulation): NAIndividual =
    self.population[0]

proc naSetNewBestIndividual*(self: var NAPopulation, individual: NAIndividual) =
    if self.acceptNewBest:
        self.population[self.populationSize - 1] = individual


