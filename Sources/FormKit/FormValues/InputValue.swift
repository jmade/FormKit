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
        case zipcode, phoneNumber
    }
    var type: InputType = .zipcode
    var identifier: UUID = UUID()
    public var value: Int? = nil
    /// TableSelectable
    public var isSelectable: Bool = false
    /// CustomKeyProviable
    public var customKey: String? = nil
    public var placeholder:String? = nil
    public var useDirectionButtons:Bool = true
}
    

extension InputValue {
    
    public init(type: InputType,customKey:String?,value:Int?) {
        self.type = type
        self.customKey = customKey
        self.value = value
    }
    
    public init(_ type: InputType,_ customKey:String?,_ placeholder: String? = nil) {
        self.type = type
        self.customKey = customKey
        self.value = nil
        self.placeholder = placeholder
    }
    
}


extension InputValue {
    
    var title:String {
        switch type {
        case .phoneNumber:
            return "Phone Number"
        case .zipcode:
            return "Zip Code"
        }
    }
    
    var displayValue:String {
        switch type {
        case .phoneNumber:
            if let val = value {
                return "+ \(val)"
            }
        case .zipcode:
            if let val = value {
                return "\(val)"
            }
        }
        return ""
    }
    
}




extension InputValue {
    
    
    func newWith(_ newValue:String) -> InputValue {
        InputValue(type: self.type,
                   identifier: UUID(),
                   value: Int(newValue),
                   isSelectable: self.isSelectable, customKey: self.customKey,
                   placeholder: self.placeholder
        )
    }
    
}


//// MARK: - FormValue -
extension InputValue: FormValue, TableViewSelectable {
    
    public var formItem: FormItem {
        return .input(self)
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
    
    static let identifier = "inputCell"
    let formatter = DefaultTextInputFormatter(textPattern: "(###) ###-##-##")
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        return label
    }()
    
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.textAlignment = .left
        textField.font = UIFont.preferredFont(forTextStyle: .headline)
        return textField
    }()
    
    var formValue : InputValue? {
        didSet {
            if let inputValue = formValue {
                titleLabel.text = inputValue.title
                textField.text = inputValue.displayValue
                textField.placeholder = inputValue.placeholder
                layout()
            }
        }
    }
    
    private var didLayout:Bool = false
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [titleLabel,textField].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        titleLabel.text = nil
        indexPath = nil
    }
    
    func layout(){
        guard let inputValue = formValue, didLayout == false else { return }
        
        evaluateButtonBar()
        let margin = contentView.layoutMarginsGuide
        
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
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            textField.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.5),
        ])

        didLayout = true
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        if selected {
            textField.becomeFirstResponder()
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
            textField.inputAccessoryView = bar
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
        textField.becomeFirstResponder()
    }
    
    @objc
    func textFieldTextChanged() {
        print("-INPUT- text changed")
        if let text = textField.text {
            guard let inputValue = formValue else { return }
            updateFormValueDelegate?.updatedFormValue(inputValue.newWith(text), indexPath)
        }
    }
    
    private func endTextEditing(){
        textField.resignFirstResponder()
    }
    
}



extension InputValueCell: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endTextEditing()
        return true
    }
    
    
    
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let inputValue = formValue else { return false }
        
        print("-INPUT-\n Range: \(range) | Replacement String: \(string)")
        
        switch inputValue.type {
        case .phoneNumber:
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
        case .zipcode:
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
        }
        
        
        let result = formatter.formatInput(currentText: textField.text ?? "", range: range, replacementString: string)
        textField.text = result.formattedText
        textField.setCursorLocation(result.caretBeginOffset)
        
        return false
        
        /*
        switch inputValue.type {
        case .phoneNumber:
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
                return true
            } else {
                return false
            }
        case .zipcode:
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
                return true
            } else {
                return false
            }
        }
        */
        
        
        
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

