 import Foundation

public protocol Rule {
    associatedtype Option
    
    var errorMessage: String { get }
    var attributedMessage: NSAttributedString { get }
    
    init(_ option: Option, error: String)
    
    func validate(for value: ValidatableType?) -> Bool
}

public struct StringRule: Rule {
    
    public var attributedMessage: NSAttributedString {
        if #available(iOS 13.0, *) {
            return NSAttributedString.validationAS(errorMessage, config: configuration)
        } else {
           return NSAttributedString()
        }
    }
    
    public let option: Option
    public let errorMessage: String
    
    public var configuration: ValidationConfiguration = .info
    
    public enum NilBehavior {
        case pass, fail
    }
    
    public var behavior:NilBehavior = .pass
    
    
    public init(_ option: Option, error: String) {
        self.option = option
        self.errorMessage = error
    }
    
    public init(_ option: Option, error: String,_ behavior:NilBehavior = .pass) {
        self.option = option
        self.errorMessage = error
        self.behavior = behavior
    }
    
    public init(_ option: Option, error: String,_ configuration: ValidationConfiguration = .info) {
        self.option = option
        self.errorMessage = error
        self.configuration = configuration
    }
    
    public init(_ option: Option, error: String, behavior:NilBehavior = .pass,configuration: ValidationConfiguration = .info) {
        self.option = option
        self.errorMessage = error
        self.configuration = configuration
        self.behavior = behavior
    }
    
    
    public func validate(for value: ValidatableType?) -> Bool {
        
        
        switch option {
        case .notEmpty:
            guard let value = value as? String else { return behavior == .pass }
            return value.isEmpty ? behavior == .pass : true
        case .max(let maxValue):
            guard let value = value as? String else { return behavior == .pass }
            if value.isEmpty { return behavior == .pass }
            return value.count <= maxValue
        case .min(let minValue):
            guard let value = value as? String else { return behavior == .pass }
            if value.isEmpty { return behavior == .pass }
            return value.count >= minValue
        case .regex(let regex):
            guard let value = value as? String else { return behavior == .pass }
            if value.isEmpty { return behavior == .pass }
            return value.range(of: regex, options: .regularExpression) != nil
        }
    }
    
    public enum Option {
        case notEmpty
        case max(Int)
        case min(Int)
        case regex(String)
    }
    
    
    public static func info(_ option: Option,_ error: String) -> StringRule {
        StringRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .info
        )
    }
    
    public static func warning(_ option: Option,_ error: String) -> StringRule {
        StringRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .warning
        )
    }
    
    public static func error(_ option: Option,_ error: String) -> StringRule {
        StringRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .error
        )
    }

    
   public static var required:StringRule {
        StringRule(
            .notEmpty,
            error: "Required",
            behavior: .fail,
            configuration: .info
        )
    }
    
    
}


public struct IntRule: Rule {
    
    public var attributedMessage: NSAttributedString {
        if #available(iOS 13.0, *) {
            return NSAttributedString.validationAS(errorMessage, config: configuration)
        } else {
           return NSAttributedString()
        }
    }
    
    public let option: Option
    public let errorMessage: String
    public var configuration: ValidationConfiguration = .info
    
    public enum NilBehavior {
        case pass, fail
    }
    
    public var behavior:NilBehavior = .pass
    
    public init(_ option: Option, error: String) {
        self.option = option
        self.errorMessage = error
    }
    
    public init(_ option: Option, error: String,_ behavior:NilBehavior = .pass) {
        self.option = option
        self.errorMessage = error
        self.behavior = behavior
    }
    
    public init(_ option: Option, error: String,_ configuration: ValidationConfiguration = .info) {
        self.option = option
        self.errorMessage = error
        self.configuration = configuration
    }
    
    public init(_ option: Option, error: String, behavior:NilBehavior = .pass,configuration: ValidationConfiguration = .info) {
        self.option = option
        self.errorMessage = error
        self.configuration = configuration
        self.behavior = behavior
    }
    
    public func validate(for value: ValidatableType?) -> Bool {
        switch option {
        case .notEmpty:
            guard let _ = value as? Int else { return behavior == .pass }
            return true
        case .notZero:
            guard let value = value as? Int else { return behavior == .pass }
            return value != 0
        case .max(let maxValue):
            guard let value = value as? Int else { return behavior == .pass }
            return value <= maxValue
        case .min(let minValue):
            guard let value = value as? Int else { return behavior == .pass }
            return value >= minValue
        }
    }
    
    @available(iOS 13.0, *)
    func attributedString() -> NSAttributedString {
        NSAttributedString.validationAS(errorMessage, config: configuration)
    }
    
    
    public enum Option {
        case notEmpty
        case notZero
        case max(Int)
        case min(Int)
    }
    
    public static func info(_ option: Option,_ error: String) -> IntRule {
        IntRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .info
        )
    }
    
    public static func warning(_ option: Option,_ error: String) -> IntRule {
        IntRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .warning
        )
    }
    
    public static func error(_ option: Option,_ error: String) -> IntRule {
        IntRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .error
        )
    }
    
    
    /// Simple Rule with **"Required"** as the message
    ///
    /// Uses the`.fail` case for the `NilBehavior`
    /// Uses a `.default` `ValidationConfiguration`
    ///
    public static var required:IntRule {
        IntRule(
            .notEmpty,
            error: "Required",
            behavior: .fail,
            configuration: .info
        )
    }
    
    
    
    
    
    
    
    
    
}


