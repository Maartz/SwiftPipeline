# SwiftPipeline

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMaartz%2FSwiftPipeline%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Maartz/SwiftPipeline)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMaartz%2FSwiftPipeline%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Maartz/SwiftPipeline)

[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

SwiftPipeline is a lightweight, functional-style library for Swift that brings the power of **threading macros** and **functional operators** inspired by languages like **Clojure** and **Haskell**. With clean and expressive operators, SwiftPipeline allows you to thread data through a series of transformations in a concise and readable way.

## Features 🎯

### Threading Operators
- **Thread-first (`=>`)**: Passes the value as the first argument to functions or uses KeyPaths for property extraction
- **Thread-last (`=>>`)**: Passes the value as the last argument to functions
- **Thread-as (`~=>`)**: Binds a value to a name for custom transformations

### Functional Operators
- **FlatMap (`<|`)**: Applies functions to optional values or arrays
- **Applicative (`<*>`)**: Applies wrapped functions to wrapped values
- **Kleisli composition (`>=>`)**: Composes functions that return optionals
- **Alternative (`<|>`)**: Provides fallback values for computations
- **Monadic bind (`>>-`)**: Chains operations that produce optionals
- **Reverse bind (`-<<`)**: Flipped version of monadic bind

## Why SwiftPipeline? 🤔

### Clean and Declarative Code
- Transform your Swift code into highly expressive and readable pipelines
- Chain operations in a natural, left-to-right flow
- Reduce nested function calls and temporary variables
- Make complex data transformations clear and maintainable

### Rich Functional Programming Patterns
- Combines threading macros from **Clojure** with functional operators from **Haskell**
- Powerful composition with monadic, applicative, and alternative operators
- Strong type safety while maintaining functional programming elegance
- Makes optional handling and error propagation elegant

### Lightweight and Swift-Native
- Zero external dependencies—pure Swift implementation
- Minimal runtime overhead
- Small API surface with maximum expressiveness
- Seamlessly integrates with Swift's type system and standard library

### Flexible and Extensible
- Works with any Swift type, including your custom types
- Combines beautifully with Swift's KeyPaths
- Easy to extend with your own operators
- Perfect for both small scripts and large applications

### Battle-Tested Patterns
- Based on proven functional programming concepts
- Inspired by decades of FP best practices
- Makes complex operations predictable and safe
- Reduces cognitive load when dealing with complex transformations

### Great for Teams
- Makes code intent clear and self-documenting
- Reduces merge conflicts by encouraging linear transformations
- Easy to learn, hard to misuse
- Consistent patterns across your codebase

Whether you're building data pipelines, handling optional chains, or just want cleaner code, SwiftPipeline provides the tools you need without the bloat.


## Installation 📥

Add **SwiftPipeline** to your project using the Swift Package Manager:
1. Open your project in Xcode
2. Go to **File > Add Packages**
3. Enter the following repository URL:
   ```plaintext
   https://github.com/Maartz/SwiftPipeline.git
   ```
4. Select the latest version and add the package

## Usage 📖

### Basic Threading Operators

#### Thread-first (`=>`)
```swift
struct Person {
    let name: String
    let age: Int
}

let person = Person(name: "Alice", age: 30)
let result = person
    => \.name
    => { $0.uppercased() }
// Output: "ALICE"
```

#### Thread-last (`=>>`)
```swift
let numbers = [1, 2, 3]
let result = numbers
    =>> { $0.map { $0 + 1 } }
    =>> { $0.filter { $0 % 2 != 0 } }
    =>> { $0.reduce(0, +) }
// Output: 6
```

#### Thread-as (`~=>`)
```swift
let total = 5 
    ~=> { x in x + 10 } 
    => { $0 * 2 }
// Output: 30
```

### Functional Operators

#### Map (`<|`)
```swift
// With optionals
let double: (Int) -> Int = { $0 * 2 }
let result = double <| Some(5)  // Optional(10)

// With arrays
let numbers = [1, 2, 3]
let doubled = double <| numbers  // [2, 4, 6]
```

#### Applicative (`<*>`)
```swift
let maybeDouble: ((Int) -> Int)? = { $0 * 2 }
let result = maybeDouble <*> Some(5)  // Optional(10)

// With arrays
let functions = [{ $0 * 2 }, { $0 + 3 }]
let values = [1, 2]
let results = functions <*> values  // [2, 4, 4, 5]
```

#### Alternative (`<|>`)
```swift
let parseNumber: (String) -> Int? = { Int($0) }
let result = parseNumber("invalid") <|> parseNumber("42") <|> Some(0)
// Falls back to valid parsing or default
```

#### Monadic Bind (`>>-`) and Reverse Bind (`-<<`)
```swift
let parseId: (String) -> Int? = { Int($0) }
let findUser: (Int) -> User? = { id in 
    // Find user by id
    id == 42 ? User(id: 42, name: "John") : nil 
}

// Using >>-
let user1 = "42" >>- parseId >>- findUser

// Using -<<
let user2 = findUser -<< (parseId -<< "42")
```

### Complex Examples

#### Optional Chaining with Alternatives
```swift
struct User {
    let id: Int
    let email: String?
}

let validateEmail: (String) -> String? = { email in
    email.contains("@") ? email : nil
}

let result = parseId -<< "42"
    >>- findUser
    >>- { user in user.email >>- validateEmail }
    <|> Some("default@email.com")
```

#### Applicative with Computations
```swift
let compute: (Int) -> (Int) -> Int? = { x in 
    { y in (x + y) > 0 ? x + y : nil } 
}

let result = (parseId -<< "5" >>- compute) 
    <*> Some(-3) 
    <|> Some(10)
```

## API Reference 📚

### Operators
| Operator | Type | Description | Example Usage |
|----------|------|-------------|---------------|
| `=>`     | Threading | Thread-first | `value => function` |
| `=>>`    | Threading | Thread-last | `value =>> function` |
| `~=>`    | Threading | Thread-as | `value ~=> { $0 * 2 }` |
| `<\|`    | Functional | Map | `function <\| optional` |
| `<*>`    | Functional | Applicative | `wrappedFn <*> wrappedValue` |
| `>=>`    | Functional | Kleisli composition | `f >=> g` |
| `<\|>`   | Functional | Alternative | `computation1 <\|> computation2` |
| `>>-`    | Functional | Monadic bind | `value >>- function` |
| `-<<`    | Functional | Reverse bind | `function -<< value` |

## Contributing 🤝

We welcome contributions! Feel free to:
- Submit a bug report or feature request
- Fork the repository and open a pull request

## License 📜

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements 🙏

SwiftPipeline is inspired by the threading macros of **Clojure** and functional operators from **Haskell**, aiming to bring similar functionality to the Swift ecosystem.

---
Enjoy using SwiftPipeline! 🚀

