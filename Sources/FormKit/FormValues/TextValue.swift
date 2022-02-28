import UIKit



struct TextValueTransportInitialization: Decodable {
       var title: String
       var customKey: String?
       var value: String?
       var placeholder: String?
       var inputDescription: String?
       var characterCount: Int?
       var allowedChars: String?
}





public typealias TextValueReturnPressedClosure = ( (TextValue) -> Void )

public typealias TextFieldConfigurationClosure = ( (UITextField) -> Void )



// MARK: - TextValue -
public struct TextValue {
    
    public enum Style {
        case horizontal, vertical, horizontalDiscrete, writeIn
    }
    
    public var characterSet = CharacterSet.noteValue /// Depercated 2/19/21; use `allowedChars`
    
    /// TableSelectable
    public var isSelectable: Bool = false
    /// CustomKeyProviable
    public var customKey: String? = nil
    
    public var textConfigurationClosure: TextFieldConfigurationClosure = { _ in }
    public var returnPressedClosure: TextValueReturnPressedClosure?
    
    public var placeholder:String? = nil
    public let title:String
    public var value:String
    public var style:Style = .horizontalDiscrete
    public var useDirectionButtons:Bool = true
    public var uuid:String = UUID().uuidString
    
    public var inputDescription:String?
    public var characterCount:Int?
    public var allowedChars:String?
    
    public var inputConfiguration: InputConfiguration?
}


extension TextValue {
    
    public struct InputConfiguration {
        public var returnPressedClosure: TextValueReturnPressedClosure?
        public var useDirectionButtons:Bool = true
        public var displaysInputBar:Bool = true
        public var returnKeyType: UIReturnKeyType = .done
    }
    
}


extension TextValue.InputConfiguration {
    
    public init(_ returnKeyType: UIReturnKeyType = .done,_ returnPressedClosure: @escaping TextValueReturnPressedClosure) {
        self.returnPressedClosure = returnPressedClosure
        self.returnKeyType = returnKeyType
        self.useDirectionButtons = false
        self.displaysInputBar = false
    }
    
    public init(_ displaysInputBar:Bool,_ useDirectionButtons:Bool,_ returnKeyType: UIReturnKeyType = .done,_ returnPressedClosure: @escaping TextValueReturnPressedClosure) {
        self.returnPressedClosure = returnPressedClosure
        self.returnKeyType = returnKeyType
        self.useDirectionButtons = useDirectionButtons
        self.displaysInputBar = displaysInputBar
    }
    
}








// MARK: - init -
extension TextValue {
    
    
    public init(title: String) {
        self.title = title
        self.value = ""
    }
    
    public init(title: String, value:String,_ style:Style = .horizontalDiscrete,_ useDirectionButton:Bool = true) {
        self.title = title
        self.value = value
        self.style = style
        self.useDirectionButtons = useDirectionButton
    }
    
    public init(title: String, value:String, customKey: String?) {
        self.title = title
        self.value = value
        self.customKey = customKey
    }
    
    public init(title: String,customKey: String?) {
        self.title = title
        self.value = ""
        self.customKey = customKey
    }
    
    public init(title: String, configClosure: @escaping TextFieldConfigurationClosure) {
        self.title = title
        self.value = ""
        self.customKey = title.lowercased()
        self.textConfigurationClosure = configClosure
    }
    
    
    
    
    public init(_ title: String,_ customKey: String?) {
        self.title = title
        self.value = ""
        self.customKey = customKey
    }
    
    public init(_ title: String,_ customKey: String?,_ placeholder:String) {
        self.title = title
        self.value = ""
        self.customKey = customKey
        self.placeholder = placeholder
    }
    
    public init(_ title: String,_ value:String,_ customKey: String?,_ placeholder:String) {
        self.title = title
        self.value = value
        self.customKey = customKey
        self.placeholder = placeholder
    }
    
    
    public init(_ title: String,inputDescription:String) {
        self.title = title
        self.value = ""
        self.inputDescription = inputDescription
    }
    
    
    public init(_ title: String,_ value:String,_ customKey: String?,_ placeholder:String, inputDescription:String) {
        self.title = title
        self.value = value
        self.customKey = customKey
        self.placeholder = placeholder
        self.inputDescription = inputDescription
    }
    
    
    public init(_ placeholder:String?) {
        self.title = ""
        self.value = ""
        self.customKey = nil
        self.placeholder = placeholder
        self.style = .writeIn
        self.isSelectable = true
        
    }

    
}





extension TextValue {
    
