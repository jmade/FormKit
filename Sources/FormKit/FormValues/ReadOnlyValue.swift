import UIKit

// MARK: - ReadOnlyValue -
public struct ReadOnlyValue {
    
    public enum ValueDisplayStyle {
        case code, digit, bold, `default`, valueOnly, centered, valueOnlyInfo
    }
    
    public var valueDisplayStyle:ValueDisplayStyle = .default
    
    public var valueDisplayClosure: ((UILabel) -> Void)?
    
    public let title:String
    public let value:String
    public var isDisabled:Bool = true
    public var customKey:String? = nil
    public var validators: [Validator] = []
    
}


extension ReadOnlyValue: Equatable, Hashable {
    
    public static func == (lhs: ReadOnlyValue, rhs: ReadOnlyValue) -> Bool {
        lhs.title == rhs.title &&
        lhs.value == rhs.value &&
        lhs.isDisabled == rhs.isDisabled &&
        lhs.customKey == rhs.customKey
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(value)
        hasher.combine(isDisabled)
        hasher.combine(customKey)
    }
    
}


public extension ReadOnlyValue {
    
    
    init(_ title:String,_ value:String,_ disabled:Bool? = nil) {
        self.title = title
        self.value = value
        self.isDisabled = disabled ?? true
    }
    
    
    init(centeredValue:String) {
        self.title = String()
        self.valueDisplayStyle = .centered
        self.value = centeredValue
    }
    
    init(title: String, value:String,_ disabled:Bool = true) {
        self.title = title
        self.value = value
        self.isDisabled = disabled
    }
    
    init(title:String,value:String,valueDisplayStyle:ValueDisplayStyle) {
        self.title = title
        self.value = value
        self.valueDisplayStyle = valueDisplayStyle
    }
    
    init(_ title:String,_ value:String) {
        self.title = title
        self.value = value
    }
    
    init(_ title:String,_ value:String,_ style:ValueDisplayStyle,_ disabled:Bool = true) {
        self.title = title
        self.value = value
        self.valueDisplayStyle = style
        self.isDisabled = disabled
    }
    
    init(valueOnly: String) {
        self.title = String()
        self.value = valueOnly
        self.valueDisplayStyle = .valueOnly
        self.isDisabled = true
    }
    
}



public extension ReadOnlyValue {
    
    static func valueOnly(_ value:String) -> ReadOnlyValue {
        ReadOnlyValue("", value, .valueOnly)
    }
    
    static func centered(_ value:String) -> ReadOnlyValue {
        ReadOnlyValue("", value, .centered)
    }
    
    static var random:ReadOnlyValue {
        ReadOnlyValue("Random", String(UUID().uuidString.split(separator: "-")[1]))
    }
    
}



// MARK: - ValueDisplayStyle -
public extension ReadOnlyValue {
    
    var valueAttributedText:NSAttributedString {
        let mutableAttribString = NSMutableAttributedString(string: value)
        
        
        var digitFont = UIFont.preferredFont(forTextStyle: .body)
        if #available(iOS 13.0, *) {
            digitFont = UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        }
        
        var boldDigit = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        if #available(iOS 13.0, *) {
            boldDigit = UIFont.monospacedDigitSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        }
        
        
        switch valueDisplayStyle {
        case .centered:
            mutableAttribString
                .addAttribute(.font,
                              value: UIFont(descriptor: UIFont.preferredFont(forTextStyle:  .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0),
                              range: NSRange(location: 0, length: value.count)
            )
        case .default:
            mutableAttribString
               .addAttribute(.font,
                             value: UIFont.preferredFont(forTextStyle: .body),
                             range: NSRange(location: 0, length: value.count)
           )
        case .code, .valueOnly:
             mutableAttribString
                .addAttribute(.font,
                              value: digitFont,
                              range: NSRange(location: 0, length: value.count)
            )
        case .digit:
            mutableAttribString
                .addAttribute(.font,
                              value: boldDigit,
                              range: NSRange(location: 0, length: value.count)
            )
        case .bold:
            mutableAttribString
                .addAttribute(.font,
                              value: UIFont(descriptor: UIFont.preferredFont(forTextStyle:  .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0),
                              range: NSRange(location: 0, length: value.count)
            )
        case .valueOnlyInfo:
            mutableAttribString
               .addAttribute(.font,
                             value: UIFont.preferredFont(forTextStyle: .caption1),
                             range: NSRange(location: 0, length: value.count)
           )
        }
        
        return
            NSAttributedString(attributedString: mutableAttribString)
    }
    
}


