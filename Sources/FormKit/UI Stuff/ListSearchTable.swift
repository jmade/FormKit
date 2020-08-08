
import UIKit


public typealias SearchedItemSelectionClosure = (SearchResultItem,ListSearchTable,IndexPath) -> Void




public class ListSearchTable : UITableViewController {
    
    
    public var itemSelectedClosure: SearchedItemSelectionClosure? = nil
    
    var searchItems:[SearchResultItem] = []
    
    var dataSource:[SearchResultItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    

    public override init(style: UITableView.Style) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }
    
    
    public init(_ searchItems:[SearchResultItem] = []) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
        self.searchItems = searchItems
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ListSearchResultCell.self, forCellReuseIdentifier: ListSearchResultCell.ReuseID)
        tableView.rowHeight = UITableView.automaticDimension
    }
}


extension ListSearchTable : UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text,searchBarText.isEmpty == false else { return }
        dataSource = searchItems.filter({ ($0.primary ?? String()).contains(searchBarText) })
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
}



public extension ListSearchTable {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        for item in searchItems {
            if item.identifier == dataSource[indexPath.row].identifier {
                itemSelectedClosure?(item,self,indexPath)
            }
        }
       
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return searchItems.isEmpty ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ListSearchResultCell.ReuseID, for: indexPath) as? ListSearchResultCell {
            cell.configureCell(searchItems[indexPath.row])
            return cell
        }
        return .init()
        
    }

}







// MARK: - ListSearchResultCell -
final class ListSearchResultCell: UITableViewCell {
    
    static let ReuseID = "FormKit.ListSearchResultCell"
    
    private lazy var primaryTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    
    private lazy var secondaryTextLabel: UILabel = {
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
          
            activateDefaultHeightAnchorConstraint()
        
           NSLayoutConstraint.activate([
            
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
