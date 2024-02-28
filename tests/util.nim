
# Nim std imports
import std/json
from std/strformat import fmt

# Local imports
import narwin/na_individual

proc assertValues*(individual: NAIndividual, data: string, fitness: float64) =
    let j1 = individual.naToJSON()
    let j2 = %* {"data": data, "fitness": fitness}
    let msg = fmt("\n----------\nJSON not equal:\nleft: {j1}\nright: {j2}\n----------\n")

    assert(j1 == j2, msg)

