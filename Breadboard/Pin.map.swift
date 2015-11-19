

public extension Pin {
    public func map<R>(from sender: Pin<R>, _ f: (R) throws -> (V)) -> Pin<V> {
        let unwire = sender.wire { [weak self] value in
            guard let receiver = self else {
                return
            }
        
            switch value {
            case .Valid(let valid):
                do {
                    receiver.value = .Valid(try f(valid))
                } catch (let error) {
                    receiver.value = .Error(error)
                }
            case .Error(let error):
                receiver.value = .Error(error)
            case .Invalid:
                receiver.value = .Invalid
            }
        }
        
        self.autounwire(with: unwire)
        
        return self
    }
    
    public func map<R>(to pin: Pin<R> = Pin(), _ f: (V) throws -> (R)) -> Pin<R> {
        return pin.map(from: self, f)
    }
}