    /**
    Initializes a new FormSection with the optional subtitle and footer strings.

    - Parameters:
       - title: The *title* of the TextValue
       - customKey: used as the JSON Key value when using `FormDataSource` params
       - value: The value in the textfield
       - placeholder: optional text displayed in textfield, that disappears on input. example: "Required"
       - allowedChars: optional string of chars that are to be allowed as input in the textfield
       - inputDescription: displayed under the `title` in a smaller font and secondary color
       - characterCount: optional max number of characters that should be allowed
     
     
    - Note: Does this work?
    - Returns: A fully functional form element for Text Input.
    */
    
    public init(_ title: String,_ customKey: String?,_ value:String?,_ placeholder:String? = nil,_ allowedChars: String? = nil,_ inputDescription:String? = nil,_ characterCount: Int? = nil) {
        self.title = title
        self.value = value ?? ""
        self.customKey = customKey
        self.placeholder = placeholder
        self.inputDescription = inputDescription
        self.characterCount = characterCount
        self.allowedChars = allowedChars
    }
    
}





// MARK: - Equatable -
extension TextValue: Equatable {
    
    public static func == (lhs: TextValue, rhs: TextValue) -> Bool {
           lhs.uuid == rhs.uuid
       }
    
}

extension TextValue: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public var hash: Int {
        return uuid.hashValue
    }
    
}




extension TextValue: FormValue, TableViewSelectable {
    
    public var formItem: FormItem {
        return FormItem.text(self)
    }
    
    
    public func encodedValue() -> [String : String] {
        return [ (customKey ?? title) : value]
    }
    
}



extension TextValue {
    
    func newWith(_ newValue:String) -> TextValue {
        
        var newValue = TextValue(characterSet: self.characterSet,
                         isSelectable: self.isSelectable,
                         customKey: self.customKey,
                         title: self.title,
                         value: newValue,
                         style: self.style,
                         useDirectionButtons: self.useDirectionButtons
        )
        newValue.placeholder = self.placeholder
        newValue.inputDescription = self.inputDescription
        newValue.allowedChars = self.allowedChars
        newValue.inputConfiguration = self.inputConfiguration
        return newValue
        
    }
    
}




extension TextValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = TextCell
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let textCell = formController.tableView.cellForRow(at: path) as? TextCell {
            textCell.activate()
        }
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}




extension TextValue {
    public static func Random() -> TextValue {
        let title = [
            "Entries","Team Name","Hometown","Favorite Food","Frist Name","Last Name","Email","Address"
            ].randomElement()!
        
        if Bool.random() {
            return TextValue(title: title, value: "", .horizontalDiscrete, true)
        } else {
            let style: TextValue.Style = Bool.random() ? .horizontal : .vertical
            return TextValue(title: title, value: "", style, true)
        }
        
    }
}




// MARK: TextCell
public final class TextCell: UITableViewCell, Activatable {
    
