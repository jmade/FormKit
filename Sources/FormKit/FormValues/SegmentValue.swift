import UIKit

//: MARK: - SegmentValue -
public struct SegmentValue: FormValue, TableViewSelectable {
    
    public var isSelectable: Bool {
        return false
    }
    
    public var formItem: FormItem {
        get {
            return .segment(self)
        }
    }
    
    public var customKey:String? = nil
    public let selectedValue:Int
    public var values:[String]
    public let uuid:String
    
    public typealias SegmentValueChangeClosure = ( (SegmentValue,FormController,IndexPath) -> Void )
    public var valueChangeClosure: SegmentValueChangeClosure? = nil
    public var validators: [Validator] = []
    
}



extension SegmentValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    public var hashValue: Int {
        return uuid.hashValue
    }
}


extension SegmentValue: Equatable {
    public static func == (lhs: SegmentValue, rhs: SegmentValue) -> Bool {
           return lhs.uuid == rhs.uuid
       }
}


extension SegmentValue {
    
    public init(values: [String],_ selectedValue:Int = 0) {
        self.uuid = UUID().uuidString
        self.values = values
        self.selectedValue = selectedValue
    }
    
    
    public init(_ values: [String],_ customKey:String? = nil,_ selectedValue:Int = 0) {
        self.uuid = UUID().uuidString
        self.values = values
        self.selectedValue = selectedValue
        self.customKey = customKey
    }
    
    
    
    public init(_ values: [String],_ selectedValue:Int = 0, valueChangeClosure: @escaping SegmentValueChangeClosure) {
        self.uuid = UUID().uuidString
        self.values = values
        self.selectedValue = selectedValue
        self.valueChangeClosure = valueChangeClosure
    }
    
    
    public init(_ values: [String],_ selectedValue:Int,_ valueChangeClosure: @escaping SegmentValueChangeClosure) {
        self.uuid = UUID().uuidString
        self.values = values
        self.selectedValue = selectedValue
        self.valueChangeClosure = valueChangeClosure
    }
    
    
    public init(from:SegmentValue,_ selectedIndex:Int) {
        self.uuid = UUID().uuidString
        self.selectedValue = selectedIndex 
        self.values = from.values
        self.customKey = from.customKey
        self.valueChangeClosure = from.valueChangeClosure
    }
    
}


extension Array where Element == SegmentValue.SegmentValueOption {
    
    var selectedValue:Int {
        for (index,opiton) in self.enumerated() {
            if opiton.selected {
                return index
            }
        }
        return 0
    }
    
    var values:[String] {
        self.map({  $0.title })
    }
}


extension Array where Element == SegmentValue.FormValuesOption {
    
    var selectedValue:Int {
        for (index,opiton) in self.enumerated() {
            if opiton.selected {
                return index
            }
        }
        return 0
    }
    
    var values:[String] {
        self.map({  $0.title })
    }
}


public extension SegmentValue {
    
    struct SegmentValueOption {
        public var title:String
        public var selected: Bool
        public var valueChange: SegmentValue.SegmentValueChangeClosure
    }
    
    init(options:[SegmentValueOption]) {
        self.uuid = UUID().uuidString
        self.values = options.values
        self.selectedValue = options.selectedValue
        self.valueChangeClosure = SegmentValue.ValueChangeUsingOptions(options: options)
    }
    
    
    
