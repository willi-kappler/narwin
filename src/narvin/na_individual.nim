## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module contains the base data structure for an individual.
##
## This Nim library allows you to write programs using evolutionary algorithms.
##

type
    NAIndividual* = ref object of RootObj
        fitness*: float64

method naMutate*(self: var NAIndividual) {.base.} =
    quit("You must override this method: naMutate")

method naRandomize*(self: var NAIndividual) {.base.} =
    quit("You must override this method: naRandomize")

method naCalculateFitness*(self: var NAIndividual) {.base.} =
    quit("You must override this method: naCalculateFitness")

method naClone*(self: NAIndividual): NAIndividual {.base.} =
    quit("You must override this method: naClone")

proc naNewRandomIndividual*(self: NAIndividual): NAIndividual =
    var newIndividual = self.naClone()
    newIndividual.naRandomize()
    newIndividual.naCalculateFitness()

