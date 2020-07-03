import UIKit

// MARK: - ReadOnlyValue -
public struct ReadOnlyValue: Equatable, Hashable {
    
    public enum ValueDisplayStyle {
        case code, digit, bold, `default`, valueOnly
    }
    
    public var valueDisplayStyle:ValueDisplayStyle = .default
    
    public let title:String
    public let value:String
    public var isDisabled:Bool = true
    public var customKey:String? = nil
}


public extension ReadOnlyValue {
    
    init(title: String, value:String,_ disabled:Bool = true) {
        self.title = title
        self.value = value
        self.isDisabled = disabled
    }
    
    init(title:String,value:String,valueDisplayStyle:ValueDisplayStyle) {
        self.title = title
        self.value = value
        self.valueDisplayStyle = valueDisplayStyle
        self.isDisabled = true
    }
    
    init(_ title:String,_ value:String) {
        self.title = title
        self.value = value
        self.valueDisplayStyle = .default
        self.isDisabled = true
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

// MARK: - ValueDisplayStyle -
public extension ReadOnlyValue {
    
    var valueAttributedText:NSAttributedString {
        let mutableAttribString = NSMutableAttributedString(string: value)
        
        
        var digitFont = UIFont.preferredFont(forTextStyle: .body)
        if #available(iOS 13.0, *) {
            digitFont = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        }
        
        
        var boldDigit = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        if #available(iOS 13.0, *) {
            boldDigit = UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: .bold)
        }
        
        
        switch valueDisplayStyle {
        case .code, .default, .valueOnly:
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
        //cell.indexPath = path
    }
    
    public typealias Controller = FormController
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        /// do something here ?
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





// MARK: - ReadOnlyCell -
public final class ReadOnlyCell: UITableViewCell {
    static let identifier = "FormKit.ReadOnlyCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .darkGray
        }
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.textAlignment = .right
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.textColor = .tertiaryLabel
        } else {
            label.textColor = .lightGray
        }
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
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
        return label
    }()
    
    
    var formValue : ReadOnlyValue? {
        didSet {
            
            guard let readOnlyValue = formValue else {
                return
            }
            
            if readOnlyValue.isDisabled {
                self.selectionStyle = .none
            }
            
            switch readOnlyValue.valueDisplayStyle {
            case .valueOnly:
                titleLabel.isHidden = true
                valueLabel.isHidden = true
                valueOnlyLabel.isHidden = false
                valueOnlyLabel.attributedText = readOnlyValue.valueAttributedText
            default:
                titleLabel.isHidden = false
                valueLabel.isHidden = false
                valueOnlyLabel.isHidden = true
                titleLabel.text = readOnlyValue.title
                valueLabel.attributedText = readOnlyValue.valueAttributedText
            }
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [titleLabel,valueLabel,valueOnlyLabel].forEach({
            contentView.addSubview($0)
        })
        
        activateDefaultHeightAnchorConstraint()
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor),
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
            contentView.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8.0),
            
            valueOnlyLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            valueOnlyLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            valueOnlyLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: valueOnlyLabel.bottomAnchor, constant: 8.0),
            
        ])
        
    }
    
    override public func prepareForReuse() {
        valueLabel.attributedText = nil
        titleLabel.text = nil
        valueOnlyLabel.attributedText = nil
        formValue = nil
        super.prepareForReuse()
    }
}
