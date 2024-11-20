import Foundation
import Testing

@testable import SwiftPipeline

struct ClojureThreading {
    struct Person {
        let name: String
        let age: Int
    }

    @Test func testThreadFirst() {
        let person = Person(name: "Alice", age: 30)

        let result =
            person
            => \.name
            => { $0.uppercased() }

        #expect(result == "ALICE")
    }

    @Test func testThreadLast() {
        let numbers = [1, 2, 3]

        let incremented = numbers =>> { $0.map { $0 + 1 } }
        let filtered = incremented =>> { $0.filter { $0 % 2 == 0 } }
        let result = filtered =>> { $0.reduce(0, +) }

        #expect(result == 6)
    }

    @Test func testAsThread() {
        let total =
            5 ~=> { x in
                x + 10
            } => { $0 * 2 }

        #expect(total == 30)
    }

    @Test func testThreadFirstWithFunction() {
        func greet(name: String) -> String {
            return "Hello, \(name)!"
        }

        let person = Person(name: "Alice", age: 30)

        let result =
            person
            => \.name
            => greet

        #expect(result == "Hello, Alice!")
    }
}

@Test func testFlatMapWithOptionnal() {
    let value: Int? = 10
    let result = { $0 * 2 } <| value
    #expect(result == Optional(20))
}

@Test func testFlatMapWithArray() {
    let numbers = [1, 2, 3]
    let result = { $0 * 2 } <| numbers
    #expect(result == [2, 4, 6])
}

@Test func testFlatMapWithThreadAs() {
    let optionalResult =
        10 ~=> { $0 * 2 } <| Optional.init

    #expect(optionalResult == Optional(20))
}

@Test func testApplicativeOperatorWithOptionnal() {
    let optionalFunction: ((Int) -> Int)? = { $0 * 2 }
    let value: Int? = 10
    let result = optionalFunction <*> value
    #expect(result == 20)
}

@Test func testApplicativeOperatorWithArray() {
    let functions = [{ $0 * 2 }, { $0 + 3 }]
    let values = [1, 2]
    let result = functions <*> values
    #expect(result == [2, 4, 4, 5])
}

struct BindOperations {
    @Test("Kleisli composition") func testBindOperator() {
        let value: Int? = 3
        let result = value >>- { x in x % 2 == 0 ? Optional(x * 2) : nil }
        #expect(result == nil)
    }

    @Test("Reverse Composition") func testReverseBindOperator() {
        let stringToInt: (String) -> Int? = { str in Int(str) }
        let addOne: (Int) -> Int? = { x in x + 1 }

        #expect(addOne -<< (stringToInt -<< "42") == 43)
        #expect(addOne -<< (stringToInt -<< "Abc") == nil)
    }

    @Test("Composition of BindOperations") func testCompositionBindOperators() {
        let stringToInt: (String) -> Int? = { str in Int(str) }
        let addOne: (Int) -> Int? = { x in x + 1 }

        let result = stringToInt -<< "42" >>- addOne
        #expect(result == 43)
    }

}

@Test func testCompositionOperator() {
    let f = { (x: Int) -> Int? in x > 0 ? x * 2 : nil }
    let g = { (x: Int) -> Int? in x < 10 ? x + 1 : nil }
    let h = f >=> g
    #expect(h(3) == 7)
    #expect(h(5) == nil)
}

@Test func testAlternativeOperator() {
    let a: Int? = nil
    let b: Int? = 2
    #expect((a <|> b) == 2)

    let c: Int? = 1
    let d: Int? = 2
    #expect((c <|> d) == 1)

    let e: Int? = nil
    let f: Int? = nil
    let g: Int? = 5
    #expect((e <|> f <|> g) == 5)

    var sideEffect = 0
    let h: Int? = 1
    _ = h
        <|> {
            sideEffect += 1
            return 2
        }()
    #expect(sideEffect == 0)

    func expensiveComputation() -> Int? {
        Thread.sleep(forTimeInterval: 0.1)
        return 42
    }

    let i: Int? = 5
    #expect((i <|> expensiveComputation()) == 5)
}
