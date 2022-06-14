

import UIKit

// MARK: - SwitchValue -
public struct SwitchValue {
    var identifier: UUID = UUID()
    public var title:String
    public var value:Bool = false
    public var customKey:String? = nil
    public var validators: [Validator] = []
}


extension SwitchValue {
    
    public init(_ title:String,value:Bool) {
        self.title = title
        self.value = value
    }
    
    public init(_ title:String,_ value:Bool,_ customKey:String? = nil) {
        self.title = title
        self.value = value
        self.customKey = customKey
    }
    
    public init(_ title:String,_ customKey:String) {
        self.title = title
        self.customKey = customKey
        self.value = false
    }
    
}



extension SwitchValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: SwitchValue, rhs: SwitchValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}





extension SwitchValue {
    
    public func newToggled() -> SwitchValue {
        SwitchValue(identifier: UUID(), title: self.title, value: !self.value, customKey: self.customKey)
    }
    
}




// MARK: - FormValue -

extension SwitchValue: FormValue, TableViewSelectable {
    public func encodedValue() -> [String : String] {
        [ (customKey ?? title) : "\(value ? "1" : "0")" ]
    }
       
       public var isSelectable: Bool {
           return true
       }
       
       public var formItem: FormItem {
           .switchValue(self)
       }
}


extension SwitchValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = SwitchCell
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}


extension SwitchValue {
    public static func Random() -> SwitchValue {
        SwitchValue(
            ["Lights On","Machine Running","Start Processing"].randomElement()!,
            value: Bool.random()
        )
    }
}




// MARK: SwitchCell
public final class SwitchCell: UITableViewCell {
    static let identifier = "FormKit.SwitchCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    public lazy var indexPath: IndexPath? = nil
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitch(_:)), for: .allEvents)
        self.contentView.addSubview(switchControl)
        return switchControl
    }()
    
    
    var formValue : SwitchValue? {
        didSet {
            guard let switchValue = formValue else { return }
            if switchValue.isSelectable == false {
                self.selectionStyle = .none
            }
            titleLabel.text = switchValue.title
            if oldValue == nil {
                switchControl.setOn(switchValue.value, animated: true)
            }
        }
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activateDefaultHeightAnchorConstraint()
        self.selectionStyle = .none
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            switchControl.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
    }
    
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            if switchControl.isOn {
                switchControl.setOn(false, animated: true)
                handleSwitch(switchControl)
            } else {
                switchControl.setOn(true, animated: true)
                handleSwitch(switchControl)
            }
        }
        
    }
    
    
    private func selectionOccured() {
        performFeedback()
        guard let switchValue = formValue else { return }
        var newSwitchValue = SwitchValue(switchValue.title, value: switchControl.isOn)
        newSwitchValue.customKey = switchValue.customKey
        updateFormValueDelegate?.updatedFormValue(
            newSwitchValue,
            indexPath
        )
    }
    
    
    private func performFeedback() {
        let feedback = UIImpactFeedbackGenerator()
        feedback.prepare()
        feedback.impactOccurred()
    }
    
   
}


extension SwitchCell {
    
    @objc private func handleSwitch(_ switchControl:UISwitch) {
        selectionOccured()
    }
    
}
