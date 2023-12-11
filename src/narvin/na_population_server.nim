# Nim std imports
import std/options

from std/strformat import fmt
from std/algorithm import sort

# External imports
import num_crunch

# Local imports
import na_individual

type
    NAPopulationServerDP* = ref object of NCServerDataProcessor
        population: seq[NAIndividual]
        targetFitness: float64
        resultFilename: string

method ncIsFinished(self: var NAPopulationServerDP): bool =
    return self.population[0].fitness <= self.targetFitness

method ncGetInitData(self: var NAPopulationServerDP): seq[byte] =
    discard

method ncGetNewData(self: var NAPopulationServerDP, n: NCNodeID): seq[byte] =
    return ncToBytes(self.population[0])

method ncCollectData(self: var NAPopulationServerDP, n: NCNodeID, data: seq[byte]) =
    let last = self.population.high
    let individual = ncFromBytes(data, NAIndividual)
    # Overwrite (kill) the least fit individual with the new best
    # individual from the node population:
    self.population[last] = individual

    # Sort population by fitness:
    self.population.sort do (a: NAIndividual, b: NAIndividual) -> int:
        return cmp(a.fitness, b.fitness)

method ncMaybeDeadNode(self: var NAPopulationServerDP, n: NCNodeID) =
    discard

method ncSaveData(self: var NAPopulationServerDP) =
    let outFile = open(self.resultFilename, mode = fmWrite)
    # TODO: Write file
    outFile.close()


    #let imgFile = open("mandel_image.ppm", mode = fmWrite)

    #imgFile.write("P3\n")
    #imgFile.write(fmt("{imgWidth} {imgHeight}\n"))
    #imgFile.write("255\n")

    #imgFile.write("\n")

    #imgFile.close()

proc initPopulationServerDP*(
        individual: NAIndividual,
        targetFitness: float64,
        populationSize: uint32 = 10,
        resultFilename: string): NAPopulationServerDP =

    assert populationSize >= 5

    result.population = newSeq[NAIndividual](populationSize)
    result.targetFitness = targetFitness
    result.resultFilename = resultFilename

    for i in 0..<populationSize:
        result.population[i] = individual.naNewRandomIndividual()

