import UIKit


public typealias TextFieldConfigurationClosure = ( (UITextField) -> Void )


// MARK: - TextValue -
public struct TextValue {
    
    public enum Style {
        case horizontal, vertical, horizontalDiscrete
    }
    
    //TODO: fully implement this
    public var characterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " .?!,()[]$*%#-=/:;"))
    
    /// TableSelectable
    public var isSelectable: Bool = false
    /// CustomKeyProviable
    public var customKey: String? = nil
    
    public var textConfigurationClosure: TextFieldConfigurationClosure = { _ in }
    
    public var placeholder:String? = nil
    public let title:String
    public var value:String
    public var style:Style = .horizontalDiscrete
    public var useDirectionButtons:Bool = true
    public var uuid:String = UUID().uuidString
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
    static let identifier = "textCell"
    
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
    
    var formValue:TextValue? {
        didSet {
            if let textValue = formValue {
                titleLabel.text = textValue.title
                textValue.textConfigurationClosure(textField)
                textField.text = textValue.value
                textField.placeholder = textValue.placeholder
                
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
                titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.5),
                ])
        case .vertical:
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: margin.topAnchor),
                
                textField.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0),
                margin.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4.0)
                ])
        case .horizontalDiscrete:
            
            activateDefaultHeightAnchorConstraint()
           
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
            ])
            
            textField.textAlignment = .right
            textField.borderStyle = .none
            textField.clearButtonMode = .never
            textField.font = UIFont.preferredFont(forTextStyle: .body)
            textField.textColor = .gray
            if #available(iOS 13.0, *) {
                textField.textColor = .secondaryLabel
            }
        }
        
        didLayout = true
    }
    
    func evaluateButtonBar(){
        guard let textValue = formValue else { return }
        if textValue.useDirectionButtons {

            let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: 44.0)))
            let previous = UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction))
            let next = UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction))
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
            bar.items = [previous,next,.Flexible(),done]
            
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
        if let text = textField.text {
            guard let textValue = formValue else { return }
            updateFormValueDelegate?.updatedFormValue(textValue.newWith(text), indexPath)
        }
    }
    
    private func endTextEditing(){
        textField.resignFirstResponder()
    }
    
    
}

extension TextCell: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endTextEditing()
        return true
    }
    
    // used to mask input
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textValue = formValue else { return false }
        
        if textValue.characterSet.isSuperset(of: CharacterSet(charactersIn: string)) {
            if let newText = textField.text {
                self.formValue = textValue.newWith(newText)
            }
            return true
        } else {
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
