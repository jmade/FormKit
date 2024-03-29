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
       case none, disclosure, moderate, readOnly, add
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
    public var originalId:String? = nil
    public var validators: [Validator] = []

}



extension ActionValue {
    
    
    public init(title: String, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.style = .moderate
    }
    
    
    public init(_ title: String,_ formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.style = .moderate
    }
    
    
    
    public init(title: String, color:UIColor, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.color = color
        self.style = .moderate
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
    }
    
    
    public init(title: String, color:UIColor,_ formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.color = color
        self.style = .moderate
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
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
    
    public init(title: String, color:UIColor, state:ActionState, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.formClosure = formClosure
        self.color = color
        self.style = .moderate
        self.state = state
    }
    
    
    public init(_ title: String,_ color:UIColor,_ state:ActionState = .disabled, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.formClosure = formClosure
        self.color = color
        self.style = .moderate
        self.state = state
    }
    
}


// Save / Submit

extension ActionValue {
    
    public init(saveValue formClosure: @escaping ActionValueFormClosure) {
        self.title = "Save"
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.formClosure = formClosure
        self.customOperatingTitle = "Saving"
        self.color = UIColor.FormKit.save
        self.style = .moderate
    }
    
    
    public init(saveValueDisabled formClosure: @escaping ActionValueFormClosure) {
        self.title = "Save"
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.formClosure = formClosure
        self.customOperatingTitle = "Saving"
        self.color = UIColor.FormKit.save
        self.style = .moderate
        self.state = .disabled
    }
    

    public init(submitValue formClosure: @escaping ActionValueFormClosure) {
        self.title = "Submit"
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.formClosure = formClosure
        self.customOperatingTitle = "Submitting"
        self.color = UIColor.FormKit.save
        self.style = .moderate
    }
    
    
    public init(submitValueDisabled formClosure: @escaping ActionValueFormClosure) {
        self.title = "Submit"
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.formClosure = formClosure
        self.customOperatingTitle = "Submitting"
        self.color = UIColor.FormKit.save
        self.style = .moderate
        self.state = .disabled
    }
    
    /*
    public init(submitValueDisabled title:String,_ formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.customKey = "\(title.uppercased())-\(UUID().uuidString.split("-").first ?? "!!")"
        self.formClosure = formClosure
        self.color = UIColor.FormKit.save
        self.style = .moderate
        self.state = .disabled
    }
    */

    public static func Submit(_ formClosure: @escaping ActionValueFormClosure) -> ActionValue {
        ActionValue(submitValueDisabled: formClosure)
    }
    
    public static func Submit(_ title:String,_ formClosure: @escaping ActionValueFormClosure) -> ActionValue {
        var value = ActionValue(submitValueDisabled: formClosure)
        value.title = title
        return value
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
    
    func operatingVersion(_ newTitle:String = "",_ newColor:UIColor? = .operating) -> ActionValue {
        ActionValue(
            state: .operating,
            customOperatingTitle: self.customOperatingTitle,
            style: self.style,
            customKey: self.customKey,
            action: self.action,
            dataAction: self.dataAction,
            formClosure: self.formClosure,
            title: (newTitle.isEmpty ? self.title : newTitle),
            color: (newColor ?? self.color),
            uuid: UUID().uuidString,
            readOnlyValue: self.readOnlyValue,
            originalId: self.uuid
        )
    }
    
    
    func completedVersion(_ newTitle:String = "",_ newColor:UIColor? = .success) -> ActionValue {
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
            uuid: UUID().uuidString,
            readOnlyValue: self.readOnlyValue,
            originalId: self.uuid
        )
    }
    
    
    func readyVersion(_ newTitle:String? = nil,_ newColor:UIColor? = nil) -> ActionValue {
        ActionValue(
            state: .ready,
            customOperatingTitle: self.customOperatingTitle,
            style: self.style,
            customKey: self.customKey,
            action: self.action,
            dataAction: self.dataAction,
            formClosure: self.formClosure,
            title: newTitle ?? self.title,
            color: newColor ?? self.color,
            uuid: UUID().uuidString,
            readOnlyValue: self.readOnlyValue,
            originalId: self.uuid
        )
    }
    
    
    func disabled() -> ActionValue {
        var newValue = ActionValue(
            state: .disabled,
            customOperatingTitle: self.customOperatingTitle,
            style: self.style,
            customKey: self.customKey,
            action: self.action,
            dataAction: self.dataAction,
            formClosure: self.formClosure,
            title: self.title,
            color: self.color,
            uuid: UUID().uuidString,
            readOnlyValue: self.readOnlyValue,
            originalId: self.uuid
        )
        
        newValue.lastState = self.state
        return newValue
    }
    
    
    func enabled() -> ActionValue {
           var newValue =  ActionValue(
               state: .ready,
               customOperatingTitle: self.customOperatingTitle,
               style: self.style,
               customKey: self.customKey,
               action: self.action,
               dataAction: self.dataAction,
               formClosure: self.formClosure,
               title: self.title,
               color: self.color,
               uuid: UUID().uuidString,
               readOnlyValue: self.readOnlyValue,
               originalId: self.uuid
           )
        newValue.lastState = self.state
        return newValue
       }
    
    
    /*
    func enabled() -> ActionValue {
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
            uuid: UUID().uuidString,
            readOnlyValue: self.readOnlyValue,
            originalId: self.uuid
        )
    }
    */
    
    
    func isValid() -> Bool {
        return state != .disabled
    }
    
    
    func dataMatches(_ av:ActionValue) -> Bool {
        
        if let original = self.originalId {
            if av.uuid == original {
                return true
            }
        }
        
        return customKey == av.customKey
    }
    
    
}



extension ActionValue: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    
    public var hash: Int {
        return "\(title)+\(color)+\(uuid)".hashValue
    }
    
    public static func == (lhs: ActionValue, rhs: ActionValue) -> Bool {
        return lhs.hash == rhs.hash
    }

}



extension ActionValue: CustomStringConvertible {
    public var description: String {
        """
        
        ActionValue:
         Title: \(title)
         UUID: \(uuid)
         State: \(state)
         TitleColor: \(color)
         isValid: \(state != .disabled)
        
        """
    }
}




// MARK: - FormValue -
extension ActionValue: FormValue, TableViewSelectable {
    
    public func encodedValue() -> [String : String] {
        return [ (customKey ?? title) : "" ]
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
        .action(self)
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
    
    private var operatingStackView = UIStackView()
    
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
        if contentView.subviews.contains(operatingStackView) {
            operatingStackView.removeFromSuperview()
        }
        
        textLabel?.text = nil
        accessoryType = .none
        super.prepareForReuse()
    }
    
    
    public func setDisabled() {
        textLabel?.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        textLabel?.textColor = .disabled
        self.selectionStyle = .none
    }
    
    
    public func setEnabled() {
        textLabel?.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        loadFromValue()
        if selectionStyle == .none {
            self.selectionStyle = .default
        }
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
        case .add:
            textLabel?.textAlignment = .center
            textLabel?.textColor = (textColor == nil) ? actionValue.color : textColor
            
        }
        
    }
    
}





