import Foundation

/// You can think of property wrapper as a regular property, which delegates its get and set to some
/// other type.
///
/// There are two requirements for a property wrapper type:
/// 1. It must be defined with the attribute @propertyWrapper.
/// 2. It must have a wrappedValue property.
@propertyWrapper
struct ConsoleLogged<Type> {
    private var val: Type

    init(wrappedValue: Type) {
        self.val = wrappedValue
    }

    var wrappedValue: Type {
        set {
            val = newValue
            print("Value update to \(newValue)")
        }
        get { return val }
    }

    func usefulFunc() {
        print("Useful wrapper method")
    }
}

// Logging value changes (without using property wrapper)
var num = ConsoleLogged<Int>(wrappedValue: 3)
num.wrappedValue = 7
num.wrappedValue = 8

// Property wrappers are not yet supported in top-level code
struct SecondLevelCode {
    // The attribute @ConsoleLogged is a syntactic sugar, which translates into the definition above
    @ConsoleLogged var cLoggedNum: Int = 4

    func doSomethingUseful() {
        // We can access the wrapper type by adding an underscore to the variable name
        _cLoggedNum.usefulFunc()
    }
}

var num2 = SecondLevelCode()
num2.cLoggedNum = 5
num2.cLoggedNum = 6

num2.doSomethingUseful()
