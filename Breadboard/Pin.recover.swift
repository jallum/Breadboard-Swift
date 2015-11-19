

public extension Pin {
    public func recover(from sender: Pin<V>, _ convert: (ErrorType) throws -> (V)) -> Pin<V> {
        let unwire = sender.wire { [weak self] value in
            guard let receiver = self else {
                return
            }
            
            switch value {
            case .Valid, .Invalid:
                receiver.value = value
            case .Error(let error):
                do {
                    receiver.value = .Valid(try convert(error))
                } catch (let thrown) {
                    receiver.value = .Error(thrown)
                }
            }
        }
        
        self.autounwire(with: unwire)
        
        return self
    }
    
    public func recover(to pin: Pin<V> = Pin(), _ convert: (ErrorType) throws -> (V)) -> Pin<V> {
        return pin.recover(from: self, convert)
    }
}