import UIKit


// MARK: - CustomValue -
public struct CustomValue {
    var identifier: UUID = UUID()
    public var customKey:String? = "CustomValue"
    
    public typealias CellConfigurationClosure = (CustomValueCell) -> Void
    public var cellConfigurationClosure:CellConfigurationClosure? = nil
    
    public typealias CellDidTapClosure = (CustomValueCell) -> Bool
    public var cellDidTapClosure:CellDidTapClosure? = nil
    
    public var validators: [Validator] = []
    
}


// init

public extension CustomValue {
    
    init(cellConfiguration: @escaping CellConfigurationClosure,cellDidTap: @escaping CellDidTapClosure) {
        self.cellConfigurationClosure = cellConfiguration
        self.cellDidTapClosure = cellDidTap
    }

}


// MARK: - FormValue -
extension CustomValue: FormValue {

    public var formItem: FormItem {
        .custom(self)
    }
    
    public func encodedValue() -> [String : String] {
        [(customKey ?? "CustomValue") : ""]
    }
}


//: MARK: - FormValueDisplayable -
extension CustomValue: FormValueDisplayable {
    
    public typealias Cell = CustomValueCell
    public typealias Controller = FormController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.ReuseID, configureCell, didSelect)
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








extension CustomValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: CustomValue, rhs: CustomValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}



public class CustomView: UIView {
    
}


//: MARK: CustomValueCell
public final class CustomValueCell: UITableViewCell {
    
    static let ReuseID = "com.jmade.FormKit.CustomValueCell.identifier"
    
    var formValue : CustomValue? {
        didSet {
            guard let customValue = formValue else { return }
            customValue.cellConfigurationClosure?(self)
        }
    }
    
    public var customView:CustomView? = nil
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath:IndexPath?
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        for subView in contentView.subviews {
            subView.removeFromSuperview()
        }
        formValue = nil
        customView = nil
    }
    
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            
            if let customValue = formValue {
                if let closure = customValue.cellDidTapClosure {
                    let closureResult = closure(self)
                    if closureResult {
                        if let path = indexPath {
                            updateFormValueDelegate?.updatedFormValue(customValue, path)
                        }
                    }
                }
            }
            //formValue?.cellDidTapClosure?(self)
        }
    }
    
}





