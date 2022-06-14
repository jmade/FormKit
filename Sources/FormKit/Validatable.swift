 import Foundation

public protocol Rule {
    associatedtype Option
    
    var errorMessage: String { get }
    
    init(_ option: Option, error: String)
    
    func validate(for value: ValidatableType?) -> Bool
}

public struct StringRule: Rule {
    public let option: Option
    public let errorMessage: String
    
    public init(_ option: Option, error: String) {
        self.option = option
        self.errorMessage = error
    }
    
    public func validate(for value: ValidatableType?) -> Bool {
        guard let value = value as? String else { return false }
        
        switch option {
        case .notEmpty:
            return !value.isEmpty
        case .max(let maxValue):
            return value.count <= maxValue
        case .min(let minValue):
            return value.count >= minValue
        case .regex(let regex):
            if value.isEmpty { return true }
            return value.range(of: regex, options: .regularExpression) != nil
        }
    }
    
    public enum Option {
        case notEmpty
        case max(Int)
        case min(Int)
        case regex(String)
    }
}

public struct IntRule: Rule {
    public let option: Option
    public let errorMessage: String
    
    public init(_ option: Option, error: String) {
        self.option = option
        self.errorMessage = error
    }
    
    public func validate(for value: ValidatableType?) -> Bool {
        
        switch option {
        case .notEmpty:
            guard let _ = value as? Int else { return false }
            return true
        case .notZero:
            guard let value = value as? Int else { return false }
            return value != 0
        case .max(let maxValue):
            guard let value = value as? Int else { return false }
            return value <= maxValue
        case .min(let minValue):
            guard let value = value as? Int else { return false }
            return value >= minValue
        }
    }
    
    public enum Option {
        case notEmpty
        case notZero
        case max(Int)
        case min(Int)
    }
}


public struct FloatRule: Rule {
    public let option: Option
    public let errorMessage: String
    
    public init(_ option: Option, error: String) {
        self.option = option
        self.errorMessage = error
    }
    
    public func validate(for value: ValidatableType?) -> Bool {
        
        switch option {
        case .notEmpty:
            guard let _ = value as? Double else { return false }
            return true
        case .notZero:
            guard let value = value as? Double else { return false }
            return !value.isZero
        case .max(let maxValue):
            guard let value = value as? Double else { return false }
            return value <= maxValue
        case .min(let minValue):
            guard let value = value as? Double else { return false }
            return value >= minValue
        }
    }
    
    public enum Option {
        case notEmpty
        case notZero
        case max(Double)
        case min(Double)
    }
}







public protocol ValidatableType { }

extension String: ValidatableType { }
extension Int: ValidatableType { }
extension Double: ValidatableType { }


public class Validator {
    
    private let identifier = UUID()
    
    public let label: String
    private let _validate: () -> [String]
    
    public var errorMessages: [String] {
        return _validate()
    }
    
    public init<V: ValidatableType, R: Rule>(_ label: String, _ value: V?, rules: [R]) {
        self.label = label
        self._validate = {
            return rules
                .filter { !$0.validate(for: value) }
                .map { $0.errorMessage }
        }
    }
}

extension Validator: Hashable {
    
    public static func == (lhs: Validator, rhs: Validator) -> Bool {
        lhs.label == rhs.label && lhs.errorMessages == rhs.errorMessages
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
}


protocol Validatable {
    var valid: Bool { get }
    var invalid: Bool { get }
    var errors: [String : [String]] { get }
    var validators: [Validator] { get }
}


extension Validatable {
    public var valid: Bool {
        return errors.count == 0
    }
    
    public var invalid: Bool {
        return !valid
    }
    
    public var errors: [String : [String]] {
        var dict = [String : [String]]()
        
        for validator in validators {
            let errorMessages = validator.errorMessages
            if !errorMessages.isEmpty {
                dict[validator.label] = errorMessages
            }
        }
        
        return dict
    }
    
    public var errorMessages:[String] {
        validators.map({ $0.errorMessages }).reduce([],+)
    }
    
}


/*
////////////////////////////////
// TESTING
////////////////////////////////

struct Person {
    var name: String
    var age: Int?
}

extension Person: Validatable {
    var validators: [Validator] {
        return [
            Validator("name", self.name, rules: [
                StringRule(.notEmpty, error: "Name can't be empty."),
                StringRule(.max(20), error: "Name can't be longer than 20 characters."),
                StringRule(.regex("^\\b[a-zA-Z-]+\\b$"), error: "Name contains invalid characters."),
            ]),
            Validator("age", self.age, rules: [
                IntRule(.notZero, error: "Age can't be zero."),
                IntRule(.max(150), error: "Age can't be greater than 150."),
            ]),
        ]
    }
}

let person = Person(name: "", age: 0)

if person.invalid {
    print(person.errors)
    // -> ["name": ["Name can't be empty."], "age": ["Age can't be zero."]]
}

let person2 = Person(name: "A person with a name that is waaaay too long +&%$", age: nil)

if person2.invalid {
    print(person2.errors)
    // -> ["name": ["Name can't be longer than 20 characters.", "Name contains invalid characters."]]
}
*/
