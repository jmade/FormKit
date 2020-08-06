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


extension MapActionValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: MapActionValue, rhs: MapActionValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}






// MARK: - FormValue -
extension MapActionValue: FormValue {
    
    public var formItem: FormItem {
        .mapAction(self)
    }
    
}


extension MapActionValue {
    
    func newWith(_ primary: String?, secondary: String?, mapValue: MapValue?) -> MapActionValue {
        return .init(customKey: self.customKey,
                     primary: (primary == nil) ? self.primary : primary,
                     secondary: (secondary == nil) ? self.secondary : secondary,
                     mapValue: (mapValue == nil) ? self.mapValue : mapValue
        )
    }
    
}



public typealias MapActionUpdateClosure = (MapActionValue) -> Void


// MARK: - FormValueDisplayable -
extension MapActionValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = MapActionValueCell
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor("\(Cell.identifier)", configureCell, didSelect)
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
        let updateClosure: MapActionUpdateClosure = { [weak formController] (mapActionValue) in
            
            let mapValuePath = IndexPath(row: (path.row-1), section: path.row)
            if let mapValue = mapActionValue.mapValue {
                formController?.dataSource.updateWith(formValue: mapValue, at: mapValuePath)
            }
            
            formController?.dataSource.updateWith(formValue: mapActionValue, at: path)
            formController?.tableView.reloadRows(at: [mapValuePath,path], with: .none)

        }
        
        let mapVC = MapViewController(mapValue: self.mapValue)
        mapVC.mapActionUpdateClosure = updateClosure
        formController.navigationController?.pushViewController(mapVC, animated: true)
        
    }
    
}












// MARK: MapActionValueCell
final public class MapActionValueCell: UITableViewCell {
    static let identifier = "FormKit.MapActionValueCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    
    var formValue: MapActionValue? {
        didSet {
            primaryTextLabel.text = formValue?.primary
            secondaryTextLabel.text = formValue?.secondary
            
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
        
        
        accessoryType = .disclosureIndicator
           
       }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        primaryTextLabel.text = nil
        secondaryTextLabel.text = nil
    }
    
       
    public func configureCell(_ mapActionValue:MapActionValue) {
        formValue = mapActionValue
    }
    
}
