
import UIKit

// MARK: - ActionValue -
public struct ActionValue: Equatable {
    
    public enum ActionState {
        case ready, operating, complete
    }
    
    var state:ActionState = .ready
    
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
       case none, discolosure, moderate
    }
    var style:ActionStyle = .discolosure
    
    public var customKey:String? = "ActionValue"
    
    public typealias ActionValueClosure = ( (ActionValue,IndexPath) -> Void )
    var action: ActionValueClosure? = nil
    
    public typealias ActionValueDataClosure = ( (ActionValue,FormDataSource,IndexPath) -> Void )
    var dataAction: ActionValueDataClosure? = nil
    
    public typealias ActionValueFormClosure = ( (ActionValue,FormController,IndexPath) -> Void )
    var formClosure: ActionValueFormClosure? = nil
    
    var title:String = "Action"
    var color:UIColor = .systemBlue
    var uuid:String = UUID().uuidString

}

public extension ActionValue {
    
    init(title: String,color:UIColor,style:ActionStyle = .discolosure,action: @escaping ActionValueClosure) {
        self.title = title
        self.color = color
        self.action = action
        self.style = style
        self.uuid = UUID().uuidString
    }
    
    init(title: String,color:UIColor, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.color = color
        self.style = .discolosure
    }
    
    
    init(title: String, operatingTitle:String, color:UIColor, formClosure: @escaping ActionValueFormClosure) {
        self.title = title
        self.formClosure = formClosure
        self.customOperatingTitle = operatingTitle
        self.color = color
        self.style = .discolosure
    }

}


// MARK: - Demo -
public extension ActionValue {
    
    static func Demo() -> ActionValue {
        return ActionValue(title: "Demo Action", color: .purple, style: .moderate) {_,_ in
            print("[ActionValueClosure] Hello!")
        }
    }
    
    
    static func DemoForm() -> ActionValue {
        ActionValue(title: "Demo Form", color: .purple, formClosure: { (actionValue, form, path) in
            form.navigationController?.pushViewController(
                FormController(formData: .Demo()),
                animated: true
            )
        })
    }
    
    
    static func DemoAdd() -> ActionValue {
        
        ActionValue(title: "Add", color: .blue, formClosure: { (actionValue, form, path) in
            
            if let lastSection = form.dataSource.sections.last {
                
                let newRows = [
                    ActionValue.DemoAdd().formItem
                ]
                
                let newFormItems = [lastSection.rows,newRows]
                    .reduce([],+)
                
                let newLastSection = FormSection(
                    lastSection.title,
                    newFormItems
                )
                
                let newSections = [
                    form.dataSource.sections[0],
                    form.dataSource.sections[1],
                    form.dataSource.sections[2],
                    newLastSection,
                ]
                
                let newFormData = FormDataSource(title: form.dataSource.title, sections: newSections)
                
                form.dataSource = newFormData
            
            }

        })
    }

    
    static func DemoExp() -> ActionValue {
        
        ActionValue(title: "Exp!", color: .systemYellow, formClosure: { (actionValue, form, path) in
            let sectionIndex = Array(0...(form.dataSource.sections.count-2)).randomElement()!
            let newDataSource = form.dataSource.newWithSection(.Random(), at: sectionIndex)
            form.dataSource = newDataSource
        })
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
            uuid: self.uuid
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
            uuid: self.uuid
        )
    }
    
    
    func readyVersion() -> ActionValue {
        ActionValue(
            state: .ready,
            customOperatingTitle: self.customOperatingTitle,
            style: .discolosure,
            customKey: self.customKey,
            action: self.action,
            dataAction: self.dataAction,
            formClosure: self.formClosure,
            title: self.title,
            color: self.color,
            uuid: self.uuid
        )
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




// MARK: - FormValue -
extension ActionValue: FormValue, TableViewSelectable {
    
    public func encodedValue() -> [String : String] {
        return [ (customKey ?? title) : "->" ]
    }
    
    public var isSelectable: Bool {
        switch state {
        case .ready:
            return true
        case .operating:
            return false
        case .complete:
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

    var formValue : ActionValue? {
        didSet {
            if let actionValue = formValue {
                loadForState()
                if actionValue.isSelectable == false {
                    self.selectionStyle = .none
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activateDefaultHeightAnchorConstraint()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
        operatingTitleLabel.text = nil
        operatingStackView.removeFromSuperview()
        textLabel?.text = nil
        accessoryType = .none
    }
    
    
    func loadForState() {
        guard let formValue = formValue else { return }
        switch formValue.state {
        case .ready:
            loadFromValue()
        case .operating:
            setupCellForOperating(formValue.operatingTitle,formValue.color)
        case .complete:
            textLabel?.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
            loadFromValue()
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
    
    func loadFromValue(){
        guard let formValue = formValue else { return }
        textLabel?.text = formValue.title
        switch formValue.style {
        case .discolosure:
            textLabel?.textAlignment = .center
            textLabel?.textColor = formValue.color
            accessoryType = .disclosureIndicator
        case .none:
            textLabel?.text = formValue.title
            accessoryType = .none
        case .moderate:
            textLabel?.textAlignment = .center
            textLabel?.textColor = formValue.color
            accessoryType = .none
        }
    }
    
}





