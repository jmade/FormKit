
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
    
    public var characterSet = CharacterSet.noteValue /// Deprecated 2/19/21; use `allowedChars`
    
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
    public var validationRules:[StringRule] = []
    
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
       - title: The **Title** of the TextValue
       - customKey: used as the JSON Key value when using `FormDataSource` params
       - value: The value in the textfield
       - placeholder: optional text displayed in textfield, that disappears on input. example: "Required"
       - allowedChars: optional string of chars that are to be allowed as input in the textfield
       - inputDescription: displayed under the `title` in a smaller font and secondary color
       - characterCount: optional max number of characters that should be allowed
     
     
    - Note: Note.
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
    
    public var validators: [Validator] {
        [
            Validator(title, self.value, rules: validationRules),
        ]
    }

    
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
                                 useDirectionButtons: self.useDirectionButtons,
                                 validationRules: self.validationRules
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
        cell.tableView = formController.tableView
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
    var tableView: UITableView?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
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
        return label
    }()
    
    private lazy var validationLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    
    private lazy var tapView:UIView = {
        let tapView = UIView()
        tapView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(tapView)
        tapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tapView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        tapView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapViewTapped))
        )
        return tapView
    }()
    
    
    /// CharacterCountDisplayable
    public var maxCharacterCount = 100
    public lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.text  = ""
        return label
    }()
    
    public lazy var characterCountBarItem: UIBarButtonItem  = {
        UIBarButtonItem(customView: characterCountLabel)
    }()

    var formValue:TextValue? {
        didSet {
            if let textValue = formValue {
                
                if let titleText = titleLabel.text {
                    if titleText != textValue.title {
                        titleLabel.text = textValue.title
                    }
                } else {
                    titleLabel.text = textValue.title
                }
                
                if let textFieldText = textField.text {
                    if textFieldText != textValue.value {
                        textField.text = textValue.value
                    }
                } else {
                    textField.text = textValue.value
                }
                
                if let placeholderValueText = textValue.placeholder {
                    if let placeholderText = textField.placeholder {
                        if placeholderText != placeholderValueText {
                            textField.placeholder = placeholderValueText
                        }
                    } else {
                        textField.placeholder = placeholderValueText
                    }
                } else {
                    if textField.placeholder != nil {
                        textField.placeholder = nil
                    }
                }
                
                if let inputDescriptionValueText = textValue.inputDescription {
                    if let inputDescriptionText = inputDescriptionLabel.text {
                        if inputDescriptionText != inputDescriptionValueText {
                            inputDescriptionLabel.text = inputDescriptionValueText
                        }
                    } else {
                        inputDescriptionLabel.text = inputDescriptionValueText
                    }
                } else {
                    if inputDescriptionLabel.text != nil {
                        inputDescriptionLabel.text = nil
                    }
                }
     
                
                if let max = textValue.characterCount {
                    maxCharacterCount = max
                }
                
                if let config = textValue.inputConfiguration {
                    textField.returnKeyType = config.returnKeyType
                }
                
                if textValue.isSelectable == false {
                    self.selectionStyle = .none
                }
                
               
                if textValue.formItem.invalid {
                    if #available(iOS 13.0, *) {
                        let attributedString = textValue.formItem.attributedMessage
                        validationLabel.attributedText = attributedString
                    }
                    if validationLabel.isHidden == true {
                        validationLabel.isHidden = false
                    }
                } else {
                    validationLabel.text = nil
                    if validationLabel.isHidden == false {
                        validationLabel.isHidden = true
                    }
                }
                
                layout()
                
                textValue.textConfigurationClosure(textField)
                
                contentView.layoutSubviews()
                contentView.bringSubviewToFront(tapView)
                
                
            }
        }
    }
    
    private var didLayout:Bool = false
    
    private var useContentStack: Bool = true
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        //stack.spacing = 2.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
        return stack
    }()
    
    private var selectAllButton:UIBarButtonItem?
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        titleLabel.text = nil
        indexPath = nil
        inputDescriptionLabel.text = nil
        validationLabel.attributedText = nil
        contentView.bringSubviewToFront(tapView)
    }
    
    func layout() {
        contentStackLayout()
    }
    
    private func makeValueStack(_ axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.distribution = .fillProportionally
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    func contentStackLayout() {
        guard let textValue = formValue, didLayout == false else { return }
        evaluateButtonBar()
        
        switch textValue.style {
        case .horizontal:
            let stack = makeValueStack(.horizontal)
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(textField)
            contentStack.addArrangedSubview(stack)
            
            contentStack.addArrangedSubview(inputDescriptionLabel)
            contentStack.addArrangedSubview(validationLabel)
        case .vertical:
            let stack = makeValueStack(.vertical)
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(textField)
            contentStack.addArrangedSubview(stack)
            
            contentStack.addArrangedSubview(inputDescriptionLabel)
            contentStack.addArrangedSubview(validationLabel)
        case .horizontalDiscrete:
            textField.textAlignment = .right
            textField.borderStyle = .none
            textField.clearButtonMode = .never
            
            textField.font = UIFont.preferredFont(forTextStyle: .body)
            textField.textColor = UIColor.FormKit.valueText
            
            let stack = makeValueStack(.horizontal)
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(textField)
            contentStack.addArrangedSubview(stack)
            
            contentStack.addArrangedSubview(inputDescriptionLabel)
            contentStack.addArrangedSubview(validationLabel)
        case .writeIn:
            titleLabel.text = nil
            textField.textAlignment = .left
            textField.borderStyle = .none
            textField.clearButtonMode = .never
            textField.font = UIFont.preferredFont(forTextStyle: .body)
            let stack = makeValueStack(.horizontal)
            stack.addArrangedSubview(textField)
            contentStack.addArrangedSubview(stack)
        }
        
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
            
            
            if #available(iOS 16.0, *) {
                selectAllButton = .selectAll(self,#selector(performSelectAll(_:)))
                
                if let text = textField.text {
                    selectAllButton!.isHidden = text.isEmpty
                }
                
                barItems.append(selectAllButton!)
                barItems.append(.flexible)
            }
            
            barItems.append(
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
            )
            
            let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: 1000, height: 44.0)))
            bar.items = barItems
            bar.sizeToFit()
            
            textField.inputAccessoryView = bar
        }
    
    }
    
    
    private func sendTextToDelegate() {
        
        guard
            let newText = textField.text,
            let existingTextValue = formValue
        else {
            return
        }
        
        if existingTextValue.characterCount != nil {
            updateCharacterCount(newText.count)
        }
        
        let newValue = existingTextValue.newWith(newText)
        
        let becameValid = existingTextValue.formItem.invalid && newValue.formItem.valid
        let becameInValid = existingTextValue.formItem.valid && newValue.formItem.invalid
        
        let messageCountChanged = existingTextValue.formItem.errorMessages != newValue.formItem.errorMessages
        let updateLayout = becameValid || becameInValid || messageCountChanged
        
        if updateLayout {
            self.tableView?.beginUpdates()
            self.formValue = newValue
            self.tableView?.endUpdates()
        }
        
        updateFormValueDelegate?.updatedFormValue(
            newValue,
            indexPath
        )
    }
    
    public func updateCharacterCount(_ count:Int) {
        characterCountLabel.text = "\(count)/\(maxCharacterCount)"
        if #available(iOS 13.0, *) {
            characterCountLabel.textColor = (count == maxCharacterCount) ? .red : .label
        }
        characterCountLabel.sizeToFit()
    }
    
    @objc
    func performSelectAll(_ sender:UIBarButtonItem) {
        
        if let title = sender.title {
            if title == .selectAll {
                UIViewPropertyAnimator(duration: 1/3, curve: .easeInOut) {
                    sender.title = .deselectAll
                }.startAnimation()
                textField.selectAll(nil)
            } else {
                UIViewPropertyAnimator(duration: 1/3, curve: .easeInOut) {
                    sender.title = .selectAll
                }.startAnimation()
                textField.setCursorLocation((textField.text ?? "").count)
            }
        }
    }
    
    @objc
    func doneAction(){
        endTextEditing()
        contentView.bringSubviewToFront(tapView)
    }
    
    @objc
    func previousAction(){
        if let path = indexPath {
            updateFormValueDelegate?.toggleTo(.previous, path)
        }
        contentView.bringSubviewToFront(tapView)
        selectAllButton?.title = .selectAll
    }
    
    @objc
    func nextAction(){
        if let path = indexPath {
            updateFormValueDelegate?.toggleTo(.next, path)
        }
        contentView.bringSubviewToFront(tapView)
        selectAllButton?.title = .selectAll
    }
    
    @objc
    func tapViewTapped(){
        contentView.sendSubviewToBack(tapView)
        selectAllButton?.title = .selectAll
        activate()
    }
    
    public func activate(){
        textField.becomeFirstResponder()
    }
    
    @objc
    func textFieldTextChanged() {
        if let text = textField.text {
            
            if #available(iOS 16.0, *) {
                selectAllButton?.isHidden = text.isEmpty
                if text.isEmpty {
                    selectAllButton?.title = .selectAll
                }
            }
            
            guard let textValue = formValue else { return }
            if textValue.characterCount != nil {
                updateCharacterCount(text.count)
            }
            sendTextToDelegate()
        }
    }
    
    private func endTextEditing(){
        textField.resignFirstResponder()
        contentView.bringSubviewToFront(tapView)
        selectAllButton?.title = .selectAll
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
                        //print("Its Safe: \(String(char))")
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
