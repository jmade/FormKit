
import UIKit
import MapKit

public extension MKPlacemark {
    
    var secondaryString: String {
        
        let firstSpace = (subThoroughfare != nil && thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (subThoroughfare != nil || thoroughfare != nil) && (subAdministrativeArea != nil || administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (subAdministrativeArea != nil && administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            subThoroughfare ?? "",
            firstSpace,
            // street name
            thoroughfare ?? "",
            comma,
            // city
            locality ?? "",
            secondSpace,
            // state
            administrativeArea ?? ""
        )
        
        return addressLine
    }
    
    var searchItem:SearchResultItem {
        get {
            return SearchResultItem(primary: name, secondary: secondaryString)
        }
    }
    
}




public struct SearchResultItem: Hashable {
    var primary:String? = nil
    var secondary:String? = nil
    let identifier: UUID = UUID()
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }

    public static func == (lhs: SearchResultItem, rhs: SearchResultItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}




//fileprivate enum Section {
//    case main
//}
//
//if #available(iOS 13.0, *) {
//    fileprivate typealias ItemsDataSource = UITableViewDiffableDataSource<Section, SearchResultItem>
//    fileprivate typealias ItemsSnapShot = NSDiffableDataSourceSnapshot<Section,SearchResultItem>
//} else {
//
//}


class LocationSearchTable : UITableViewController {
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var matchingItems:[MKMapItem] = [] {
        didSet {
            searchItems = matchingItems.map({ $0.placemark.searchItem })
        }
    }
    var mapView: MKMapView? = nil
    
    
    //private var dataSource: ItemsDataSource!
    
    var searchItems:[SearchResultItem] = [] {
        didSet {
            tableView.reloadData()
            //createSnapshot(from: searchItems)
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchResultItemCell.self, forCellReuseIdentifier: SearchResultItemCell.ReuseID)
        tableView.rowHeight = UITableView.automaticDimension
        
        /*
        configureDataSource()
        createSnapshot(from: self.searchItems)
        */
    }
    
    /*
    private func configureDataSource() {
        dataSource = ItemsDataSource(tableView: tableView, cellProvider: { (tableView, path, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultItemCell.ReuseID, for: path) as? SearchResultItemCell
            cell?.configureCell(item)
            return cell
            }
        )
        dataSource.defaultRowAnimation = .fade
    }
    */
}


/*
extension LocationSearchTable {
    
    private func createSnapshot(from items:[SearchResultItem]) {
        var snapshot = ItemsSnapShot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
}
*/


extension LocationSearchTable : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text
            else { return }
        
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
}



extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = matchingItems[indexPath.row]
        handleMapSearchDelegate?.dropPinZoomIn(placemark: item.placemark)
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultItemCell.ReuseID, for: indexPath) as? SearchResultItemCell {
            cell.configureCell(searchItems[indexPath.row])
            return cell
        }
        return .init()
    }

}






// MARK: - SearchResultItemCell -
final class SearchResultItemCell: UITableViewCell {
    
    static let ReuseID = "SearchResultItemCell"
    
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
        primaryTextLabel.text = nil
        secondaryTextLabel.text = nil
    }
    
       
    public func configureCell(_ item:SearchResultItem) {
        secondaryTextLabel.text = item.secondary
        primaryTextLabel.text = item.primary
    }
    
}