// MARK: - FormValue -
extension ReadOnlyValue: FormValue {
    
    public var formItem: FormItem {
       FormItem.readOnly(self)
    }
    
    public func encodedValue() -> [String : String] {
        [(customKey ?? title) : value]
    }
}


// MARK: - FormValueDisplayable -
extension ReadOnlyValue: FormValueDisplayable {
    
    public typealias Cell = ReadOnlyCell
    
    public func configureCell(_ formController: FormController, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
    }
    
    public typealias Controller = FormController
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}


extension ReadOnlyValue {
    public static func Random() -> ReadOnlyValue {
        let randomString = UUID().uuidString
        let randomTitle = randomString.split(separator: "-")[1]
        let randomValue = randomString.split(separator: "-")[2]
        return ReadOnlyValue(title: String(randomTitle), value: String(randomValue))
    }
}


extension UITableViewCell {
    
    func addAndContrainToContentView(_ view:UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}





// MARK: - ReadOnlyCell -
public final class ReadOnlyCell: UITableViewCell {
    
    static let identifier = "FormKit.ReadOnlyCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    private lazy var readOnlyView:ReadOnlyValueView = {
        let readOnly = ReadOnlyValueView()
        addAndContrainToContentView(readOnly)
        return readOnly
    }()
    
    var formValue : ReadOnlyValue? {
        didSet {
            readOnlyView.formValue = formValue
            selectionStyle = (formValue?.isDisabled ?? false) ? .none : .default
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activateDefaultHeightAnchorConstraint()
    }
    
    override public func prepareForReuse() {
        formValue = nil
        super.prepareForReuse()
    }
}




final class ReadOnlyValueView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        if #available(iOS 13.0, *) {
            label.textColor = .label
        }
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        //label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.textAlignment = .right
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .lightGray
        }
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4.0).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        return label
    }()
    
    
    private lazy var valueOnlyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.textColor = .tertiaryLabel
        } else {
            label.textColor = .lightGray
        }
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        return label
    }()
    
    
    var formValue : ReadOnlyValue? {
        didSet {
            
            guard let readOnlyValue = formValue else {
                valueLabel.attributedText = nil
                titleLabel.text = nil
                valueOnlyLabel.attributedText = nil
                return
            }
            
            switch readOnlyValue.valueDisplayStyle {
            case .valueOnly, .valueOnlyInfo:
                titleLabel.isHidden = true
                valueLabel.isHidden = true
                valueOnlyLabel.isHidden = false
                valueOnlyLabel.textAlignment = .left
                valueOnlyLabel.attributedText = readOnlyValue.valueAttributedText
            case .centered:
                titleLabel.isHidden = true
                valueLabel.isHidden = true
                valueOnlyLabel.isHidden = false
                valueOnlyLabel.textAlignment = .center
                valueOnlyLabel.attributedText = readOnlyValue.valueAttributedText
            default:
                titleLabel.isHidden = false
                valueLabel.isHidden = false
                valueOnlyLabel.isHidden = true
                valueOnlyLabel.textAlignment = .left
                titleLabel.text = readOnlyValue.title
                valueLabel.attributedText = readOnlyValue.valueAttributedText
            }
            
        }
        
    }
    
}
