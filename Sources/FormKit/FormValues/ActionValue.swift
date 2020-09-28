import UIKit

// MARK: - ActionValue -
public struct ActionValue: Equatable {
    
    public enum ActionState {
        case ready, operating, complete, disabled
    }
    
    var state:ActionState = .ready
    
    private var lastState:ActionState?
    
    var operatingTitle: String {
        
        if let customOperatingTitle = customOperatingTitle {
            return customOperatingTitle
        }
        
        if let lastChar = title.last {
            if (lastChar == "e") || (lastChar == "E") {
                return "\(title.dropLast())ing..."
            }
        }
        
        return title
    }
    
    private var customOperatingTitle:String? = nil
    
    public enum ActionStyle {
       case none, disclosure, moderate, readOnly
    }
    
    public var style:ActionStyle = .disclosure
    
    public var customKey:String? = "ActionValue"
    
    public typealias ActionValueClosure = ( (ActionValue,IndexPath) -> Void )
    var action: ActionValueClosure? = nil
    
    public typealias ActionValueDataClosure = ( (ActionValue,FormDataSource,IndexPath) -> Void )
    var dataAction: ActionValueDataClosure? = nil
    
    public typealias ActionValueFormClosure = ( (ActionValue,FormController,IndexPath) -> Void )
    var formClosure: ActionValueFormClosure? = nil
    
    var title:String = "Action"
    var color:UIColor = UIColor.FormKit.text
    var uuid:String = UUID().uuidString
    
    public var readOnlyValue:ReadOnlyValue? = nil

}



extension ActionValue {
    
    
    public init(title: String, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.style = .moderate
    }
    
    
    public init(_ title: String,_ formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.style = .moderate
    }
    
    
    
    public init(title: String, color:UIColor, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.color = color
        self.style = .moderate
    }
    
    
    public init(title: String, color:UIColor,_ formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.color = color
        self.style = .moderate
    }
    
    
    public init(title: String, operatingTitle:String, color:UIColor, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.customOperatingTitle = operatingTitle
        self.color = color
        self.style = .moderate
    }
    
    
    public init(title: String,_ operatingTitle:String,_ color:UIColor,_ showDisclosure:Bool = false,_ formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.customOperatingTitle = operatingTitle
        self.color = color
        self.style = showDisclosure ? .disclosure : .moderate
    }

    
    /// ReadOnly init
    public init(_ readOnlyValue:ReadOnlyValue, formClosure: @escaping ActionValueFormClosure) {
        self.formClosure = formClosure
        self.readOnlyValue = readOnlyValue
        self.style = .readOnly
    }
    
    
    
}


extension ActionValue {
    
    
    
    
    
    
    public init(saveValue formClosure: @escaping ActionValueFormClosure) {
        self.title = "Save"
        self.formClosure = formClosure
        self.customOperatingTitle = "Saving"
        self.color = UIColor.FormKit.save
        self.style = .moderate
    }
    
}


// MARK: - Demo -
public extension ActionValue {
    
    static func Demo() -> ActionValue {
        ActionValue("Demo Action") { (_, _, _) in
            print("[ActionValueClosure] Hello Demo!")
        }
    }
    

    static func DemoForm() -> ActionValue {
        ActionValue("Demo Form") { (_, form, _) in
            form.navigationController?.pushViewController(
                FormController(formData: .Demo()),
                animated: true
            )
        }
    }
    
}



public extension ActionValue {
    
    func operatingVersion(_ newColor:UIColor? = .operating) -> ActionValue {
        ActionValue(
            state: .operating,
            customOperatingTitle: self.customOperatingTitle,
            style: self.style,
            customKey: self.customKey,
            action: self.action,
            dataAction: self.dataAction,
            formClosure: self.formClosure,
            title: self.title,
            color: (newColor ?? self.color),
            uuid: self.uuid,
            readOnlyValue: self.readOnlyValue
        )
    }
    
    
    func completedVersion(_ newTitle:String = "",_ newColor:UIColor? = .systemGreen) -> ActionValue {
        ActionValue(
            state: .complete,
            customOperatingTitle: self.customOperatingTitle,
            style: .moderate,
            customKey: self.customKey,
            action: self.action,
            dataAction: self.dataAction,
            formClosure: self.formClosure,
            title: newTitle,
            color: (newColor ?? self.color),
            uuid: self.uuid,
            readOnlyValue: self.readOnlyValue
        )
    }
    
    
    func readyVersion() -> ActionValue {
        ActionValue(
            state: .ready,
            customOperatingTitle: self.customOperatingTitle,
            style: .disclosure,
            customKey: self.customKey,
            action: self.action,
            dataAction: self.dataAction,
            formClosure: self.formClosure,
            title: self.title,
            color: self.color,
            uuid: self.uuid,
            readOnlyValue: self.readOnlyValue
        )
    }
    
    
    func disabled() -> ActionValue {
        var newValue = ActionValue(
            state: .disabled,
            customOperatingTitle: self.customOperatingTitle,
            style: .disclosure,
            customKey: self.customKey,
            action: self.action,
            dataAction: self.dataAction,
            formClosure: self.formClosure,
            title: self.title,
            color: self.color,
            uuid: self.uuid,
            readOnlyValue: self.readOnlyValue
        )
        
        newValue.lastState = self.state
        return newValue
        
    }
    
