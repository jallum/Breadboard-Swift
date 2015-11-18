import Foundation


public final class Pin<V> {
    public typealias WireFunc = (Value<V>)->()
    public typealias UnwireFunc = ()->()
    
    public var value: Value<V> {
        didSet {
            OSSpinLockLock(&spinlock)
            let value = self.value
            var next = self.wires
            OSSpinLockUnlock(&spinlock)
            
            if oldValue == value {
                return
            }
            
            while let this = next {
                this.propagate(value)
                next = this.next
            }
        }
    }
    private var unwire: UnwireFunc? {
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
    
    public func wire(propagate: WireFunc) -> UnwireFunc {
        OSSpinLockLock(&spinlock)
        let wire = Wire(next: self.wires, propagate: propagate)
        self.wires = wire
        OSSpinLockUnlock(&spinlock)
        
        propagate(self.value)
        
        return {
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
    }
    
    public func autounwire(with block: UnwireFunc) {
        self.unwire = block
    }
}


private final class Wire<V> {
    var next: Wire<V>?
    let propagate: Pin<V>.WireFunc
    
    init(next: Wire<V>?, propagate: Pin<V>.WireFunc) {
        self.next = next
        self.propagate = propagate
    }
}

