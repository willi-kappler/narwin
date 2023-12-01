## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module just reexports items from other modules.
##
## This nim library allows you to write programs using evolutionary algorithms.
##

type
    NAIndividual* = ref object of RootObj
        fitness: float64

method naMutate(self: var NAIndividual) {.base.} =
    quit("You must override this method: naMutate")

method naCalculateFitness(self: var NAIndividual) {.base.} =
    quit("You must override this method: naCalculateFitness")


