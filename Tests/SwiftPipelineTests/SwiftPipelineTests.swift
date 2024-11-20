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

struct ComplexOperations {
    struct User {
        let id: Int
        let name: String
        let email: String?
        let role: Role?
        let preferences: Preferences?
    }

    struct Role {
        let name: String
        let permission: [String]
    }

    struct Preferences {
        let theme: String
        let notifications: Bool
    }

    @Test("Complex operator chain")
    func testComplexOperatorChain() {
        let parseId: (String) -> Int? = { Int($0) }
        let findUser: (Int) -> User? = { id in
            id == 42
                ? User(
                    id: id, name: "John Appleseed", email: "john@appleseed.com", role: nil,
                    preferences: nil) : nil
        }

        let validateEmail: (String) -> String? = { email in
            email.contains("@") ? email : nil
        }

        let formatEmail: (String) -> String = { $0.uppercased() }

        // Complex Chain 1: using multiple operators
        let result =
            parseId -<< "42"
            >>- findUser
            >>- { user in user.email >>- validateEmail }
            >>- { email in Optional(formatEmail(email)) }

        #expect(result == "JOHN@APPLESEED.COM")

        // Complex Chain 2: Alternative Path
        let invalidUser = (parseId -<< "invalidId" >>- findUser) <|> (findUser -<< Optional(42))
        #expect(invalidUser?.id == 42)

        // Complex Chain 3: Applicative with Alternative
        let compute: (Int) -> (Int) -> Int? = { x in { y in (x + y) > 0 ? x + y : nil } }
        let result2 = (parseId -<< "5" >>- compute) <*> Optional(-3) <|> Optional(10)
        #expect(result2 == 2)
        let result3 = (parseId -<< "invalid" >>- compute) <*> Optional(-3) <|> Optional(10)
        #expect(result3 == 10)
    }

    @Test("Real world use case")
    func itIsForReal() {
        let users = [
            User(
                id: 1, name: "Alice", email: "alice@test.com",
                role: Role(name: "admin", permission: ["read", "write"]),
                preferences: Preferences(theme: "dark", notifications: true)),
            User(id: 2, name: "Bob", email: nil, role: nil, preferences: nil),
        ]

        let getTheme =
            users => { $0.map(\.preferences) } => { $0.map { $0?.theme } } => { themes in
                themes.map { $0 <|> "default" }
            }
        #expect(getTheme == ["dark", "default"])

        let hasPermission: (Role?) -> Bool? = { $0?.permission.contains("write") }
        let adminEmails =
            users => { $0.map(\.email) } ~=> { emails in
                emails.enumerated().compactMap { idx, email in
                    let role = users[idx].role
                    return hasPermission(role) == true ? email : nil
                }
            }
        #expect(adminEmails == ["alice@test.com"])

        let validateEmail: (String) -> String? = { $0.contains("@") ? $0 : nil }
        let formatEmail: (String) -> String = { $0.uppercased() }

        let processedEmails =
            users => { $0.map(\.email) } => { optionals in
                optionals.map { email in
                    (validateEmail -<< email >>- { Optional(formatEmail($0)) })
                        <|> Optional("NO_EMAIL")
                }
            }
        #expect(processedEmails == ["ALICE@TEST.COM", "NO_EMAIL"])
    }
}
