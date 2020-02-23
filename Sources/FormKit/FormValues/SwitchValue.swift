//
//  File.swift
//  
//
//  Created by Justin Madewell on 2/23/20.
//

import UIKit

// MARK: - SwitchValue -
public struct SwitchValue: Equatable, Hashable {

    public var title:String
    public var value:Bool = false
    public var customKey:String? = nil
}


extension SwitchValue {
    
    public init(_ title:String,value:Bool) {
        self.title = title
        self.value = value
    }
    
}


extension SwitchValue {
    
    public func newWith(_ state:Bool) -> SwitchValue {
        SwitchValue(title: self.title, value: state, customKey: self.customKey)
    }
    
}




// MARK: - FormValue -

extension SwitchValue: FormValue, TableViewSelectable {
    public func encodedValue() -> [String : String] {
           return [ (customKey ?? title) : "\(value)" ]
       }
       
       public var isSelectable: Bool {
           return true
       }
       
       public var formItem: FormItem {
           return FormItem.switchValue(self)
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
            currentState = switchValue.value
            switchControl.setOn(switchValue.value, animated: true)
        }
    }
    
    /// State
    private var currentState: Bool = false {
        didSet {
            
            if currentState != oldValue {
                resolveState()
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
        currentState.toggle()
    }
    
    
    private func resolveState() {
        switchControl.setOn(currentState, animated: true)
        
        if let switchValue = formValue {
            updateFormValueDelegate?.updatedFormValue(
                switchValue.newWith(currentState),
                indexPath
            )
        }
        
    }
    
}


extension SwitchCell {
    
    @objc private func handleSwitch(_ switchControl:UISwitch) {
        
    }
    
}
