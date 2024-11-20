import Foundation

precedencegroup ThreadingPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator => : ThreadingPrecedence

func => <Input, Output>(value: Input, function: (Input) -> Output) -> Output {
    return function(value)
}

func => <Root, Value>(value: Root, keyPath: KeyPath<Root, Value>) -> Value {
    return value[keyPath: keyPath]
}

infix operator =>> : ThreadingPrecedence

func =>> <Input, Output>(value: Input, function: (Input) -> Output) -> Output {
    return function(value)
}

func =>> <Input, Arg1, Output>(value: Input, function: @escaping (Arg1) -> (Input) -> Output) -> (
    Arg1
) ->
    Output
{
    return { arg1 in function(arg1)(value) }
}

infix operator ~=> : ThreadingPrecedence

func ~=> <Value, Result>(_ value: Value, transform: (Value) -> Result) -> Result {
    return transform(value)
}

infix operator <| : ThreadingPrecedence

func <| <T, U>(function: (T) -> U, optional: T?) -> U? {
    return optional.map(function)
}

func <| <T, U>(function: (T) -> U, array: [T]) -> [U] {
    return array.map(function)
}

func <| <T>(value: T, wrap: (T) -> T?) -> T? {
    return wrap(value)
}

private func wrap<T>(_ value: T) -> T? {
    return Optional(value)
}
