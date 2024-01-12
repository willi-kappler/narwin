## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the base data structure for an individual.
##
## This Nim library allows you to write programs using evolutionary algorithms.
##

# Nim std imports
import std/json

type
    NAIndividual* = ref object of RootObj
        fitness*: float64

method naMutate*(self: var NAIndividual, operations: seq[uint32] = @[]) {.base.} =
    quit("You must override this method: naMutate")

method naRandomize*(self: var NAIndividual) {.base.} =
    quit("You must override this method: naRandomize")

method naCalculateFitness*(self: var NAIndividual) {.base.} =
    quit("You must override this method: naCalculateFitness")

method naClone*(self: NAIndividual): NAIndividual {.base, gcsafe.} =
    quit("You must override this method: naClone")

method naToBytes*(self: NAIndividual): seq[byte] {.base, gcsafe.} =
    quit("You must override this method: naToBytes")

method naFromBytes*(self: var NAIndividual, data: seq[byte]) {.base, gcsafe.} =
    quit("You must override this method: naFromBytes")

method naToJSON*(self: NAIndividual): JsonNode {.base, gcsafe.} =
    quit("You must override this method: naToJSON")

method naFromJSON*(self: NAIndividual, data: JsonNode): NAIndividual {.base, gcsafe.} =
    quit("You must override this method: naFromJSON")

proc naNewRandomIndividual*(self: NAIndividual): NAIndividual =
    result = self.naClone()
    result.naRandomize()
    result.naCalculateFitness()

proc naLoadData*(self: NAIndividual, fileName: string): NAIndividual =
    let inFile = open(fileName, mode = fmRead)
    let data = inFile.readAll()
    inFile.close()

    return self.naFromJson(parseJson(data))

