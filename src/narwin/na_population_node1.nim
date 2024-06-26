## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutionary algorithms.
##
## This module contains the implementation of the node code from num_crunch.
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
        ## Strategy:
        ## 1. duplicate the whole population.
        ## 2. mutate the original populaton (not the duplicates).
        ## 3. sort the new population by fitness (original and duplicates).
        ## 4. the second half of the bad population will be overwritten.
        population: NAPopulation

method ncProcessData(self: var NAPopulationNodeDP1, inputData: seq[byte]): seq[byte] =
    ## This function is called when the client receives the message "newData" from the server.
    ncDebug("ncProcessData()", 2)

    let offset = self.population.populationSize

    self.population.naResetOrAcepptBest(inputData)

    for i in 0..<self.population.numOfIterations:
        for j in 0..<self.population.populationSize:
            # Save all individuals of the current population.
            # Those will not be mutated.
            # This overwrites all the individuals above self.populationSize.
            # They will not survive and die.
            self.population[j + offset] = self.population[j]

            # Now mutate all individuals of the current active population:
            self.population[j].naMutate()
            # Calculate the new fitness for the mutated individual:
            self.population[j].naCalculateFitness()

        # Sort the whole population (new and old) by fitness:
        # All individuals that are not fit enough will be moved to position
        # above self.populationSize and will be overwritten in the next iteration.
        self.population.naSort()

        if self.population[0] <= self.population.targetFitness:
            ncDebug(fmt("Early exit at i: {i}"))
            break

    ncDebug(fmt("Best fitness: {self.population[0].fitness}, worst fitness: {self.population[offset - 2].fitness}"))

    return self.population[0].naToBytes()

proc naInitPopulationNodeDP1*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP1 =
    ## This is the constructor / initializer for the population node of kind 1.
    ncInfo("naInitPopulationNodeDP1")
    ncInfo("Clone population and mutate individuals in place. Then sort population by fitness.")
    ncInfo("The worst individuals are overwritten.")

    let initPopulation = newSeq[NAIndividual](2 * config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP1(population: population)

