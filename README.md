# SwiftPipeline 📦🚀

SwiftPipeline is a lightweight, functional-style library for Swift that brings the power of **threading macros** inspired by languages like **Clojure**. With clean and expressive operators, SwiftPipeline allows you to thread data through a series of transformations in a concise and readable way.

---

## Features 🎯

- **Thread-first (`=>`)**: Passes the value as the first argument to functions or uses KeyPaths for property extraction.
- **Thread-last (`=>>`)**: Passes the value as the last argument to functions.
- **Thread-as (`~=>`)**: Binds a value to a name for custom transformations.
- **Functional and Declarative**: Keeps your Swift code expressive and clean.

---

## Installation 📥

Add **SwiftPipeline** to your project using the Swift Package Manager:

1. Open your project in Xcode.
2. Go to **File > Add Packages**.
3. Enter the following repository URL:

   ```plaintext
   https://github.com/Maartz/SwiftPipeline.git
   ```

4. Select the latest version and add the package.

---

## Usage 📖

### Thread-First (`=>`)

The `=>` operator passes the value as the **first argument** to a function or extracts a property using KeyPaths.

```swift
import SwiftPipeline

struct Person {
    let name: String
    let age: Int
}

let person = Person(name: "Alice", age: 30)

// Thread-first usage
let result =
    person
    => \.name
    => { $0.uppercased() }

print(result) // Output: "ALICE"
```

---

### Thread-Last (`=>>`)

The `=>>` operator passes the value as the **last argument** to a function, enabling clean transformations for collections and curried functions.

```swift
import SwiftPipeline

let numbers = [1, 2, 3]

// Thread-last usage
let result =
    numbers
    =>> { $0.map { $0 + 1 } }
    =>> { $0.filter { $0 % 2 != 0 } }
    =>> { $0.reduce(0, +) }

print(result) // Output: 6
```

---

### Thread-As (`~=>`)

The `~=>` operator binds a value to a custom name for transformations, making it ideal for intermediate computations.

```swift
import SwiftPipeline

let total =
    5 ~=> { x in
        x + 10
    } => { $0 * 2 }

print(total) // Output: 30
```

---

## Combining Operators 🤝

SwiftPipeline shines when you combine these operators for complex, yet readable, pipelines.

```swift
import SwiftPipeline

struct Item {
    let price: Double
    let quantity: Int
}

let items = [
    Item(price: 19.99, quantity: 2),
    Item(price: 9.99, quantity: 5),
    Item(price: 29.99, quantity: 1)
]

let totalCost = items
    =>> { $0.map { $0.price * Double($0.quantity) } }
    =>> { $0.reduce(0, +) }
    ~=> { $0 * 1.08 } // Apply tax

print(totalCost) // Output: 140.39
```

---

## API Reference 📚

### Operators

| Operator | Description                       | Example Usage                                    |
|----------|-----------------------------------|-------------------------------------------------|
| `=>`     | Thread-first operator            | `value => function`                             |
| `=>>`    | Thread-last operator             | `value =>> function`                            |
| `~=>`    | Thread-as operator               | `value ~=> { $0 * 2 }`                          |

### Customization

You can extend the library with your own operators or adapt it for specialized needs.

---

## Why SwiftPipeline? 🤔

- **Declarative and Clean**: Make your Swift code more expressive and easier to read.
- **Inspired by Clojure**: Brings the elegance of threading macros to Swift.
- **Lightweight**: No external dependencies—just pure Swift.

---

## Contributing 🤝

We welcome contributions! Feel free to:

- Submit a bug report or feature request.
- Fork the repository and open a pull request.

---

## License 📜

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgements 🙏

SwiftPipeline is inspired by the threading macros of **Clojure** and aims to bring similar functionality to the Swift ecosystem.

---

Enjoy using SwiftPipeline! 🚀🎉

---
