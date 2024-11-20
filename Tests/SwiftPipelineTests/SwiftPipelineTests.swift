import XCTest

@testable import SwiftPipeline

final class SwiftPipelineTests: XCTestCase {
    struct Person {
        let name: String
        let age: Int
    }

    func testThreadFirst() {
        let person = Person(name: "Alice", age: 30)

        let result =
            person
            => \.name
            => { $0.uppercased() }

        XCTAssertEqual(result, "ALICE")
    }

    func testThreadLast() {
        let numbers = [1, 2, 3]

        let incremented = numbers =>> { $0.map { $0 + 1 } }
        let filtered = incremented =>> { $0.filter { $0 % 2 != 0 } }
        let result = filtered =>> { $0.reduce(0, +) }

        XCTAssertEqual(result, 6)
    }

    func testAsThread() {
        let total =
            5 ~=> { x in
                x + 10
            } => { $0 * 2 }

        XCTAssertEqual(total, 30)
    }

    func testThreadFirstWithFunction() {
        func greet(name: String) -> String {
            return "Hello, \(name)!"
        }

        let person = Person(name: "Alice", age: 30)

        let result =
            person
            => \.name
            => greet

        XCTAssertEqual(result, "Hello, Alice!")
    }

    func testFlatMapWithOptionnal() {
        let value: Int? = 10
        let result = { $0 * 2 } <| value
        XCTAssertEqual(result, Optional(20))
    }

    func testFlatMapWithArray() {
        let numbers = [1, 2, 3]
        let result = { $0 * 2 } <| numbers
        XCTAssertEqual(result, [2, 4, 6])
    }

    func testFlatMapWithThreadAs() {
        let optionalResult =
            10 ~=> { $0 * 2 } <| Optional.init

        XCTAssertEqual(optionalResult, Optional(20))
    }
}
