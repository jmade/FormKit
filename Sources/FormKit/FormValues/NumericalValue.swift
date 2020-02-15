import UIKit

//: MARK: - NumericalValue -
public struct NumericalValue: Equatable, Hashable {
    
    public enum Style {
        case horizontal,vertical, hoizontalDiscrete
    }
    
    public enum NumberType {
        case int,float
    }
    
    public var customKey:String? = nil
    
    let title:String
    let value:String
    var style:Style = .hoizontalDiscrete
    var numberType: NumberType = .float
    var useDirectionButtons:Bool = true
    
}


extension NumericalValue {
    
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
        self.value = ""
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
    
    /// Int
    init(intTitle: String, customKey:String? = nil) {
        self.title = intTitle
        self.value = ""
        self.customKey = customKey
        self.numberType = .int
    }
    
}



// MARK: - FormValue -
extension NumericalValue: FormValue {
    
    public var formItem: FormItem {
           get {
               return FormItem.numerical(self)
           }
       }
    
}



extension NumericalValue: FormValueDisplayable {
    
    public typealias Cell = NumericalCell
    public typealias Controller = FormController
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
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
    
    public func encodedValue() -> [String : String] {
        return [ (customKey ?? title) : value ]
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
                useDirectionButtons: self.useDirectionButtons
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



// MARK: NumericalCell
public final class NumericalCell: UITableViewCell, Activatable {
    static let identifier = "numericalCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
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
    
    var formValue : NumericalValue? {
        didSet {
            if let numericalValue = formValue {
                titleLabel.text = numericalValue.title
                textField.text = numericalValue.value
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
        guard let numericalValue = formValue, didLayout == false else { return }
        
        evaluateButtonBar()
        let margin = contentView.layoutMarginsGuide
        
        switch numericalValue.numberType {
        case .int:
            textField.keyboardType = .numberPad
        case .float:
            textField.keyboardType = .decimalPad
        }
        
        switch numericalValue.style {
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
                titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
                textField.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.5),
            ])
        }
        
        didLayout = true
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            FormConstant.makeSelectionFeedback()
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
            let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
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
            guard let numericalValue = formValue else { return }
            updateFormValueDelegate?.updatedFormValue(numericalValue.newWith(text), indexPath)
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
//                if let newText = textField.text {
//                    self.formValue = formValue.newWith(newText)
//                }
                return true
            } else {
                 return false
            }
        case .float:
            let floatCharacterSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".-+"))
            if floatCharacterSet.isSuperset(of: CharacterSet(charactersIn: string)) {
//                if let newText = textField.text {
//                    self.formValue = formValue.newWith(newText)
//                }
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

