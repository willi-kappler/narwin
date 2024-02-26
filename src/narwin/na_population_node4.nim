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
from std/math import sin

# External imports
import num_crunch

# Local imports
import na_config
import na_individual
import na_population

type
    NAPopulationNodeDP4 = ref object of NCNodeDataProcessor
        population: NAPopulation
        dt: float64
        amplitude: float64
        base: float64

method ncProcessData(self: var NAPopulationNodeDP4, inputData: seq[byte]): seq[byte] =
    ncDebug("ncProcessData()", 2)

    var tmpIndividual: NAIndividual
    var fitnessLimit: float64
    var t: float64 = 0.0
    var currentBest = self.population.naClone(0)

    self.population.naReplaceWorst(inputData)

    block iterations:
        for i in 0..<self.population.numOfIterations:
            fitnessLimit = self.base + (self.amplitude * sin(t))

            for j in 0..<self.population.populationSize:
                tmpIndividual = self.population.naClone(j)

                for _ in 0..<self.population.numOfMutations:
                    tmpIndividual.naMutate()
                    tmpIndividual.naCalculateFitness()

                    if tmpIndividual < fitnessLimit:
                        self.population[j] = tmpIndividual
                    elif tmpIndividual < self.population[j]:
                        self.population[j] = tmpIndividual

                    if tmpIndividual < currentBest:
                        currentBest = tmpIndividual.naClone()

                        if tmpIndividual <= self.population.targetFitness:
                            ncDebug(fmt("Early exit at i: {i}"))
                            break iterations

            t = t + self.dt

    ncDebug(fmt("Current best: {currentBest.fitness}"))
    # Find the best and the worst individual at the end:
    self.population.findBestAndWorstIndividual()
    ncDebug(fmt("Best fitness: {self.population.bestFitness}, worst fitness: {self.population.worstFitness}"))

    return currentBest.naToBytes()

proc naInitPopulationNodeDP4*(individual: NAIndividual, config: NAConfiguration): NAPopulationNodeDP4 =
    ncInfo("naInitPopulationNodeDP4")
    ncInfo("The fitness limit is changed using a sine wave.")

    assert config.dt > 0.0
    assert config.amplitude > 0.0
    assert config.base >= 0.0

    ncDebug(fmt("Dt: {config.dt}"))
    ncDebug(fmt("Amplitude: {config.amplitude}"))
    ncDebug(fmt("Base: {config.base}"))

    let initPopulation = newSeq[NAIndividual](config.populationSize)
    var population = naInitPopulation(individual, config, initPopulation)

    result = NAPopulationNodeDP4(population: population)
    result.dt = config.dt
    result.amplitude = config.amplitude
    result.base = config.base