    static func ValueChangeUsingOptions(options:[SegmentValueOption]) -> SegmentValue.SegmentValueChangeClosure {
        { (segmentValue,form,path) in
            
            let selectedOption = options[segmentValue.selectedValue]
            selectedOption.valueChange(segmentValue,form,path)
        }
    }
    
    
    static func ValueChangeUsingFormValuesOptions(options:[FormValuesOption]) -> SegmentValue.SegmentValueChangeClosure {
        { (segmentValue,form,path) in
            
            guard let section = form.dataSource.section(for: path.section) else  { return }
            
            if let lastSegmentValue = form.lastSegmentValue {
                let lastSelectedValue = lastSegmentValue.selectedValue
                let lastSelectedOption = options[lastSelectedValue]
                
                var newRows = lastSelectedOption.formValues
                newRows.insert(segmentValue, at: 0)
                form.dataSource.storage["CustomRows"] = Array(section.rows.dropFirst())
            }
            
            let selectedValue = segmentValue.selectedValue
            let selectedOption = options[selectedValue]
            
            var newRows = selectedOption.formValues
            newRows.insert(segmentValue, at: 0)
            
            
            
            
            let newData = form.dataSource.newWith([
                section.newWithRows(
                    newRows.map({ $0.formItem })
                ),
            ])
            
            newData.storage["lastSection"] = section
            
            form.setNewData(
                form.dataSource.newWith([
                    section.newWithRows(
                        newRows.map({ $0.formItem })
                    ),
                ])
            )
            
            
        }
    }
    
    
    struct FormValuesOption {
        public var title: String
        public var selected: Bool
        public var formValues: [FormValue]
    }
    
    init(formValueOptions options:[FormValuesOption]) {
        self.uuid = UUID().uuidString
        self.values = options.values
        self.selectedValue = options.selectedValue
        self.valueChangeClosure = SegmentValue.ValueChangeUsingFormValuesOptions(options: options)
    }
    
}


public extension SegmentValue.SegmentValueOption {
    
    init(_ title:String,_ valueChangeClosure: @escaping SegmentValue.SegmentValueChangeClosure) {
        self.title = title
        self.selected = false
        self.valueChange = valueChangeClosure
    }
    
    init(_ title:String,_ selected:Bool,_ valueChangeClosure: @escaping SegmentValue.SegmentValueChangeClosure) {
        self.title = title
        self.selected = selected
        self.valueChange = valueChangeClosure
    }
    
}


public extension SegmentValue.FormValuesOption {
    
    init(_ title:String,_ formValues:[FormValue]) {
        self.title = title
        self.selected = false
        self.formValues = formValues
    }
    
    init(selectedTitle:String,_ formValues:[FormValue]) {
        self.title = selectedTitle
        self.selected = true
        self.formValues = formValues
    }
    
}



extension SegmentValue: FormValueDisplayable {
    
    public typealias Cell = SegmentCell
    public typealias Controller = FormController
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        //
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}

extension SegmentValue {
    public static func Random() -> SegmentValue {
        let values = Array(1...Int.random(in: 2...4)).map({ "Segment \($0)" })
        return SegmentValue(values: values, Int.random(in: 0...values.count-1))
    }
    
    
    public static func Demo() -> SegmentValue {
        return SegmentValue(values: ["Morning","Day","Night"], [0,1,2].randomElement()!)
    }
    
    
}


extension SegmentValue {
    
    
    public func encodedValue() -> [String : String] {
        if let key = customKey {
            return [key:values[selectedValue]]
        } else {
            return ["SegmentValue":values[selectedValue]]
        }
    }
    
}





//: MARK: SegmentCell
public final class SegmentCell: UITableViewCell {
    static let identifier = "jmade.FormKit.SegmentCell.identifier"
    
    var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath:IndexPath?
    
    var formValue : SegmentValue? {
        didSet {
            if let segmentValue = formValue  {
                for (i,v) in segmentValue.values.enumerated() {
                    segmentedControl.insertSegment(withTitle: v, at: i, animated: true)
                }
                segmentedControl.selectedSegmentIndex = segmentValue.selectedValue
                
                if segmentValue.isSelectable == false {
                    self.selectionStyle = .none
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        segmentedControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        contentView.addSubview(segmentedControl)
        
        let heightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
        heightAnchorConstraint.isActive = true
        
        let margin = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: margin.topAnchor),
            margin.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            ])
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        segmentedControl.removeAllSegments()
    }
    
    @objc
    func valueChanged(_ sender:UISegmentedControl) {
        FormConstant.makeSelectionFeedback()
        if let segmentValue = formValue {
            updateFormValueDelegate?.updatedFormValue(
                SegmentValue(from: segmentValue,sender.selectedSegmentIndex),
                indexPath
            )
        }
    }
    
}
