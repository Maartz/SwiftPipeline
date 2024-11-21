import Foundation

/// Defines precedence for threading operators with left associativity.
///
/// This precedence group ensures threading operators are evaluated left-to-right
/// and take precedence over basic assignments.
precedencegroup ThreadingPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

/// Defines precedence for bind operators with left associativity.
///
/// This precedence group ensures bind operators are evaluated left-to-right
/// and take precedence over nil-coalescing operations.
precedencegroup BindPrecedence {
    associativity: left
    higherThan: NilCoalescingPrecedence
}

infix operator => : ThreadingPrecedence

/// Passes a value as the first argument to a function.
///
/// The thread-first operator allows for clean sequential transformations of data, where each result is passed
/// as the first argument to the next function.
///
/// - Parameters:
///   - value: The value to transform
///   - function: A function to apply to the value
///
/// - Returns: The result of applying the function to the value
///
/// ## Example
/// ```swift
/// let result = 5 => { $0 * 2 } => String.init
/// // Returns "10"
/// ```
func => <Input, Output>(value: Input, function: (Input) -> Output) -> Output {
    return function(value)
}

/// Accesses a property using Swift's KeyPath syntax.
///
/// The thread-first KeyPath operator provides a convenient way to access properties in a threading chain.
///
/// - Parameters:
///   - value: The root value containing the property
///   - keyPath: The KeyPath to the desired property
///
/// - Returns: The value at the specified KeyPath
///
/// ## Example
/// ```swift
/// struct User { let name: String }
/// let user = User(name: "Alice")
/// let name = user => \.name
/// // Returns "Alice"
/// ```
func => <Root, Value>(value: Root, keyPath: KeyPath<Root, Value>) -> Value {
    return value[keyPath: keyPath]
}

infix operator =>> : ThreadingPrecedence

/// Applies a function to the last argument in a chain.
///
/// The thread-last operator is particularly useful for operations where the value
/// should be the last argument of the function.
///
/// - Parameters:
///   - value: The value to transform
///   - function: A function to apply to the value
///
/// - Returns: The result of applying the function to the value
///
/// ## Example
/// ```swift
/// let numbers = [1, 2, 3]
/// let sum = numbers =>> { $0.reduce(0, +) }
/// // Returns 6
/// ```
func =>> <Input, Output>(value: Input, function: (Input) -> Output) -> Output {
    return function(value)
}

/// Creates a partially applied function with the value as the last argument.
///
/// This variation of the thread-last operator enables partial application and currying.
///
/// - Parameters:
///   - value: The value to be used as the last argument
///   - function: A function that returns another function taking the value
///
/// - Returns: A function waiting for its first argument
///
/// ## Example
/// ```swift
/// func multiply(_ x: Int) -> (Int) -> Int { { $0 * x } }
/// let double = 2 =>> multiply
/// let result = double(3)
/// // Returns 6
/// ```
func =>> <Input, Arg1, Output>(value: Input, function: @escaping (Arg1) -> (Input) -> Output) -> (
    Arg1
) ->
    Output
{
    return { arg1 in function(arg1)(value) }
}

infix operator ~=> : ThreadingPrecedence

/// Applies a transformation with a named parameter.
///
/// The thread-as operator allows for more explicit naming in transformations.
///
/// - Parameters:
///   - value: The value to transform
///   - transform: A transformation function
///
/// - Returns: The transformed value
///
/// ## Example
/// ```swift
/// let result = 5 ~=> { x in
///     x * 2
/// }
/// // Returns 10
/// ```
func ~=> <Value, Result>(_ value: Value, transform: (Value) -> Result) -> Result {
    return transform(value)
}

infix operator <| : ThreadingPrecedence

/// Maps a function over an optional value.
///
/// Applies a transformation to an optional value, preserving the optional context.
///
/// - Parameters:
///   - function: The function to apply
///   - optional: The optional value to transform
///
/// - Returns: An optional containing the transformed value if the input was non-nil
///
/// ## Example
/// ```swift
/// let double: (Int) -> Int = { $0 * 2 }
/// let result = double <| Optional(5)
/// // Returns Optional(10)
/// ```
func <| <T, U>(function: (T) -> U, optional: T?) -> U? {
    return optional.map(function)
}

/// Maps a function over an array.
///
/// Applies a transformation to each element of an array.
///
/// - Parameters:
///   - function: The function to apply to each element
///   - array: The array to transform
///
/// - Returns: An array containing the transformed elements
///
/// ## Example
/// ```swift
/// let double: (Int) -> Int = { $0 * 2 }
/// let result = double <| [1, 2, 3]
/// // Returns [2, 4, 6]
/// ```
func <| <T, U>(function: (T) -> U, array: [T]) -> [U] {
    return array.map(function)
}

