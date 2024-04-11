## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutionary algorithms.
##
## This module contains the base data structure for an individual.
## See the examples folder on how to implement the data structure and override the methods.
##

# Nim std imports
import std/json

type
    NAIndividual* = ref object of RootObj
        ## Abstract data structure for a single individual.
        ## It just contains the fitness as element.
        ## The user has to inherit from it and add other meaningful data.
        ## See the examples folder.
        fitness*: float64

method naMutate*(self: var NAIndividual) {.base.} =
    ## This method is called in each iteration for each individual.
    ## The user has to override it and mutate the user data accordingly.
    quit("You must override this method: naMutate")

method naRandomize*(self: var NAIndividual) {.base.} =
    ## This method is only called at the beginning of each iteration when reset is enabled.
    ## The user has to override it and totally randomize the user data.
    quit("You must override this method: naRandomize")

method naCalculateFitness*(self: var NAIndividual) {.base.} =
    ## This method is called in each iteration for each individual.
    ## The user has to override it.
    ## It has to calculate the fitness value of this individual and save it in the base object.
    quit("You must override this method: naCalculateFitness")

method naClone*(self: NAIndividual): NAIndividual {.base, gcsafe.} =
    ## This method is in each iteration and when the population is initialized.
    ## The user has to override it and clone all the relevant user data.
    quit("You must override this method: naClone")

method naToBytes*(self: NAIndividual): seq[byte] {.base, gcsafe.} =
    ## This method is called when the data has to be sent over the network and serialized.
    ## The user has to override it using the ncToBytes helper function from the num_crunch library.
    quit("You must override this method: naToBytes")

method naFromBytes*(self: var NAIndividual, data: seq[byte]) {.base, gcsafe.} =
    ## This method is called when the data has been sent over the network and needs to be deserialized.
    ## The user has to override it using the ncFromBytes helper function from the num_crunch library.
    quit("You must override this method: naFromBytes")

method naToJSON*(self: NAIndividual): JsonNode {.base, gcsafe.} =
    ## This method is called when the data has to be written to disk.
    ## The user has to override it using the toJson function from the std/json library.
    quit("You must override this method: naToJSON")

method naFromJSON*(self: NAIndividual, data: JsonNode): NAIndividual {.base, gcsafe.} =
    ## This method is called when the data has to be read from disk.
    ## The user has to override it using the fromJson function from the std/json library.
    quit("You must override this method: naFromJSON")

proc naNewRandomIndividual*(self: NAIndividual): NAIndividual =
    ## This function is called when a new and totally randomized individual has to be created.
    ## It used the other methods that the user has provided: naClone, naRandomize, naCalculateFitness.
    result = self.naClone()
    result.naRandomize()
    result.naCalculateFitness()

proc naLoadData*(self: NAIndividual, fileName: string): NAIndividual =
    ## This function is called to load the user data from disk.
    ## It used the other methods that the user has provided: naFromJSON
    let inFile = open(fileName, mode = fmRead)
    let data = inFile.readAll()
    inFile.close()

    return self.naFromJSON(parseJson(data))

proc `<`*(self: NAIndividual, other: NAIndividual): bool =
    ## Compares the fitness of two individuals.
    self.fitness < other.fitness

proc `<`*(self: NAIndividual, fitness: float64): bool =
    ## Compares the fitness of this individual with a float64.
    self.fitness < fitness

proc `<=`*(self: NAIndividual, fitness: float64): bool =
    ## Compares the fitness of this individual with a float64.
    self.fitness <= fitness

