## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the node code from num_crunch.
##
## This Nim library allows you to write programs using evolutionary algorithms.
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
    NAPopulationNodeDP7 = ref object of NCNodeDataProcessor
        population: NAPopulation
        limitStart: float64
        limitEnd: float64
        limitIncrement: float64

method ncProcessData(self: var NAPopulationNodeDP7, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual: NAIndividual

    self.population.naResetOrAcepptBest(inputData)

    var fitnessLimit: float64

    block iterations:
        for i in 0..<self.population.numOfIterations:
            fitnessLimit = self.limitStart

            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)

                for _ in 0..<self.population.numOfMutations:
                    tmpIndividual.naMutate()
                    tmpIndividual.naCalculateFitness()

                    if tmpIndividual < fitnessLimit:
                        self.population[j] = tmpIndividual
                    elif tmpIndividual < self.population[j]:
                        self.population[j] = tmpIndividual

                    if tmpIndividual < self.population[0]:
                        self.population[0] = tmpIndividual

                        if tmpIndividual <= self.population.targetFitness:
                            ncDebug(fmt("Early exit at i: {i}, j: {j}"))
                            break iterations

                fitnessLimit = fitnessLimit + self.limitIncrement
                if fitnessLimit > self.limitEnd:
                    fitnessLimit = self.limitStart

    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population[0].fitness}, worst fitness: {self.population.worstFitness}"))

    return self.population[0].naToBytes()

proc naInitPopulationNodeDP7*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP7 =
    ncInfo("naInitPopulationNodeDP7")
    ncInfo("The best individual is at index 0, start limit at base and increment for each individual.")

    assert config.base > 0.0
    ncDebug(fmt("Base: {config.base}"))

    assert config.limitEnd > config.base
    ncDebug(fmt("Limit end: {config.limitEnd}"))

    assert config.increment > 0.0
    ncDebug(fmt("Increment: {config.increment}"))

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP7(population: population)
    result.limitStart = config.base
    result.limitEnd = config.limitEnd
    result.limitIncrement = config.increment


