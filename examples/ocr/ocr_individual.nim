# This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the implementation of the NAIndividual code from narwin for the TSP example.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##


# Nim std imports
import std/json
import std/jsonutils

from std/random import rand, sample
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import ../../src/narwin

type
    OCRIndividual* = ref object of NAIndividual
        data: bool

method naMutate*(self: var OCRIndividual, operations: seq[uint32]) =
    discard

method naRandomize*(self: var OCRIndividual) =
    discard

method naCalculateFitness*(self: var OCRIndividual) =
    discard

method naClone*(self: OCRIndividual): NAIndividual =
    result = OCRIndividual(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: OCRIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var OCRIndividual, data: seq[byte]) =
    self = ncFromBytes(data, OCRIndividual)

method naToJSON*(self: OCRIndividual): JsonNode =
    self.toJson()

method naFromJSON*(self: OCRIndividual, data: JsonNode): NAIndividual =
    return data.jsonTo(OCRIndividual)

proc loadImage*(fileName: string): OCRIndividual =
    result = OCRIndividual(data: true)

