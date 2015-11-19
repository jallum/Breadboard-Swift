

public extension Pin {
    public func settle(from sender: Pin<V>) -> Pin<V> {
        var currentValue = sender.value
        
        let unwire = sender.wire { [weak self] value in
            guard let receiver = self else {
                return
            }
            
            guard value != currentValue else {
                return
            }
            
            currentValue = value
            receiver.value = value
        }
        
        self.autounwire(with: unwire)
        
        return self
    }
    
    public func settle(to pin: Pin<V> = Pin()) -> Pin<V> {
        return pin.settle(from: self)
    }
}