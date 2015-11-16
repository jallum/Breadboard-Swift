import Foundation
import Quick
import Nimble
@testable import Breadboard


class PinSpec : QuickSpec {
    override func spec() {
        describe("Pin") {
            context("with an integer pin called A") {
                let a = Pin(23)
                
                context("a string pin derived A, called B") {
                    let b = a.wire {
                        "\($0)"
                    }
                    
                    it("assigns the correct value on setup") {
                        switch b.value {
                        case .Valid(let value):
                            expect(value).to(equal("23"))
                        default:
                            fail()
                        }
                    }
                    
                    context("with a tap derived from B") {
                        var t: Tap<String>? = b.tap()
                        var s = ""
                        
                        it("assigns the correct value on setup") {
                            t!.then { value in
                                s = value
                            }
                            expect(s).to(equal("23"))
                        }
                        
                        it("propagates changes to A") {
                            a.set(32)
                            expect(s).to(equal("32"))
                        }
                        
                        it("unwires properly when garbage-collected") {
                            t = nil
                            a.set(23)
                            expect(s).to(equal("32"))
                        }
                    }
                }
            }
        }
    }
}