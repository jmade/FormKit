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
    public var value:Double
}



extension StepperValue {
    
    public init(title: String,value:Double) {
        self.title = title
        self.value = value
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
        return [(customKey ?? title):"\(value)"]
    }
    
    
    public var formItem: FormItem {
           return FormItem.stepper(self)
       }
}


extension StepperValue {
    
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
        stepper.maximumValue = 99
        stepper.minimumValue = 0
        stepper.wraps = false
        return stepper
    }()
    
    
    private lazy var stepperLabel: BadgeSwift = {
        let badge = BadgeSwift()
        if #available(iOS 13.0, *) {
            badge.badgeColor = .systemGray4
        } else {
            badge.badgeColor = .lightGray
        }
        return badge
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
    var indexPath:IndexPath?
    
    var formValue:StepperValue? {
        didSet {
            if let stepperValue = formValue {
                stepper.value = stepperValue.value
                stepperLabel.text = String(Int(stepperValue.value))
                titleLabel.text = stepperValue.title
                if stepperValue.isSelectable == false {
                    self.selectionStyle = .none
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [stepper,stepperLabel,titleLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        stepper.addTarget(self, action: #selector(stepperStepped(_:)), for: .valueChanged)
        
        activateDefaultHeightAnchorConstraint()
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            stepperLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
            stepperLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            stepper.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -4.0),
            stepper.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stepper.bottomAnchor, constant: 2.0)
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
            updateFormValueDelegate?.updatedFormValue(StepperValue(title: stepperValue.title, value: sender.value), indexPath)
        }
    }
}

