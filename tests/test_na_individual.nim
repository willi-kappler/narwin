
# Nim std imports
import std/json
import std/jsonutils

# External imports
import num_crunch

# Local imports
import narwin/na_individual

type
    TestIndividual* = ref object of NAIndividual
        data: string

method naMutate*(self: var TestIndividual) =
    self.data = "Mutate1"

method naRandomize*(self: var TestIndividual) =
    self.data = "Randomize1"

method naCalculateFitness*(self: var TestIndividual) =
    self.fitness = float64(self.data.len())

method naClone*(self: TestIndividual): NAIndividual =
    result = TestIndividual(data: self.data)
    result.fitness = self.fitness

method naToBytes*(self: TestIndividual): seq[byte] =
    ncToBytes(self)

method naFromBytes*(self: var TestIndividual, data: seq[byte]) =
    self = ncFromBytes(data, TestIndividual)

method naToJSON*(self: TestIndividual): JsonNode =
    self.toJson()

method naFromJSON*(self: TestIndividual, data: JsonNode): NAIndividual =
    return data.jsonTo(TestIndividual)

proc test1_mutate() =
    var indi1 = TestIndividual(data: "Test1")
    assert(indi1.data == "Test1")
    assert(indi1.fitness == 0.0)

    var indi2: NAIndividual = indi1
    indi2.naMutate()
    assert(indi1.data == "Mutate1")
    assert(indi1.fitness == 0.0)
    assert(indi2.fitness == 0.0)

proc test2_mutate() =
    var indi1 = TestIndividual(data: "Test2")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()
    assert(indi1.data == "Test2")
    assert(indi1.fitness == 5.0)
    assert(indi2.fitness == 5.0)

    indi2.naMutate()
    assert(indi1.data == "Mutate1")
    assert(indi1.fitness == 5.0)
    assert(indi2.fitness == 5.0)
    indi2.naCalculateFitness()
    assert(indi1.data == "Mutate1")
    assert(indi1.fitness == 7.0)
    assert(indi2.fitness == 7.0)

proc test3_randomize() =
    var indi1 = TestIndividual(data: "Test3")

    var indi2: NAIndividual = indi1
    indi2.naRandomize()
    assert(indi1.data == "Randomize1")
    assert(indi1.fitness == 0.0)
    assert(indi2.fitness == 0.0)
    indi2.naCalculateFitness()
    assert(indi1.fitness == 10.0)
    assert(indi2.fitness == 10.0)

proc test4_clone() =
    var indi1 = TestIndividual(data: "Test4")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()

    let indi3 = indi2.naClone()
    #assert(indi2.data == "Test4")
    assert(indi3.fitness == 5.0)

    indi1.data = "Test4 Indi1"
    indi2.naCalculateFitness()
    assert(indi1.fitness == 11.0)
    assert(indi2.fitness == 11.0)
    #assert(indi2.data == "Test4")
    assert(indi3.fitness == 5.0)

proc test5_bytes() =
    var indi1 = TestIndividual(data: "Test5")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()

    let binaryValue = indi2.naToBytes()

    indi1.data = "Test5 Original"
    indi2.naCalculateFitness()
    assert(indi1.fitness == 14.0)
    assert(indi2.fitness == 14.0)

    indi2.naFromBytes(binaryValue)
    #assert(indi1.data == "Test5")
    assert(indi2.fitness == 5.0)

proc test6_json() =
    var indi1 = TestIndividual(data: "Test6")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()

    let jsonValue = indi2.naToJSON()

    indi1.data = "Test6 Original"
    indi2.naCalculateFitness()
    assert(indi1.fitness == 14.0)

    let indi3 = indi2.naFromJSON(jsonValue)
    #assert(indi3.data == "Test6")
    assert(indi3.fitness == 5.0)

when isMainModule:
    test1_mutate()
    test2_mutate()
    test3_randomize()
    test4_clone()
    test5_bytes()
    test6_json()


