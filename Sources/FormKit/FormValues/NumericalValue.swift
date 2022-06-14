import UIKit

//: MARK: - NumericalValue -
public struct NumericalValue {
    
    public enum Style {
        case horizontal,vertical, hoizontalDiscrete
    }
    
    public enum NumberType {
        case int,float
    }
    
    /// TableSelectable
    public var isSelectable: Bool = false
    
    public var customKey:String? = nil
    
    public let title:String
    public let value:String
    public var style:Style = .hoizontalDiscrete
    public var numberType: NumberType = .float
    public var useDirectionButtons:Bool = true
    public var placeholder:String? = nil
    public var inputDescription:String?
    
    public var floatValidationRules: [FloatRule] = []
    public var intValidationRules: [IntRule] = []
    
}

extension NumericalValue: Equatable, Hashable {
    
    public static func == (lhs: NumericalValue, rhs: NumericalValue) -> Bool {
        lhs.title == rhs.title && lhs.value == rhs.value && lhs.numberType == rhs.numberType
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(value)
        hasher.combine(numberType)
    }

    
}




public extension NumericalValue {
    
    /// General
    init(title:String, numberType:NumberType, customKey:String?) {
        self.title = title
        self.value = ""
        self.numberType = numberType
        self.customKey = customKey
    }
    
    /// General with Value
    init(title:String, value:String, numberType:NumberType, customKey:String?) {
        self.title = title
        self.value = value
        self.numberType = numberType
        self.customKey = customKey
    }

    
    /// Float
    init(floatTitle: String, customKey:String? = nil) {
        self.title = floatTitle
        self.value = ""
        self.customKey = customKey
        self.numberType = .float
    }
    
    init(floatTitle: String, customKey:String? = nil,_ placeholder:String) {
        self.title = floatTitle
        self.value = ""
        self.customKey = customKey
        self.numberType = .float
        self.placeholder = placeholder
    }
    
    
    /// Int
    init(intTitle: String, customKey:String? = nil) {
        self.title = intTitle
        self.value = ""
        self.customKey = customKey
        self.numberType = .int
    }
    
    
    init(intTitle: String,_ customKey:String? = nil) {
        self.title = intTitle
        self.value = ""
        self.customKey = customKey
        self.numberType = .int
    }
    
    
    
}


public extension NumericalValue {

    static func float(_ title:String,_ customKey:String,_ value:String,_ inputDescription:String) -> NumericalValue {
        var num = NumericalValue(title: title, value: value)
        num.customKey = customKey
        num.inputDescription = inputDescription
        num.numberType = .float
        return num
    }
    
    static func float(_ title:String,_ customKey:String,_ inputDescription:String) -> NumericalValue {
        var num = NumericalValue(title: title, value: "")
        num.customKey = customKey
        num.inputDescription = inputDescription
        num.numberType = .float
        return num
    }
    
    
    
    static func int(_ title:String,_ customKey:String,_ value:String,_ inputDescription:String) -> NumericalValue {
        var num = NumericalValue(title: title, value: value)
        num.customKey = customKey
        num.inputDescription = inputDescription
        num.numberType = .int
        return num
    }
    
    
    static func int(_ title:String,_ customKey:String,_ inputDescription:String) -> NumericalValue {
        var num = NumericalValue(title: title, value: "")
        num.customKey = customKey
        num.inputDescription = inputDescription
        num.numberType = .int
        return num
    }
    
}



extension NumericalValue {
    
    var formattedValue: String {
        switch numberType {
        case .float:
            guard let doubleValue = Double(value) else {
                return value
            }
            return String(format: "%.2f", doubleValue)
        case .int:
            guard let intValue = Int(value) else {
                return value
            }
            return "\(intValue)"
        }
    }
    
}



// MARK: - FormValue -
extension NumericalValue: FormValue {
    
    private var floatValdator: Validator {
        Validator("value", Double(self.value), rules: floatValidationRules)
    }
    
    private var intValdator: Validator {
        Validator("value", Int(self.value), rules: intValidationRules)
    }
    
