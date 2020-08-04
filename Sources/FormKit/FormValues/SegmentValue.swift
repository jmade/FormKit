import UIKit

//: MARK: - SegmentValue -
public struct SegmentValue: FormValue, TableViewSelectable {
    
    public var isSelectable: Bool {
        return false
    }
    
    public var formItem: FormItem {
        get {
            return FormItem.segment(self)
        }
    }
    
    public var customKey:String? = "SegmentValue"
    public let selectedValue:Int
    public var values:[String]
    public let uuid:String
    
    public typealias SegmentValueChangeClosure = ( (SegmentValue,FormController,IndexPath) -> Void )
    public var valueChangeClosure: SegmentValueChangeClosure? = nil
    
    
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
    
    
    public init(_ values: [String],_ selectedValue:Int = 0, valueChangeClosure: @escaping SegmentValueChangeClosure) {
        self.uuid = UUID().uuidString
        self.values = values
        self.selectedValue = selectedValue
        self.valueChangeClosure = valueChangeClosure
    }
    
    
    public init(from:SegmentValue,_ selectedIndex:Int) {
        self.uuid = from.uuid
        self.selectedValue = selectedIndex
        self.values = from.values
        self.customKey = from.customKey
        self.valueChangeClosure = from.valueChangeClosure
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
    static let identifier = "jmade.FormKit.segmentCell.identifier"
    
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