    static let identifier = "com.jmade.FormKit.TextCell"
    static let ReuseID = "com.jmade.FormKit.TextCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    public lazy var indexPath: IndexPath? = nil
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        textField.keyboardType = .alphabet
        textField.textAlignment = .left
        textField.font = UIFont.preferredFont(forTextStyle: .headline)
        return textField
    }()
    
    private lazy var inputDescriptionLabel:UILabel = {
        let label = UILabel.inputDescription
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.0).isActive = true
        contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        return label
    }()
    
    
    /// CharacterCountDisplayable
    public var maxCharacterCount = 100
    public lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.text  = ""
        //contentView.addSubview(label)
        return label
    }()
    
    public lazy var characterCountBarItem: UIBarButtonItem  = {
        UIBarButtonItem(customView: characterCountLabel)
    }()

    var formValue:TextValue? {
        didSet {
            if let textValue = formValue {
                titleLabel.text = textValue.title
                textValue.textConfigurationClosure(textField)
                textField.text = textValue.value
                textField.placeholder = textValue.placeholder
                inputDescriptionLabel.text = textValue.inputDescription
                if let max = textValue.characterCount {
                    maxCharacterCount = max
                }
                
                if let config = textValue.inputConfiguration {
                    textField.returnKeyType = config.returnKeyType
                }
                
                if textValue.isSelectable == false {
                    self.selectionStyle = .none
                }
                
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
        inputDescriptionLabel.text = nil
    }
    
    func layout(){
        guard let textValue = formValue, didLayout == false else { return }
        
        evaluateButtonBar()
        let margin = contentView.layoutMarginsGuide
        
        switch textValue.style {
        case .horizontal:
            
            activateDefaultHeightAnchorConstraint()
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.topAnchor.constraint(equalTo: margin.topAnchor),
                //titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                
                textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
                
                
                //textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.topAnchor.constraint(equalTo: titleLabel.topAnchor),
                
                
                //textField.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.5),
                margin.bottomAnchor.constraint(equalTo: textField.bottomAnchor),

                
                ])
        case .vertical:
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: margin.topAnchor),
                
                textField.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0),
                //margin.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4.0)
                ])
        case .horizontalDiscrete:
            
            activateDefaultHeightAnchorConstraint()
           
            
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.topAnchor.constraint(equalTo: margin.topAnchor),
                //titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                
                textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
                
                
                //textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.topAnchor.constraint(equalTo: titleLabel.topAnchor),
                
                
                //textField.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.5),
                margin.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
                
                /*
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.topAnchor.constraint(equalTo: margin.topAnchor),
                //titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
                */
            ])
            
            textField.textAlignment = .right
            textField.borderStyle = .none
            textField.clearButtonMode = .never
            textField.font = UIFont.preferredFont(forTextStyle: .body)
            textField.textColor = UIColor.FormKit.valueText
            
            //titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            
           
        case .writeIn:
            activateDefaultHeightAnchorConstraint()
            
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.topAnchor.constraint(equalTo: margin.topAnchor),
                margin.bottomAnchor.constraint(equalTo: margin.bottomAnchor),
            ])
            
            titleLabel.text = nil
            textField.textAlignment = .left
            textField.borderStyle = .none
            textField.clearButtonMode = .never
            textField.font = UIFont.preferredFont(forTextStyle: .body)
   
        }
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        didLayout = true
    }
    
    
    func evaluateButtonBar() {
        guard let textValue = formValue else { return }
        
        if let config = textValue.inputConfiguration {
            
            if config.displaysInputBar {
                
                var barItems:[UIBarButtonItem] = []
                
                if config.useDirectionButtons {
                    
                    barItems.append(
                        UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction))
                    )
                    
                    barItems.append(
                        UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction))
                    )
                    
                    barItems.append(.flexible)
                    
                    barItems.append(
                        UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
                    )
                    
                }
                
                
                if textValue.characterCount != nil {
                    barItems.append(characterCountBarItem)
                    barItems.append(.flexible)
                }
                            
                let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: 44.0)))
                bar.items = barItems
                bar.sizeToFit()
                
            } else {
                textField.inputAccessoryView = nil
            }
            
        } else {
            var barItems:[UIBarButtonItem] = []
            
            if textValue.useDirectionButtons {
                
                barItems.append(
                    UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction))
                )
                
                barItems.append(
                    UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction))
                )
            }
            
            barItems.append(.flexible)
            
            if textValue.characterCount != nil {
                barItems.append(characterCountBarItem)
                barItems.append(.flexible)
            }
            
            barItems.append(
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
            )
            
            let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: 44.0)))
            bar.items = barItems
            bar.sizeToFit()
            
            textField.inputAccessoryView = bar
        }
    
    }
    
    public func updateCharacterCount(_ count:Int) {
        characterCountLabel.text = "\(count)/\(maxCharacterCount)"
        if #available(iOS 13.0, *) {
            characterCountLabel.textColor = (count == maxCharacterCount) ? .red : .label
        }
        characterCountLabel.sizeToFit()
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
        if let text = textField.text {
            guard let textValue = formValue else { return }
            if textValue.characterCount != nil {
                updateCharacterCount(text.count)
            }
            updateFormValueDelegate?.updatedFormValue(textValue.newWith(text), indexPath)
        }
    }
    
    private func endTextEditing(){
        textField.resignFirstResponder()
    }
    
    
}

extension TextCell: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let textValue = formValue {
            if let config = textValue.inputConfiguration {
                config.returnPressedClosure?(textValue)
            } else {
                textValue.returnPressedClosure?(textValue)
            }
        }
        endTextEditing()
        return true
    }
    
    // used to mask input
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textValue = formValue else { return false }
        
        let maxChars = textValue.characterCount ?? Int.max
        
        let charSet = CharacterSet.formKit(textValue.allowedChars ?? FormConstant.ALLOWED_CHARS)
        
        let existingText = textField.text ?? ""
        
        
        if charSet.isSuperset(of: CharacterSet(charactersIn: string)) {
            
            if (existingText + string).count <= maxChars {
                return true
            } else {
                var newText = ""
                string.forEach { (char) in
                    if (existingText + newText).count+1 <= maxChars {
                        print("Its Safe: \(String(char))")
                        newText.append(char)
                    }
                }
                
                
                let newString = existingText + newText
                textField.text = newString
                textField.setCursorLocation(newString.count)
                
                return false
            }
        } else {
            
            var newText = ""
            string.forEach { (char) in
                if charSet.isSuperset(of: CharacterSet(charactersIn: String(char))) {
                    newText.append(char)
                }
            }
            
            let newString = existingText + newText
            textField.text = newString
            textField.setCursorLocation(newString.count)
            return false
            
           
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
