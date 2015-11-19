import Foundation


public func reduce<A,B,R>(a: Pin<A>, _ b: Pin<B>, block: (A,B) throws -> R) -> Pin<R> {
    let output = Pin<R>()
    
    var spinlock = OS_SPINLOCK_INIT
    var av: Value<A> = a.value
    var bv: Value<B> = b.value
    
    let tick = { [weak output] in
        guard let output = output else {
            return
        }
        
        OSSpinLockLock(&spinlock)
        let value: Value<R>
        switch (av, bv) {
        case (.Valid(let ax), .Valid(let bx)):
            do {
                value = .Valid(try block(ax, bx))
            } catch (let error) {
                value = .Error(error)
            }
        default:
            switch av {
            case .Error(let error):
                value = .Error(error)
            case .Invalid:
                value = .Invalid
            default:
                switch bv {
                case .Error(let error):
                    value = .Error(error)
                default:
                    value = .Invalid
                }
            }
        }
        OSSpinLockUnlock(&spinlock)
        output.value = value
    }
    
    tick()
    
    let au = a.wire { value in
        av = value
        tick()
    }
    let bu = b.wire { value in
        bv = value
        tick()
    }
    
    output.autounwire {
        au()
        bu()
    }
    
    return output
}

public func reduce<A,B,C,R>(a: Pin<A>, _ b: Pin<B>, _ c: Pin<C>, block: (A,B,C) throws -> R) -> Pin<R> {
    let output = Pin<R>()
    
    var spinlock = OS_SPINLOCK_INIT
    var av: Value<A> = a.value
    var bv: Value<B> = b.value
    var cv: Value<C> = c.value
    
    let tick = { [weak output] in
        guard let output = output else {
            return
        }
        
        OSSpinLockLock(&spinlock)
        let value: Value<R>
        switch (av, bv, cv) {
        case (.Valid(let ax), .Valid(let bx), .Valid(let cx)):
            do {
                value = .Valid(try block(ax, bx, cx))
            } catch (let error) {
                value = .Error(error)
            }
        default:
            switch av {
            case .Error(let error):
                value = .Error(error)
            case .Invalid:
                value = .Invalid
            default:
                switch bv {
                case .Error(let error):
                    value = .Error(error)
                case .Invalid:
                    value = .Invalid
                default:
                    switch cv {
                    case .Error(let error):
                        value = .Error(error)
                    default:
                        value = .Invalid
                    }
                }
            }
        }
        OSSpinLockUnlock(&spinlock)
        output.value = value
    }
    
    tick()
    
    let au = a.wire { value in
        av = value
        tick()
    }
    let bu = b.wire { value in
        bv = value
        tick()
    }
    let cu = c.wire { value in
        cv = value
        tick()
    }
    
    output.autounwire {
        au()
        bu()
        cu()
    }
    
    return output
}

public func reduce<A,B,C,D,R>(a: Pin<A>, _ b: Pin<B>, _ c: Pin<C>, _ d: Pin<D>, block: (A,B,C,D) throws -> R) -> Pin<R> {
    let output = Pin<R>()
    
    var spinlock = OS_SPINLOCK_INIT
    var av: Value<A> = a.value
    var bv: Value<B> = b.value
    var cv: Value<C> = c.value
    var dv: Value<D> = d.value
    
    let tick = { [weak output] in
        guard let output = output else {
            return
        }
        
        OSSpinLockLock(&spinlock)
        let value: Value<R>
        switch (av, bv, cv, dv) {
        case (.Valid(let ax), .Valid(let bx), .Valid(let cx), .Valid(let dx)):
            do {
                value = .Valid(try block(ax, bx, cx, dx))
            } catch (let error) {
                value = .Error(error)
            }
        default:
            switch av {
            case .Error(let error):
                value = .Error(error)
            case .Invalid:
                value = .Invalid
            default:
                switch bv {
                case .Error(let error):
                    value = .Error(error)
                case .Invalid:
                    value = .Invalid
                default:
                    switch cv {
                    case .Error(let error):
                        value = .Error(error)
                    case .Invalid:
                        value = .Invalid
                    default:
                        switch dv {
                        case .Error(let error):
                            value = .Error(error)
                        default:
                            value = .Invalid
                        }
                    }
                }
            }
        }
        OSSpinLockUnlock(&spinlock)
        output.value = value
    }
    
    tick()
    
    let au = a.wire { value in
        av = value
        tick()
    }
    let bu = b.wire { value in
        bv = value
        tick()
    }
    let cu = c.wire { value in
        cv = value
        tick()
    }
    let du = d.wire { value in
        dv = value
        tick()
    }
    
    output.autounwire {
        au()
        bu()
        cu()
        du()
    }
    
    return output
}
