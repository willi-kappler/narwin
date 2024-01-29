## This module is part of narwin: https://github.com/willi-kappler/narwin
##
## Written by Willi Kappler, License: MIT
##
## This module just reexports items from other modules.
##
## This Nim library allows you to write programs using evolutionary algorithms.
##

# Nim std imports
from std/strformat import fmt

# External imports
import num_crunch

# Local imports
import narwin/na_config
import narwin/na_individual
import narwin/na_population_node1
import narwin/na_population_node2
import narwin/na_population_node3
import narwin/na_population_node4
import narwin/na_population_node5
import narwin/na_population_node6
import narwin/na_population_node7
import narwin/na_population_server

export na_config
export na_individual
export na_population_server

export num_crunch


proc naGetPopulationNodeDP*(individual: NAIndividual, config: NAConfiguration): NCNodeDataProcessor =
    case config.populationKind:
    of 1:
        return naInitPopulationNodeDP1(individual, config)
    of 2:
        return naInitPopulationNodeDP2(individual, config)
    of 3:
        return naInitPopulationNodeDP3(individual, config)
    of 4:
        return naInitPopulationNodeDP4(individual, config)
    of 5:
        return naInitPopulationNodeDP5(individual, config)
    of 6:
        return naInitPopulationNodeDP6(individual, config)
    of 7:
        return naInitPopulationNodeDP7(individual, config)
    else:
        raise newException(ValueError, fmt("Unknown population kind: {config.populationKind}"))