public struct FloatRule: Rule {
    
    public var attributedMessage: NSAttributedString {
        if #available(iOS 13.0, *) {
            return NSAttributedString.validationAS(errorMessage, config: configuration)
        } else {
           return NSAttributedString()
        }
    }
    
    public let option: Option
    public let errorMessage: String
    
    public var configuration: ValidationConfiguration = .info
    
    public enum NilBehavior {
        case pass, fail
    }
    
    public var behavior:NilBehavior = .pass
    
    public init(_ option: Option, error: String) {
        self.option = option
        self.errorMessage = error
    }
    
    public init(_ option: Option, error: String,_ behavior:NilBehavior = .pass) {
        self.option = option
        self.errorMessage = error
        self.behavior = behavior
    }
    
    public init(_ option: Option, error: String,_ configuration: ValidationConfiguration = .info) {
        self.option = option
        self.errorMessage = error
        self.configuration = configuration
    }
    
    public init(_ option: Option, error: String, behavior:NilBehavior = .pass,configuration: ValidationConfiguration = .info) {
        self.option = option
        self.errorMessage = error
        self.configuration = configuration
        self.behavior = behavior
    }
    
    
    public func validate(for value: ValidatableType?) -> Bool {
        
        switch option {
        case .notEmpty:
            guard let _ = value as? Double else { return behavior == .pass }
            return true
        case .notZero:
            guard let value = value as? Double else { return behavior == .pass }
            return !value.isZero
        case .max(let maxValue):
            guard let value = value as? Double else { return behavior == .pass }
            return value <= maxValue
        case .min(let minValue):
            guard let value = value as? Double else { return behavior == .pass }
            return value >= minValue
        }
    }
    
    
    @available(iOS 13.0, *)
    func attributedString() -> NSAttributedString {
        NSAttributedString.validationAS(errorMessage, config: configuration)
    }
    
    
    
    public enum Option {
        case notEmpty
        case notZero
        case max(Double)
        case min(Double)
    }
    
    
    public static func info(_ option: Option,_ error: String) -> FloatRule {
        FloatRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .info
        )
    }
    
    public static func warning(_ option: Option,_ error: String) -> FloatRule {
        FloatRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .warning
        )
    }
    
    public static func error(_ option: Option,_ error: String) -> FloatRule {
        FloatRule(
            option,
            error: error,
            behavior: .pass,
            configuration: .error
        )
    }
    
    
    
   public static var required:FloatRule {
        FloatRule(
            .notEmpty,
            error: "Required",
            behavior: .fail,
            configuration: .info
        )
    }
    
}







public protocol ValidatableType { }

extension String: ValidatableType { }
extension Int: ValidatableType { }
extension Double: ValidatableType { }


public class Validator {
    
    private let identifier = UUID()
    
    public let label: String
    
    private let _validateMessages: () -> [NSAttributedString]
    
    public var attributedMessages:[NSAttributedString] {
        return _validateMessages()
    }
    
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
        self._validateMessages = {
            return rules
                .filter { !$0.validate(for: value) }
                .map { $0.attributedMessage }
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
    
    public var attributedMessage:NSAttributedString {
        
        let messages = validators.map({ $0.attributedMessages }).reduce([],+)
        if messages.count == 1 {
            return messages.first!
        }
        
        var newMessages = messages
        
        let last = newMessages.popLast()
        
        var newAttributed:[NSAttributedString] = newMessages.map({ attrib in
            let new = NSMutableAttributedString(string: "")
            new.append(attrib)
            new.append(NSAttributedString(string: "\n"))
            return NSAttributedString(attributedString: new)
        })
        
        if let last = last {
            newAttributed.append(last)
        }
        
        let attrib = NSMutableAttributedString(string: "")
        
        newAttributed.forEach({
            attrib.append($0)
        })
        
        return NSAttributedString(attributedString: attrib)
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