    public var validators: [Validator] {
        numberType == .int ? [intValdator] : [floatValdator]
    }
    
    
    public var formItem: FormItem {
           .numerical(self)
    }
    
    public func encodedValue() -> [String : String] {
           return [ (customKey ?? title) : formattedValue ]
       }
    
}





extension NumericalValue: FormValueDisplayable, TableViewSelectable {
    
    public typealias Cell = NumericalCell
    public typealias Controller = FormController
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.tableView = formController.tableView
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let numericalCell = formController.tableView.cellForRow(at: path) as? NumericalCell {
            numericalCell.activate()
        }
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}





extension NumericalValue {
    
    func newWith(_ newValue:String) -> NumericalValue {
        return
            NumericalValue(
                customKey: self.customKey,
                title: self.title,
                value: newValue,
                style: self.style,
                numberType: self.numberType,
                useDirectionButtons: self.useDirectionButtons,
                inputDescription: self.inputDescription,
                floatValidationRules: self.floatValidationRules,
                intValidationRules: self.intValidationRules
        )
    }
    
}




extension NumericalValue {
    
    public static func Random() -> NumericalValue {
        let title = [
            "Books","Jars","Pounds","Ounces","Trucks","Containers","Beers","Drinks","Roads","Items","Elements"
        ].randomElement()!
        
        if Bool.random() {
          return NumericalValue(title: title, value: "\(Int.random(in: 0...99))", numberType: .int, customKey: "demo_int")
        } else {
          return NumericalValue(title: title, value: "\(Double.random(in: 0.0...99.9))", numberType: .float, customKey: "demo_float")
        }
    }

    
    public static func DemoInt() -> NumericalValue {
           return NumericalValue(title: "Temperature", value: "72", numberType: .int, customKey: "temperature")
       }
    
    
    public static func DemoFloat() -> NumericalValue {
        return NumericalValue(title: "Meter Reading", value: "\(Double.random(in: 0.0...99.9))", numberType: .float, customKey: "meterReading")
    }
       
    
}


extension UILabel {
    static var inputDescription: UILabel {
        
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        //label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .caption2).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        }
        return label
    }
}



// MARK: NumericalCell
public final class NumericalCell: UITableViewCell, Activatable {
    static let identifier = "numericalCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    var tableView: UITableView?
    
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
    
    /*
    private lazy var inputDescriptionLabel:UILabel = {
        let label = UILabel.inputDescription
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: validationErrorView.bottomAnchor, constant: 2.0).isActive = true
        contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        return label
    }()
    */
    
    private lazy var inputDescriptionLabel:UILabel = {
        let label = UILabel.inputDescription
        return label
    }()
    
