import Foundation
import Queue


public final class Tap<V>: Unwireable {
    public var value: Value<V> {
        didSet {
            OSSpinLockLock(&spinlock)
            let value = self.value
            let chain = self.chain
            OSSpinLockUnlock(&spinlock)

            let pass = {
                for link in chain {
                    link(value)
                }
            }
            
            if let queue = self.queue {
                queue.async(pass)
            } else {
                pass()
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
    private let queue: Queue?
    private var chain: [(Value<V>)->()] = []
    private var spinlock: OSSpinLock = OS_SPINLOCK_INIT
    
    deinit {
        if let unwire = unwire {
            unwire()
        }
    }
    
    public init(on queue: Queue? = nil, pin: Pin<V>? = nil) {
        self.queue = queue
        self.value = .Invalid
        if let pin = pin {
            self.wire(to: pin)
        }
    }
    
    public func wire(to pin: Pin<V>) {
        pin.wire(to: self) { [weak self] value in
            self?.value = value
        }
    }
    
    public func then(block: (V)->()) -> Self {
        link { value in
            switch value {
            case .Valid(let value):
                block(value)
            default:
                return
            }
        }
        return self
    }

    public func error(block: (ErrorType)->()) -> Self {
        link { value in
            switch value {
            case .Error(let error):
                block(error)
            default:
                return
            }
        }
        return self
    }

    public func invalid(block: ()->()) -> Self {
        link { value in
            switch value {
            case .Invalid:
                block()
            default:
                return
            }
        }
        return self
    }


    //  Private Methods
    
    private func link(link: (Value<V>)->()) {
        OSSpinLockLock(&spinlock)
        self.chain = self.chain + [ link ]
        let value = self.value
        OSSpinLockUnlock(&spinlock)
        
        if let queue = self.queue {
            queue.async { link(value) }
        } else {
            link(value)
        }
    }
}


public extension Pin {
    public func tap(on queue: Queue? = nil) -> Tap<V> {
        return Tap(on: queue, pin: self)
    }
}