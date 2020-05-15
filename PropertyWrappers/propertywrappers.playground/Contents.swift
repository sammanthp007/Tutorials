import Foundation

struct ConsoleLogged<Value> {
    private var val: Value

    var wrappedValue: Value {
        set {
            val = newValue
            print("Value update to \(newValue)")
        }
        get {
            return val
        }
    }

    init(val: Value) {
        self.val = val
    }
}

var num = ConsoleLogged<Int>(val: 3)

num.wrappedValue = 7
num.wrappedValue = 8
