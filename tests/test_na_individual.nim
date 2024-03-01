
# Nim std imports
import std/json
import std/jsonutils

# External imports
import num_crunch

# Local imports
import narwin/na_individual
import util

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
    assertValues(indi2, "Mutate1", 0.0)

proc test2_mutate() =
    var indi1 = TestIndividual(data: "Test2")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()
    assert(indi1.data == "Test2")
    assert(indi1.fitness == 5.0)
    assertValues(indi2, "Test2", 5.0)

    indi2.naMutate()
    assert(indi1.data == "Mutate1")
    assert(indi1.fitness == 5.0)
    assertValues(indi2, "Mutate1", 5.0)

    indi2.naCalculateFitness()
    assert(indi1.data == "Mutate1")
    assert(indi1.fitness == 7.0)
    assertValues(indi2, "Mutate1", 7.0)

proc test3_randomize() =
    let indi1 = TestIndividual(data: "Test3")

    var indi2: NAIndividual = indi1
    indi2.naRandomize()
    assert(indi1.data == "Randomize1")
    assert(indi1.fitness == 0.0)
    assertValues(indi2, "Randomize1", 0.0)
    indi2.naCalculateFitness()
    assert(indi1.fitness == 10.0)
    assertValues(indi2, "Randomize1", 10.0)

proc test4_clone() =
    var indi1 = TestIndividual(data: "Test4")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()

    let indi3 = indi2.naClone()
    assertValues(indi2, "Test4", 5.0)
    assertValues(indi3, "Test4", 5.0)

    indi1.data = "Test4 Indi1"
    indi2.naCalculateFitness()
    assert(indi1.fitness == 11.0)
    assertValues(indi2, "Test4 Indi1", 11.0)
    assertValues(indi3, "Test4", 5.0)

proc test5_bytes() =
    var indi1 = TestIndividual(data: "Test5")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()

    let binaryValue = indi2.naToBytes()

    indi1.data = "Test5 Original"
    indi2.naCalculateFitness()
    assert(indi1.fitness == 14.0)
    assertValues(indi2, "Test5 Original", 14.0)

    indi2.naFromBytes(binaryValue)
    assertValues(indi2, "Test5", 5.0)

proc test6_json() =
    let indi1 = TestIndividual(data: "Test6")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()

    let jsonValue = indi2.naToJSON()

    indi1.data = "Test6 Original"
    indi2.naCalculateFitness()
    assert(indi1.fitness == 14.0)
    assertValues(indi2, "Test6 Original", 14.0)

    let indi3 = indi2.naFromJSON(jsonValue)
    assertValues(indi3, "Test6", 5.0)

proc test7_randomIndividual() =
    let indi1 = TestIndividual(data: "Test7")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()

    let indi3 = indi2.naNewRandomIndividual()
    assert(indi1.fitness == 5.0)
    assertValues(indi2, "Test7", 5.0)
    assertValues(indi3, "Randomize1", 10.0)

proc test8_loadData() =
    let indi1 = TestIndividual(data: "Test8")
    var indi2: NAIndividual = indi1
    let indi3 = indi2.naLoadData("tests/test_data.json")
    assertValues(indi2, "Test8", 0.0)
    assertValues(indi3, "Some test data", 14.0)

proc test9_sm() =
    let indi1 = TestIndividual(data: "Test9")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()

    let indi3 = TestIndividual(data: "Test9 Bigger")
    var indi4: NAIndividual = indi3
    indi4.naCalculateFitness()

    assert(indi1.fitness == 5.0)
    assert(indi3.fitness == 12.0)

    assertValues(indi2, "Test9", 5.0)
    assertValues(indi4, "Test9 Bigger", 12.0)

    assert(indi2 < indi4)

proc test10_sm() =
    var indi1 = TestIndividual(data: "Test10")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()
    assertValues(indi2, "Test10", 6.0)

    assert(indi2 < 7.0)

proc test11_sm_eq() =
    var indi1 = TestIndividual(data: "Test11")
    var indi2: NAIndividual = indi1
    indi2.naCalculateFitness()
    assertValues(indi2, "Test11", 6.0)

    assert(indi2 <= 6.0)
    assert(indi2 <= 7.0)

when isMainModule:
    test1_mutate()
    test2_mutate()
    test3_randomize()
    test4_clone()
    test5_bytes()
    test6_json()
    test7_randomIndividual()
    test8_loadData()
    test9_sm()
    test10_sm()
    test11_sm_eq()




