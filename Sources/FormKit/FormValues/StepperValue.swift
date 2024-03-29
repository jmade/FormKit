//
//  StepperValue.swift
//  FW Device
//
//  Created by Justin Madewell on 12/15/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit

// TODO: Add in the ability to step in whole numbers or by a defined amount
// -- also add in a formater ?

// MARK: - StepperValue -
public struct StepperValue: FormValue, TableViewSelectable, Equatable, Hashable {
    
    public var isSelectable: Bool {
        return false
    }
    
    public var customKey:String? = nil
    
    public var title:String
    public var info:String? = nil
    public var value:Double
    public var validators: [Validator] = []
}



extension StepperValue {
    
    public init(title: String,value:Double) {
        self.title = title
        self.value = value
    }
    
    public init(title: String) {
        self.title = title
        self.value = 0.0
    }
    
    public init(_ title:String,_ customKey:String? = nil,_ info:String?,_ value:Double = 0.0) {
        self.title = title
        self.value = value
        self.customKey = customKey
        self.info = info
    }
    
    
    public init(_ title:String,_ customKey:String,_ value:Double) {
        self.title = title
        self.value = value
        self.customKey = customKey
    }
    

    
    public init(_ title:String,_ customKey:String? = nil) {
        self.title = title
        self.value = 0.0
        self.customKey = customKey
    }
    
}


extension StepperValue {
    
    public func newWith(_ newTitle:String) -> StepperValue {
        StepperValue(customKey: self.customKey, title: newTitle, info: self.info, value: self.value)
    }
    
    public func newWith(_ newValue:Double) -> StepperValue {
        StepperValue(customKey: self.customKey, title: self.title, info: self.info, value: newValue)
       }
    
}




//: MARK: - FormValueDisplayable -
extension StepperValue: FormValueDisplayable {
    
    public typealias Cell = StepperCell
    public typealias Controller = FormController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        /*  */
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    
}


extension StepperValue {

    
    public func encodedValue() -> [String : String] {
        return [(customKey ?? title) : "\(value)" ]
    }
    
    
    public var formItem: FormItem {
        .stepper(self)
    }
}


extension StepperValue {
    
    public var intValue: Int {
        Int(value)
    }
    
    
    public static func Random() -> StepperValue {
        return StepperValue(title: "Stepper \(UUID().uuidString.split(separator: "-")[1])", value: Double.random(in: 0...99) )
    }
    
    public static func Demo() -> StepperValue {
        StepperValue(title: "Demo Stepper", value: 10)
    }
}





//: MARK: StepperCell
public final class StepperCell: UITableViewCell {
    static let identifier = "stepperCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    private lazy var stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.maximumValue = 500
        stepper.minimumValue = -500
        stepper.wraps = false
        stepper.addTarget(self, action: #selector(stepperStepped(_:)), for: .valueChanged)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stepper)
        return stepper
    }()
    
    
    private lazy var stepperLabel: BadgeSwift = {
        let badge = BadgeSwift()
        if #available(iOS 13.0, *) {
            badge.badgeColor = .systemGray4
        } else {
            badge.badgeColor = .lightGray
        }
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.setContentHuggingPriority(.required, for: .horizontal)
        badge.setContentHuggingPriority(.required, for: .vertical)
        contentView.addSubview(badge)
        return badge
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.addSubview(label)
        return label
    }()
    
    
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .lightGray
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    
    
    var indexPath:IndexPath?
    
    var formValue:StepperValue? {
        didSet {
            if let stepperValue = formValue {
                stepper.value = stepperValue.value
                stepperLabel.text = String(Int(stepperValue.value))
                titleLabel.text = stepperValue.title
                infoLabel.text = stepperValue.info
                if stepperValue.isSelectable == false {
                    self.selectionStyle = .none
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activateDefaultHeightAnchorConstraint()
        
        let stepperTrailingConstraint = stepper.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        stepperTrailingConstraint.priority = UILayoutPriority(900.0)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: stepperLabel.leadingAnchor, constant: -8.0),
            
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            stepperLabel.trailingAnchor.constraint(equalTo: stepper.leadingAnchor, constant: -8.0),
            
            stepperLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            
            infoLabel.leadingAnchor.constraint(equalTo: stepperLabel.trailingAnchor, constant: 8.0),
            infoLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: stepper.leadingAnchor, constant: -4.0),
            
            stepperTrailingConstraint,
            stepper.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            ])
    }
    
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    
    
    @objc
    func stepperStepped(_ sender:UIStepper) {
        FormConstant.makeSelectionFeedback()
        stepperLabel.text = String(Int(sender.value))
        if let stepperValue = formValue {
            let newValue = stepperValue.newWith(sender.value)
            updateFormValueDelegate?.updatedFormValue(newValue, indexPath)
        }
    }
}