    func enabled() -> ActionValue {
        if let lastState = self.lastState {
           return ActionValue(
                state: lastState,
                customOperatingTitle: self.customOperatingTitle,
                style: self.style,
                customKey: self.customKey,
                action: self.action,
                dataAction: self.dataAction,
                formClosure: self.formClosure,
                title: self.title,
                color: self.color,
                uuid: self.uuid,
                readOnlyValue: self.readOnlyValue
            )
        } else {
            return ActionValue(
                state: .ready,
                customOperatingTitle: self.customOperatingTitle,
                style: self.style,
                customKey: self.customKey,
                action: self.action,
                dataAction: self.dataAction,
                formClosure: self.formClosure,
                title: self.title,
                color: self.color,
                uuid: self.uuid,
                readOnlyValue: self.readOnlyValue
            )
        }
        
    }
    
    
    
    func isValid() -> Bool {
        return state != .disabled
    }
    
    
}



extension ActionValue: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public var hash: Int {
        //return "\(title)+\(color)+\(uuid)+\(state)".hashValue
        return "\(title)+\(color)+\(uuid)".hashValue
    }
    
    public static func == (lhs: ActionValue, rhs: ActionValue) -> Bool {
        return lhs.hash == rhs.hash
    }

}




// MARK: - FormValue -
extension ActionValue: FormValue, TableViewSelectable {
    
    public func encodedValue() -> [String : String] {
        return [ (customKey ?? title) : "@ction!" ]
    }
    
    public var isSelectable: Bool {
        switch state {
        case .ready:
            return true
        case .operating, .complete, .disabled:
            return false
        }
    }
    
    public var formItem: FormItem {
        return FormItem.action(self)
    }
    
}

// MARK: - FormValueDisplayable -
extension ActionValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = ActionCell
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let selectedFormItem = formController.dataSource.itemAt(path) {
            switch selectedFormItem {
            case .action(let actionValue):
                switch actionValue.state {
                case .ready:
                    formClosure?(actionValue,formController,path)
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
}











// MARK: ActionCell
public final class ActionCell: UITableViewCell {
    static let identifier = "FormKit.ActionCell"
    
    private lazy var operatingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var operatingStackView = UIStackView()
    
    /// `ReadOnly` Styling
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
    
    var formValue : ActionValue? {
        didSet {
            guard let actionValue = formValue else { return }
            if actionValue.isSelectable == false {
                self.selectionStyle = .none
            }
            loadForState()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activateDefaultHeightAnchorConstraint()
        
        // ReadOnly Setup
        [titleLabel,valueLabel].forEach({
            contentView.addSubview($0)
            $0.isHidden = true
        })
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor),
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
            contentView.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8.0),
        ])
    }
    
    
    public override func prepareForReuse() {
        formValue = nil
        valueLabel.attributedText = nil
        titleLabel.text = nil
        operatingTitleLabel.text = nil
        operatingStackView.removeFromSuperview()
        textLabel?.text = nil
        accessoryType = .none
        super.prepareForReuse()
    }
    
    
    func loadForState() {
        guard let formValue = formValue else { return }
        switch formValue.state {
        case .ready:
            textLabel?.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
            loadFromValue()
        case .operating:
            setupCellForOperating(formValue.operatingTitle,formValue.color)
        case .complete:
            textLabel?.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
            loadFromValue()
        case .disabled:
            textLabel?.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
            loadFromValue(.disabled)
        }
    }
    
    
    private func setupCellForOperating(_ operatingTitle:String,_ color:UIColor) {
        textLabel?.text = nil
        accessoryType = .none
        operatingStackView.removeFromSuperview()
        operatingStackView = makeOperatingStackView(operatingTitle,color)
        contentView.addSubview(operatingStackView)
        
        operatingStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        operatingStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        operatingStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        operatingStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    
    private func makeOperatingStackView(_ operatingTitle:String,_ color:UIColor) -> UIStackView {
        
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        operatingTitleLabel.text = operatingTitle
        operatingTitleLabel.textColor = color
        operatingTitleLabel.sizeToFit()
        operatingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let progressView = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            progressView.style = .medium
        } else {
            progressView.style = .gray
        }
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(operatingTitleLabel)
        stackView.addArrangedSubview(progressView)
        
        progressView.startAnimating()
        
        return stackView
        
    }
    
    
    
    func loadFromValue(_ textColor:UIColor? = nil){
        guard let actionValue = formValue else { return }
        textLabel?.text = actionValue.title
        switch actionValue.style {
        case .disclosure:
            textLabel?.textAlignment = .center
            textLabel?.textColor = (textColor == nil) ? actionValue.color : textColor
            accessoryType = .disclosureIndicator
            titleLabel.isHidden = true
            valueLabel.isHidden = true
        case .none:
            textLabel?.text = actionValue.title
            accessoryType = .none
            titleLabel.isHidden = true
            valueLabel.isHidden = true
        case .moderate:
            textLabel?.textAlignment = .center
            textLabel?.textColor = (textColor == nil) ? actionValue.color : textColor
            accessoryType = .none
            titleLabel.isHidden = true
            valueLabel.isHidden = true
        case .readOnly:
            textLabel?.text = nil
            accessoryType = .none
            titleLabel.text = actionValue.readOnlyValue?.title
            valueLabel.attributedText = actionValue.readOnlyValue?.valueAttributedText
            titleLabel.isHidden = false
            valueLabel.isHidden = false
        }
    }
    
}





