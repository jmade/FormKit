//
//  InputValue.swift
//  
//
//  Created by Justin Madewell on 9/30/20.
//

import UIKit

// MARK: - MapValue -
public struct InputValue {
    
    public enum InputType {
        case zipcode, phoneNumber, password, cellPhoneNumber
    }
    public var type: InputType = .zipcode
    var identifier: UUID = UUID()
    public var value: String? = nil
    /// TableSelectable
    public var isSelectable: Bool = false
    /// CustomKeyProviable
    public var customKey: String? = nil
    public var placeholder:String? = nil
    public var useDirectionButtons:Bool = true
    public var textPattern:String? = nil
    public var validators: [Validator] = []
}
    

extension InputValue {
    
    public init(type: InputType,customKey:String?,value:Int?) {
        self.type = type
        self.customKey = customKey
        if let value = value {
            if value > 1_000_000_0000 {
                self.value = "\( value - 1_000_000_0000 )"
            }
            self.value = "\(value)"
        }
    }
    
    public init(type: InputType,customKey:String?,value:String?) {
        self.type = type
        self.customKey = customKey
        self.value = value
    }
    
    
    public init(_ type: InputType,_ customKey:String?,_ placeholder: String? = nil) {
        self.type = type
        self.customKey = customKey
        self.placeholder = placeholder
    }
    
    
    public init(phoneNumber:String,_ customKey:String?) {
        self.type = .phoneNumber
        self.customKey = customKey
        self.value = phoneNumber
    }
    
    public init(zipCode:String,_ customKey:String?) {
           self.type = .zipcode
           self.customKey = customKey
           self.value = zipCode
       }
    
    
    
}


extension InputValue {
    
    var title:String {
        switch type {
        case .phoneNumber:
            return "Phone Number"
        case .cellPhoneNumber:
            return "Cell Phone Number"
        case .zipcode:
            return "Zip Code"
        case .password:
            return "Password"
        }
    }
    
    
    var formatedTextPattern: String {
        guard let pattern = textPattern else {
            switch type {
            case .phoneNumber, .cellPhoneNumber:
                return "(###) ###-####"
            case .zipcode:
                return "#####"
            case .password:
                return "########"
            }
        }
        return pattern
    }
    
    
    var displayValue:String {
        switch type {
        case .phoneNumber, .cellPhoneNumber:
            if let val = value {
                return "\(val)"
            }
        case .zipcode:
            if let val = value {
                return "\(val)"
            }
        case .password:
            break
        }
        return ""
    }
    
}




extension InputValue {
    
    func newWith(_ newValue:String) -> InputValue {
        InputValue(type: self.type, identifier: UUID(), value: newValue, isSelectable: self.isSelectable, customKey: self.customKey, placeholder: self.placeholder, useDirectionButtons: self.useDirectionButtons, textPattern: self.textPattern)
    }
    
}


//// MARK: - FormValue -
extension InputValue: FormValue, TableViewSelectable {
    
    public var formItem: FormItem {
        .input(self)
    }
    
    
    public func encodedValue() -> [String : String] {
        if let val = value {
            return [ (customKey ?? title) : "\(val)"]
        }
        return [ (customKey ?? title) : ""]
    }
    
}



extension InputValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: InputValue, rhs: InputValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}




//: MARK: - FormValueDisplayable -
extension InputValue: FormValueDisplayable {
    
    public typealias Cell = InputValueCell
    public typealias Controller = FormController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        /*  */
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    
}


extension InputValue {
    
    static func Random() -> InputValue {
        if Bool.random() {
            return InputValue(.phoneNumber, nil)
        } else {
            return InputValue(.zipcode, nil)
        }
    }
    
}














// MARK: InputValueCell
public final class InputValueCell: UITableViewCell, Activatable {
    
    static let identifier = "com.jmade.FormKit.InputValueCell.identifier"
    
    private lazy var approvedPasswordSet:CharacterSet = {
        let sets:[CharacterSet] = [
            .alphanumerics,
            .letters,
            .capitalizedLetters,
            .lowercaseLetters,
            .uppercaseLetters,
            .decimalDigits,
            .punctuationCharacters
        ]
        
        var megaSet = CharacterSet()
        
        for set in sets {
            megaSet.formUnion(set)
        }
        return megaSet
    }()
    
    
    var formatter:DefaultTextInputFormatter? = nil
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.returnKeyType = .done

        textField.delegate = self
        textField.keyboardType = .numberPad
        