    private lazy var validationLabel:UILabel = {
        let label = UILabel.inputDescription
        label.textColor = .red
        return label
    }()
    
    
    private lazy var validationErrorView: ValidationErrorCellView = {
        let view = ValidationErrorCellView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        
        
        
        view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.0).isActive = true
        contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        return view
    }()
    
    
    var formValue : NumericalValue? {
        didSet {
            if let numericalValue = formValue {
                
                if let titleText = titleLabel.text {
                    if titleText != numericalValue.title {
                        titleLabel.text = numericalValue.title
                    }
                } else {
                    titleLabel.text = numericalValue.title
                }
                
                if let textFieldText = textField.text {
                    if textFieldText != numericalValue.value {
                        textField.text = numericalValue.value
                    }
                } else {
                    textField.text = numericalValue.value
                }
                
                if let placeholderValueText = numericalValue.placeholder {
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
                
                if let inputDescriptionValueText = numericalValue.inputDescription {
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
                
                if numericalValue.formItem.invalid {
                    validationLabel.text = numericalValue.formItem.errorMessages.joined(separator: "\n")
                    if validationLabel.isHidden == true {
                        validationLabel.isHidden = false
                    }
                } else {
                    if validationLabel.isHidden == false {
                        validationLabel.isHidden = true
                        validationLabel.text = nil
                    }
                }
                //validationErrorView.set(numericalValue.formItem.errorMessages)
                layout()
            }
        }
    }
    
    private var useContentStack: Bool = true
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 2.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 2.0),
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 2.0)
        ])
        return stack
    }()
    
    
    private var didLayout:Bool = false
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if useContentStack {
        } else {
            [titleLabel,textField,inputDescriptionLabel].forEach({
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
            })
        }
        
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
    
    func layout() {
        if useContentStack {
            contentStackLayout()
        } else {
            originalLayout()
        }
    }
    
    
    fileprivate func makeValueStack(_ axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.distribution = .fillProportionally
        stack.spacing = 2.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    
    func contentStackLayout() {
        guard let numericalValue = formValue, didLayout == false else { return }
        evaluateButtonBar()
        
        switch numericalValue.numberType {
        case .int:
            textField.keyboardType = .numberPad
            textField.returnKeyType = .done
        case .float:
            textField.keyboardType = .decimalPad
        }
        
        
        switch numericalValue.style {
            
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
        case .hoizontalDiscrete:
            
            textField.textAlignment = .right
            textField.borderStyle = .none
            textField.clearButtonMode = .never
            textField.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .semibold)  //UIFont.preferredFont(forTextStyle: .body)
            textField.textColor = UIColor.FormKit.valueText
            
            
            let titleStack = makeValueStack(.vertical)
            titleStack.addArrangedSubview(titleLabel)
            titleStack.addArrangedSubview(inputDescriptionLabel)
            
            let stack = makeValueStack(.horizontal)
            stack.addArrangedSubview(titleStack)
            stack.addArrangedSubview(textField)
            contentStack.addArrangedSubview(stack)
            
            //contentStack.addArrangedSubview(inputDescriptionLabel)
            contentStack.addArrangedSubview(validationLabel)
            
            //contentStack.addArrangedSubview(inputDescriptionLabel)
            //contentStack.addArrangedSubview(validationLabel)
                               
            
        }
        didLayout = true
    }
    
    
    
    func originalLayout(){
        guard let numericalValue = formValue, didLayout == false else { return }
        
        evaluateButtonBar()
        let margin = contentView.layoutMarginsGuide
        
        switch numericalValue.numberType {
        case .int:
            textField.keyboardType = .numberPad
            textField.returnKeyType = .done
        case .float:
            textField.keyboardType = .decimalPad
        }
        
        switch numericalValue.style {
        case .horizontal:
            
            activateDefaultHeightAnchorConstraint()
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                titleLabel.topAnchor.constraint(equalTo: margin.topAnchor),
                //titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
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
                //margin.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4.0)
                ])
        case .hoizontalDiscrete:
            activateDefaultHeightAnchorConstraint()
            
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
                titleLabel.topAnchor.constraint(equalTo: margin.topAnchor),
                //titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.5),
            ])
        }
        
        didLayout = true
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        if selected {
            textField.becomeFirstResponder()
        }
    }
  
    func evaluateButtonBar(){
        guard let numericalValue = formValue else { return }
        if numericalValue.useDirectionButtons {
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
        if let text = textField.text {
            guard let currentValue = formValue else { return }
            
            let newValue = currentValue.newWith(text)
            
            let becameValid = currentValue.formItem.invalid && newValue.formItem.valid
            let becameInValid = currentValue.formItem.valid && newValue.formItem.invalid
            
            let messageCountChanged = currentValue.formItem.errorMessages != newValue.formItem.errorMessages
            let updateLayout = becameValid || becameInValid || messageCountChanged
            
            if updateLayout {
                self.tableView?.beginUpdates()
                self.formValue = newValue
                self.tableView?.endUpdates()
            }
            
            updateFormValueDelegate?.updatedFormValue(newValue, indexPath)
        }
    }
    
    private func endTextEditing(){
        textField.resignFirstResponder()
    }
    
}

extension NumericalCell: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endTextEditing()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let formValue = formValue else { return false }
        
        switch formValue.numberType {
        case .int:
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
                return true
            } else {
                 return false
            }
        case .float:
            let floatCharacterSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".-+"))
            if floatCharacterSet.isSuperset(of: CharacterSet(charactersIn: string)) {
                return true
            } else {
                return false
            }
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

