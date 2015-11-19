

public enum CycleError : ErrorType {
    case EndOfSequence
}


public func cycle<V>(arrayPin: Pin<[V]>, inout next: ()->(), endOfSequenceError: ErrorType = CycleError.EndOfSequence) -> Pin<V> {
    let output = Pin<V>()
    
    var generator: IndexingGenerator<[V]>? = nil
    
    next = { [weak output] in
        guard let output = output else {
            return
        }
        if let v = generator?.next() {
            output.value = .Valid(v)
        } else {
            output.value = .Error(endOfSequenceError)
        }
    }

    output.autounwire(with: arrayPin.wire { [weak output] value in
        guard let output = output else {
            return
        }
        switch value {
        case .Valid(let array):
            generator = array.generate()
            next()
        case .Invalid:
            output.value = .Invalid
        case .Error(let error):
            output.value = .Error(error)
        }
    })
    
    return output
}
