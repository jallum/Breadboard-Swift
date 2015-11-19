import Foundation


public enum Value<V> : Equatable {
    case Valid(V)
    case Error(ErrorType)
    case Invalid
}


public func ==<V:Equatable>(lhs: Value<V>, rhs: Value<V>) -> Bool {
    switch (lhs, rhs) {
    case (.Valid(let l), .Valid(let r)):
        return l == r
    case (.Error(let l), .Error(let r)):
        return l._domain == r._domain && l._code == r._code
    case (.Invalid, .Invalid):
        return true
    default:
        return false
    }
}


public func ==<V>(lhs: Value<V>, rhs: Value<V>) -> Bool {
    switch (lhs, rhs) {
    case (.Valid, .Valid):
        return false
    case (.Error(let l), .Error(let r)):
        return l._domain == r._domain && l._code == r._code
    case (.Invalid, .Invalid):
        return true
    default:
        return false
    }
}
