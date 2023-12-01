## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module just reexports items from other modules.
##
## This nim library allows you to write programs using evolutionary algorithms.
##

# Local imports
import na_individual


type
    NAPopulation* = object
        populationSize: uint32
        population: seq[NAIndividual]
        numOfMutations: uint32
        numOfIterations: uint32

