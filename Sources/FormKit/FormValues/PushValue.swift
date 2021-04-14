
import UIKit

// MARK: - PushValue -
public struct PushValue {
    var identifier: UUID = UUID()
    
    public var customKey:String? = "PushValue"
    
    public var primary:String? = nil
    public var secondary: String? = nil
    
    public typealias PushValueSelectionClosure = ( (PushValue,FormController,IndexPath) -> Void )
    public typealias PushValueActionClosure = ( (PushValue) -> Void )
    
    public var selectionClosure: PushValueSelectionClosure? = nil
    public var actionClosure: PushValueActionClosure? = nil
    public var model:Any? = nil
    public var params:[String:String]? = nil
    public var cellAccessoryType: UITableViewCell.AccessoryType = .disclosureIndicator
}


extension PushValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: PushValue, rhs: PushValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}



public extension PushValue {
    
    init(_ primary:String? = nil,_ secondary: String? = nil,_ model:Any? = nil,selectionClosure: @escaping PushValueSelectionClosure) {
        self.primary = primary
        self.secondary = secondary
        self.model = model
        self.selectionClosure = selectionClosure
    }
    
    init(_ primary:String? = nil,_ secondary: String? = nil,_ params:[String:String]? = nil,selectionClosure: @escaping PushValueSelectionClosure) {
        self.primary = primary
        self.secondary = secondary
        self.params = params
        self.selectionClosure = selectionClosure
    }
    
    
    init(_ primary:String, actionClosure: @escaping PushValueActionClosure) {
        self.primary = primary
        self.actionClosure = actionClosure
        self.cellAccessoryType = .none
    }
    
    
    init(_ primary:String,_ secondary: String? = nil,_ cellAccessoryType: UITableViewCell.AccessoryType,actionClosure: @escaping PushValueActionClosure) {
        self.primary = primary
        self.secondary = secondary
        self.actionClosure = actionClosure
        self.cellAccessoryType = cellAccessoryType
    }
    
    
    
    init(_ primary:String,_ model:Any,_ cellAccessoryType: UITableViewCell.AccessoryType ,actionClosure: @escaping PushValueActionClosure) {
        self.primary = primary
        self.model = model
        self.actionClosure = actionClosure
        self.cellAccessoryType = cellAccessoryType
    }
    
    
   
    
}


// MARK: - FormValue -
extension PushValue: FormValue {
    
    var idKey: String {
        return "\(identifier.uuidString.split(separator: "-")[1])"
       }
    
    public var formItem: FormItem {
        .push(self)
    }
    
    public func encodedValue() -> [String : String] {
        return params ?? [:]
    }
    
}



// MARK: - FormValueDisplayable -
extension PushValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = PushValueCell
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor("\(Cell.identifier)-\(idKey)", configureCell, didSelect)
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
        if let selectedFormItem = formController.dataSource.itemAt(path) {
            switch selectedFormItem {
            case .push(let pushValue):
                selectionClosure?(pushValue,formController,path)
                actionClosure?(pushValue)
            default:
                break
            }
        }
        
    }
    
}




// MARK: PushValueCell
final public class PushValueCell: UITableViewCell {
    static let identifier = "com.jmade.FormKit.PushValueCell.identifier"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    
    var formValue: PushValue? {
        didSet {
            
            primaryTextLabel.text = formValue?.primary
            secondaryTextLabel.text = formValue?.secondary
            
            if let push = formValue {
                accessoryType = push.cellAccessoryType
            }
            
            
            
        }
    }
    
    
    lazy var primaryTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    
    lazy var secondaryTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle:  .caption2).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
       
       override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)
           
           let defaultTableViewCellHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
           defaultTableViewCellHeightConstraint.priority = UILayoutPriority(501)
           
           NSLayoutConstraint.activate([
               defaultTableViewCellHeightConstraint,
               
               primaryTextLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
               primaryTextLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
               primaryTextLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
               
               secondaryTextLabel.topAnchor.constraint(equalTo: primaryTextLabel.bottomAnchor),
               secondaryTextLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
               secondaryTextLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
               
               contentView.bottomAnchor.constraint(equalTo: secondaryTextLabel.bottomAnchor, constant: 8.0),
              
               
           ])
        
           
       }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        primaryTextLabel.text = nil
        secondaryTextLabel.text = nil
    }
    
       
    public func configureCell(_ pushValue:PushValue) {
        formValue = pushValue
    }
    
}
