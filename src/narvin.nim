## This module is part of narvin: https://github.com/willi-kappler/narvin
##
## Written by Willi Kappler, License: MIT
##
## This module just reexports items from other modules.
##
## This Nim library allows you to write programs using evolutinary algorithms.
##

# Nim std imports
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import narvin/na_config
import narvin/na_individual
import narvin/na_population
import narvin/na_population_node1
import narvin/na_population_node2
import narvin/na_population_node3
import narvin/na_population_server

export na_config
export na_individual
export na_population
export na_population_node1
export na_population_node2
export na_population_node3
export na_population_server

export num_crunch


proc naGetPopulationNodeDP*(individual: NAIndividual, config: NAConfiguration): NCNodeDataProcessor =
    case config.populationKind:
    of 0:
        return naInitPopulationNodeDP1(individual, config)
    of 1:
        return naInitPopulationNodeDP2(individual, config)
    of 2:
        return naInitPopulationNodeDP3(individual, config)
    else:
        raise newException(ValueError, fmt("Unknown population kind: {config.populationKind}"))



