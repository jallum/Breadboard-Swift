

public extension Pin {
    public func map<R>(from sender: Pin<R>, _ convert: (R) throws -> (V)) -> Pin<V> {
        self.autounwire(with: sender.wire { [weak self] value in
            guard let receiver = self else {
                return
            }
            switch value {
            case .Valid(let valid):
                do {
                    receiver.value = .Valid(value: try convert(valid))
                } catch (let error) {
                    receiver.value = .Error(error: error)
                }
            case .Error(let error):
                receiver.value = .Error(error: error)
            case .Invalid:
                receiver.value = .Invalid
            }
        })
        return self
    }
    
    public func map<R>(to pin: Pin<R> = Pin(), _ convert: (V) throws -> (R)) -> Pin<R> {
        return pin.map(from: self, convert)
    }
}