/// Wraps a value in an optional.
///
/// - Parameters:
///   - value: The value to wrap
///   - wrap: A function that wraps the value in an optional
///
/// - Returns: The wrapped optional value
///
/// ## Example
/// ```swift
/// let value = 42 <| Optional.init
/// // Returns Optional(42)
/// ```
func <| <T>(value: T, wrap: (T) -> T?) -> T? {
    return wrap(value)
}

private func wrap<T>(_ value: T) -> T? {
    return Optional(value)
}

infix operator <*> : ThreadingPrecedence

/// Applies an optional function to an optional value.
///
/// The applicative operator for optionals, allowing you to apply a wrapped function
/// to a wrapped value.
///
/// - Parameters:
///   - ff: An optional function
///   - fa: An optional value
///
/// - Returns: The result of applying the function to the value, if both exist
///
/// ## Example
/// ```swift
/// let maybeDouble: ((Int) -> Int)? = { $0 * 2 }
/// let result = maybeDouble <*> Optional(5)
/// // Returns Optional(10)
/// ```
func <*> <A, B>(ff: ((A) -> B)?, fa: A?) -> B? {
    guard let f = ff, let a = fa else { return nil }
    return f(a)
}

/// Applies an array of functions to an array of values.
///
/// The applicative operator for arrays, applying each function to each value.
///
/// - Parameters:
///   - ff: An array of functions
///   - fa: An array of values
///
/// - Returns: An array containing all possible combinations of applying the functions to the values
///
/// ## Example
/// ```swift
/// let functions = [{ $0 + 1 }, { $0 * 2 }]
/// let values = [1, 2]
/// let results = functions <*> values
/// // Returns [2, 3, 2, 4]
/// ```
func <*> <A, B>(ff: [(A) -> B], fa: [A]) -> [B] {
    ff.flatMap { f in fa.map { a in f(a) } }
}

infix operator >=> : ThreadingPrecedence

/// Composes two functions that return optionals.
///
/// The Kleisli composition operator, allowing you to chain operations that produce optionals.
///
/// - Parameters:
///   - f: First function returning an optional
///   - g: Second function returning an optional
///
/// - Returns: A composed function that chains both operations
///
/// ## Example
/// ```swift
/// let parseNumber: (String) -> Int? = { Int($0) }
/// let double: (Int) -> Int? = { $0 * 2 }
/// let parse_then_double = parseNumber >=> double
/// let result = parse_then_double("21")
/// // Returns Optional(42)
/// ```
func >=> <A, B, C>(f: @escaping (A) -> B?, g: @escaping (B) -> C?) -> (A) -> C? {
    { a in f(a) >>- g }
}

infix operator <|> : ThreadingPrecedence

/// Provides a fallback value for optional values.
///
/// The alternative operator allows you to specify a default value if the first option is nil.
///
/// - Parameters:
///   - lhs: The primary optional value
///   - rhs: A closure providing the fallback value (evaluated lazily)
///
/// - Returns: The first non-nil value, or nil if both are nil
///
/// ## Example
/// ```swift
/// let result = Optional<Int>.none <|> Optional(42)
/// // Returns Optional(42)
/// ```
func <|> <A>(lhs: A?, rhs: @autoclosure () -> A?) -> A? {
    lhs ?? rhs()
}

infix operator >>- : BindPrecedence

/// Chains optional values with functions that produce optionals.
///
/// The monadic bind operator for optionals, allowing you to chain operations that might fail.
///
/// - Parameters:
///   - a: An optional value
///   - f: A function that takes the unwrapped value and returns an optional
///
/// - Returns: The result of applying the function to the value, if it exists
///
/// ## Example
/// ```swift
/// let value: Int? = 42
/// let result = value >>- { x in x % 2 == 0 ? Optional(x * 2) : nil }
/// // Returns Optional(84)
/// ```
func >>- <A, B>(a: A?, f: @escaping (A) -> B?) -> B? {
    a.flatMap(f)
}

infix operator -<< : BindPrecedence

/// Reverse bind operator for optional values.
///
/// A flipped version of the monadic bind operator, useful when you want to emphasize the transformation.
///
/// - Parameters:
///   - f: A function that returns an optional
///   - a: An optional value
///
/// - Returns: The result of applying the function to the value, if it exists
///
/// ## Example
/// ```swift
/// let double: (Int) -> Int? = { $0 * 2 }
/// let result = double -<< Optional(21)
/// // Returns Optional(42)
/// ```
func -<< <A, B>(f: @escaping (A) -> B?, a: A?) -> B? {
    a.flatMap(f)
}
