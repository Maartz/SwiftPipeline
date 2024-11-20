import Testing

@testable import SwiftPipeline

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
