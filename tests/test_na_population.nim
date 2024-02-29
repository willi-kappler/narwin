# Nim std imports
import std/json
import std/jsonutils

# External imports
import num_crunch

# Local imports
import narwin/na_config
import narwin/na_individual
import narwin/na_population
import util

type
    TestIndividual* = ref object of NAIndividual
        data: string

method naMutate*(self: var TestIndividual) =
    self.data = "Mutate2"

method naRandomize*(self: var TestIndividual) =
    self.data = "Randomize2"

method naCalculateFitness*(self: var TestIndividual) =
    self.fitness = float64(self.data.len())

method naClone*(self: TestIndividual): NAIndividual =
    result = TestIndividual(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: TestIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var TestIndividual, data: seq[byte]) =
    self = ncFromBytes(data, TestIndividual)

method naToJSON*(self: TestIndividual): JsonNode =
    self.toJson()

method naFromJSON*(self: TestIndividual, data: JsonNode): NAIndividual =
    return data.jsonTo(TestIndividual)

proc test1() =
    discard

when isMainModule:
    test1()

