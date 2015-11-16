import Foundation


public final class Pin<V> : Unwireable {
    public var value: Value<V> {
        didSet {
            OSSpinLockLock(&spinlock)
            let value = self.value
            var next = self.wires
            OSSpinLockUnlock(&spinlock)
            
            while let this = next {
                this.pass(value)
                next = this.next
            }
        }
    }
    public var unwire: (()->())? {
        didSet {
            if let unwire = oldValue {
                unwire()
            }
        }
    }
    private var spinlock: OSSpinLock = OS_SPINLOCK_INIT
    private var wires: Wire<V>?
    
    deinit {
        if let unwire = unwire {
            unwire()
        }
    }
    
    public init() {
        self.value = .Invalid
    }
    
    public init(_ value: V) {
        self.value = .Valid(value: value)
    }

    public func set(value: V) {
        self.value = .Valid(value: value)
    }

    public func set(error: ErrorType) {
        self.value = .Error(error: error)
    }
    
    public func unset() {
        self.value = .Invalid
    }

    public func wire(var to object: Unwireable, pass: (Value<V>)->()) -> Self {
        OSSpinLockLock(&spinlock)
        let wire = Wire(next: self.wires, pass: pass)
        self.wires = wire
        OSSpinLockUnlock(&spinlock)
        
        object.unwire = {
            OSSpinLockLock(&self.spinlock)
            if let first = self.wires {
                if first === wire {
                    self.wires = first.next
                } else {
                    var last = first
                    while let next = last.next {
                        if next === wire {
                            last.next = next.next
                            break
                        }
                        last = next
                    }
                }
            }
            OSSpinLockUnlock(&self.spinlock)
        }

        pass(self.value)
        
        return self
    }
    
    public func wire<R>(to pin: Pin<R> = Pin(), pass: (V) throws -> (R)) -> Pin<R> {
        wire(to: pin) { [weak pin] value in
            if let pin = pin {
                switch value {
                case .Valid(let valid):
                    do {
                        pin.value = .Valid(value: try pass(valid))
                    } catch (let error) {
                        pin.value = .Error(error: error)
                    }
                case .Error(let error):
                    pin.value = .Error(error: error)
                case .Invalid:
                    pin.value = .Invalid
                }
            }
        }
        return pin
    }
}


private final class Wire<V> {
    var next: Wire<V>?
    let pass: (Value<V>)->()
    
    init(next: Wire<V>?, pass: (Value<V>)->()) {
        self.next = next
        self.pass = pass
    }
}

