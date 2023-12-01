## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module implements a population of a specific amount of individuals.
##
## This nim library allows you to write programs using evolutionary algorithms.
##

# Local imports
import na_individual

proc naDefaultCmp(x, y: NAIndividual): int =
    cmp(x.fitness, y.fitness)

type
    NAPopulation* = object
        populationSize: uint32
        population: seq[NAIndividual]
        numOfMutations: uint32
        numOfIterations: uint32
        cmpProc: proc (x, y: NAIndividual): int {.closure.}

proc naInitPopulation(individual: NAIndividual): NAPopulation =
    # TODO: implement it
    var population = newSeq[NAIndividual](self.populationSize)

    # Initialize the population with random individuals:
    for i in 0..<self.populationSize:
        var newIndividual = individual.naClone()
        newIndividual.naMutate()
        population[i] = newIndividual


    discard

proc naRun(var self: NAPopulation) =
    var oldPopulation = newSeq[NAPopulation](self.populationSize)

    for i in 0..<self.numOfIterations:
        # Save all individuals of the current population.
        # Those will not be mutated.
        for j in 0..<self.populationSize:
            oldPopulation[j] = self.population[j].naClone()

        # Now mutate all individuals of the current population:
        for j in 0..<self.populationSize:
            for k in 0..<self.numOfMutations:
                self.population[j].naMutate()

        # Merge original saved and new mutated population:
        for j in 0..<self.populationSize:
            self.population.add(oldPopulation[j])

        # Sort merged population by fitness:
        sort(self.population, self.cmpProc)

        # Delete all individuals that have a bad fitness:
        # (Those will not survice and die...)
        self.population.delete(self.populationSize..)