        textField.textAlignment = .right
        textField.borderStyle = .none
        textField.clearButtonMode = .never
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        if #available(iOS 13.0, *) {
            textField.textColor = .secondaryLabel
        } else {
            textField.textColor = .gray
        }
        textField.addTarget(self, action: #selector(textFieldTextChanged(textField:)), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        return textField
    }()
    
    
    //private let passwordField = HideShowPasswordTextField()
    
    private lazy var passwordField: HideShowPasswordTextField = {
        let textField = HideShowPasswordTextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.font = UIFont.preferredFont(forTextStyle: .headline)
        if #available(iOS 13.0, *) {
            textField.rightView?.tintColor = .label
            textField.textColor = .label
        } else {
            textField.textColor = .black
            textField.rightView?.tintColor = .black
        }
        textField.textAlignment = .left
        textField.borderStyle = .none // .roundedRect
        textField.delegate = self
        
        textField.clearButtonMode = .never
        textField.keyboardType = .default
        textField.isSecureTextEntry = true
        textField.returnKeyType = .default
        //textField.placeholder = "Password"
        textField.addTarget(self, action: #selector(textFieldTextChanged(textField:)), for: .editingChanged)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        return textField
    }()
    
    
    
    var formValue : InputValue? {
        didSet {
            if let inputValue = formValue {
                
                if inputValue.type == .password {
                    titleLabel.text = nil
                    passwordField.placeholder = "Password"
                    passwordField.text = inputValue.value
                } else {
                    formatter = DefaultTextInputFormatter(textPattern: inputValue.formatedTextPattern)
                    titleLabel.text = inputValue.title
                    textField.text = inputValue.displayValue
                    textField.placeholder = inputValue.placeholder
                }
                
                layout()
            }
        }
    }
    
    
    private var didLayout:Bool = false
    
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
        textField.text = nil
        titleLabel.text = nil
        indexPath = nil
        passwordField.text = nil
    }
    
    
    func layout(){
        guard let inputValue = formValue, didLayout == false else { return }
        
        evaluateButtonBar()
        
        if inputValue.type == .password {
            NSLayoutConstraint.activate([
                passwordField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                passwordField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                passwordField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: passwordField.bottomAnchor),
                
                //passwordField.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
                
                textField.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                textField.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            ])
        }
        
        didLayout = true
    }
    
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        
        if selected {
            guard let inputValue = formValue else { return }
            if inputValue.type == .password {
                passwordField.becomeFirstResponder()
            } else {
                textField.becomeFirstResponder()
            }
        }
    }
    
    
    func evaluateButtonBar(){
        guard let inputValue = formValue else { return }
        if inputValue.useDirectionButtons {
            // Toolbar
            let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: 44.0)))
            let previous = UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction))
            let next = UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
            bar.items = [previous,next,spacer,done]
            
            bar.sizeToFit()
            if inputValue.type == .password {
                passwordField.inputAccessoryView = bar
            } else {
                textField.inputAccessoryView = bar
            }
            
            
            
        }
    }
    
    
    @objc
    func doneAction(){
        endTextEditing()
    }
    
    @objc
    func previousAction(){
        if let path = indexPath {
            updateFormValueDelegate?.toggleTo(.previous, path)
        }
    }
    
    @objc
    func nextAction(){
        if let path = indexPath {
            updateFormValueDelegate?.toggleTo(.next, path)
        }
    }
    
    
    public func activate(){
        guard let inputValue = formValue else { return }
        if inputValue.type == .password {
            passwordField.becomeFirstResponder()
        } else {
            textField.becomeFirstResponder()
        }
    }
    
    @objc
    func textFieldTextChanged(textField:UITextField) {
        print(" textFieldTextChanged Firing")
        if let text = textField.text {
            guard let inputValue = formValue else { return }
            //print("TEXT: \(text)")
            updateFormValueDelegate?.updatedFormValue(inputValue.newWith(text), indexPath)
        }
    }
    
    private func endTextEditing(){
        guard let inputValue = formValue else { return }
        if inputValue.type == .password {
            passwordField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
}



extension InputValueCell: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endTextEditing()
        return true
    }
    
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let inputValue = formValue else { return false }
        
        switch inputValue.type {
        case .phoneNumber, .cellPhoneNumber:
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
        case .zipcode:
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
        case .password:
            guard approvedPasswordSet.isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
        }
        
        
        if let formatter = formatter {
            let result = formatter.formatInput(currentText: textField.text ?? "", range: range, replacementString: string)
            textField.text = result.formattedText
            textField.setCursorLocation(result.caretBeginOffset)
            if let newValue = textField.text {
                let newInputValue = inputValue.newWith(newValue)
                updateFormValueDelegate?.updatedFormValue(newInputValue, indexPath)
            }
            return false
        } else {
            if let newValue = textField.text {
                let newInputValue = inputValue.newWith(newValue)
                updateFormValueDelegate?.updatedFormValue(newInputValue, indexPath)
            }
            
            return true
        }
        
    }
    
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
       endTextEditing()
    }
    
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}

