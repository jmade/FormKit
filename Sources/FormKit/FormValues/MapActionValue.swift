import UIKit
import MapKit


// MARK: - MapActionValue -
public struct MapActionValue: Codable {
    let identifier: UUID = UUID()
    
    public var customKey:String? = "MapActionValue"
    
    var primary:String? = nil
    var secondary: String? = nil
    var mapValue:MapValue? = nil
}


public extension MapActionValue {
    
    init()
    
}



public typealias MapActionUpdateClosure = (MapActionValue?) -> Void


// MARK: - FormValueDisplayable -
extension MapActionValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = MapActionValueCell
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor("\(Cell.identifier)_\(idKey)", configureCell, didSelect)
        /*
        switch selectionType {
        case .single:
            return FormCellDescriptor("\(Cell.identifier)_\(idKey)", configureCell, didSelect)
        case .multiple:
            return FormCellDescriptor("\(Cell.identifier)_\(idKey)", configureCell, didSelect)
        }
        */
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
        
        
        
        
        
        let changeClosure: ListSelectionChangeClosure = { [weak formController] (selectedValues) in
            if let formItem = formController?.dataSource.itemAt(path) {
                switch formItem {
                case .listSelection(let list):
                    let new = list.newWith(selectedValues)
                    formController?.dataSource.updateWith(formValue: new, at: path)
                    formController?.tableView.reloadRows(at: [path], with: .none)
                default:
                    break
                }
            }
        }
        
        let descriptor = self.makeDescriptor(changeClosure)
        let listSelectionController = ListSelectViewController(descriptor: descriptor)
        formController.navigationController?.pushViewController(listSelectionController, animated: true)
        
    }
    
}












// MARK: MapActionValueCell
final public class MapActionValueCell: UITableViewCell {
    static let identifier = "FormKit.MapActionValueCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = .label
        }
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        return label
    }()
    
    lazy var selectionLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
             label.textColor = .gray
        }
        label.textAlignment = .right
        return label
    }()
    
    var formValue : MapSearchValueCell? {
        didSet {
            if let listSelectValue = formValue {
//                titleLabel.text = listSelectValue.title
//                selectionLabel.text = listSelectValue.selectionTitle
                if let path = indexPath {
                    updateFormValueDelegate?.updatedFormValue(listSelectValue, path)
                }
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [titleLabel,selectionLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        activateDefaultHeightAnchorConstraint()
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            selectionLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            selectionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            selectionLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
            ])
        
        accessoryType = .disclosureIndicator
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        selectionLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 499), for: .horizontal)
    }
    
    
    override public func prepareForReuse() {
        titleLabel.text = nil
        selectionLabel.text = nil
        formValue = nil
        super.prepareForReuse()
    }
    
}
