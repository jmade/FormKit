import UIKit


// MARK: - CustomValue -
public struct CustomValue {
    
    var identifier: UUID = UUID()
    public var customKey:String? = "CustomValue"
    
    public typealias CellConfigurationClosure = (CustomValue,CustomValueCell) -> Void
    public var cellConfigurationClosure:CellConfigurationClosure? = nil
    
    public typealias CustomValueSelectionClosure = ( (CustomValue,FormController,IndexPath) -> Void )
    public var selectionClosure:CustomValueSelectionClosure? = nil
    
    public typealias CellDidTapClosure = (CustomValue,CustomValueCell) -> Bool
    public var cellDidTapClosure:CellDidTapClosure? = nil
    
    public var validators: [Validator] = []
    
    public var customStore:[String:Any] = [:]
    
}


// init

public extension CustomValue {
    
    init(cellConfiguration: @escaping CellConfigurationClosure) {
        self.cellConfigurationClosure = cellConfiguration
    }
    
    init(cellConfiguration: @escaping CellConfigurationClosure, cellDidTap: @escaping CellDidTapClosure) {
        self.cellConfigurationClosure = cellConfiguration
        self.cellDidTapClosure = cellDidTap
    }
    
    init(cellConfiguration: @escaping CellConfigurationClosure, selectionClosure: @escaping CustomValueSelectionClosure) {
        self.cellConfigurationClosure = cellConfiguration
        self.selectionClosure = selectionClosure
    }
    
    func withNewIdentifier() -> CustomValue {
        var copy = self
        copy.identifier = UUID()
        return copy
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
        if let selectedFormItem = formController.dataSource.itemAt(path) {
            switch selectedFormItem {
            case .custom(let customValue):
                selectionClosure?(customValue,formController,path)
            default:
                break
            }
        }
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
        cell.tableView = formController.tableView
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


//: MARK: CustomValueCell
public final class CustomValueCell: UITableViewCell {
    
    static let ReuseID = "com.jmade.FormKit.CustomValueCell.identifier"
    
    var formValue : CustomValue? {
        didSet {
            guard let customValue = formValue else { return }
            customValue.cellConfigurationClosure?(customValue,self)
        }
    }
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    var indexPath:IndexPath?
    var tableView: UITableView?
    
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
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard let customValue = formValue else { return }
        
        if selected {
            if let closure = customValue.cellDidTapClosure {
                if closure(customValue,self) {
                    handleHeightUpdates()
                }
            }
        }
        
    }
    
    
    private func handleHeightUpdates() {
        self.tableView?.beginUpdates()
        for subView in contentView.subviews {
            subView.sizeToFit()
        }
        self.tableView?.endUpdates()
    }
    
}





