# This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This Nim library allows you to write programs using evolutionary algorithms.
##
## This module contains the implementation of the NAIndividual code from narwin for the OCR example.
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
        data: bool # TODO: data is a pointer to an image in memory
        line1: string
        line2: string

const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "

method naMutate*(self: var OCRIndividual) =
    const maxOperation: int = 7

    let l1 = self.line1.high
    let l2 = self.line2.high
    let l3 = chars.high

    let operation = rand(maxOperation)

    case operation
    of 0:
        # Change one char at line 1
        let i = rand(l1)
        let c = rand(l3)
        self.line1[i] = chars[c]
    of 1:
        # Change one char at line 2
        let i = rand(l2)
        let c = rand(l3)
        self.line2[i] = chars[c]
    of 2:
        # Add one char at line 1
        discard
    of 3:
        # Add one char at line 2
        discard
    of 4:
        # Remove one char at line 1
        discard
    of 5:
        # Remove one char at line 2
        discard
    of 6:
        # Swap two chars at line 1
        discard
    of maxOperation:
        # Swap two chars at line 2
        discard
    else:
        raise newException(ValueError, fmt("Unknown mutation operation: {operation}"))

method naRandomize*(self: var OCRIndividual) =
    let l1 = rand(8) + 2
    let l2 = rand(8) + 2

method naCalculateFitness*(self: var OCRIndividual) =
    # TODO: Render text to temporary image, then compare it to given image.
    # The number of errors is how many pixel are different.
    discard

method naClone*(self: OCRIndividual): NAIndividual =
    result = OCRIndividual(
        data: self.data,
        line1: self.line1,
        line2: self.line2,
    )
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
    result.line1 = ""
    result.line2 = ""

