import Foundation


public enum Value<V> {
    case Valid(value: V)
    case Error(error: ErrorType)
    case Invalid
}
