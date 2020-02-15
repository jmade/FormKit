
import UIKit


// MARK: - ListSelectionDelegate -
protocol ListSelectionDelegate: class {
    func selectionUpdated(values: [String])
}

// MARK: - ListSelectionChangeClosure -
typealias ListSelectionChangeClosure = ( ([String]) -> Void )

let DefaultChangeClosure: ListSelectionChangeClosure = { (changes) in
    print("[ListSelectionChangeClosure] Selection Changed: \(changes)")
}


// MARK: - ListSelectionControllerDescriptor -
struct ListSelectionControllerDescriptor {
    let title: String
    let listVales: [String]
    let selectedIndicies: [Int]
    let tableViewStyle: UITableView.Style
    let selectionMessage: String
    let allowsMultipleSelection: Bool
    let selectionChangeClosure:ListSelectionChangeClosure
    
    init(title:String, values:[String], selected:[Int], allowsMultipleSelection:Bool, message:String, changeClosure: @escaping ListSelectionChangeClosure ) {
        self.title = title
        self.listVales = values
        self.selectedIndicies = selected
        self.selectionChangeClosure = changeClosure
        self.allowsMultipleSelection = allowsMultipleSelection
        if #available(iOS 13.0, *) {
            self.tableViewStyle = .insetGrouped
        } else {
            self.tableViewStyle = .grouped
        }
        self.selectionMessage = message
    }
}


extension ListSelectionControllerDescriptor {
    
    static func Demo() -> ListSelectionControllerDescriptor {
        
        let values = stride(from: 0, to: 32, by: 1).map({ "Item \($0)" })
        let selected = [1]
        let title = "Demo List"
        let closure:ListSelectionChangeClosure = { (changes) in
            print("[ListSelectionChangeClosure] Single Selection Changed: \(changes)")
        }
        
        return
            ListSelectionControllerDescriptor(
                title: title,
                values: values,
                selected: selected,
                allowsMultipleSelection: false,
                message: "Select an Item",
                changeClosure: closure
        )
    }
    
}






//: MARK: - ListSelectViewController -
final class ListSelectViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    static let ReuseID = "FormKit.ListSelectionCell"
    
    /// Closure
    public var listSelectionChangeClosure: ListSelectionChangeClosure = { _ in }
    /// Delegation
    weak var delegate:ListSelectionDelegate?
    
    // MARK: - DataSource -
    private struct SelectionRow: Equatable {
        let title: String
        let selected: Bool
    }
    
    private var completeDataSource:[SelectionRow] = []
    
    private var dataSource: [SelectionRow] = [] {
        didSet {
            tableView.tableFooterView = nil
            tableView.reloadData()
        }
    }
    
    public var allowDismissal:Bool = true {
        didSet {
            if allowDismissal == false {
                if #available(iOS 13.0, *) {
                    isModalInPresentation = true
                }
            }
        }
    }
    
    private var sectionTile: String = ""
    
    /// setting the data from outside
    private var unformatedData: ([String],[Int]) = ([],[]) {
        didSet {
            formatData(unformatedData.0, unformatedData.1)
        }
    }
    
    
    public var allowsMultipleSelection: Bool = true {
        didSet {
            if allowsMultipleSelection {
                tableView.allowsMultipleSelection = true
            } else {
                tableView.allowsMultipleSelection = false
            }
        }
    }
    
    
    // MARK: - Searching -
    private var searchEnabled = true
    public lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = true
        controller.searchBar.tintColor = UIColor.white
        
        if #available(iOS 13.0, *) {
            controller.searchBar.searchTextField.backgroundColor = .systemBackground
        } else {
            if let searchBarTextField = controller.searchBar.textField {
                searchBarTextField.textColor = .white
            }
        }
        
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.delegate = self
        return controller
    }()

    
    // MARK: - Init -
    required init?(coder aDecoder: NSCoder) {fatalError()}

    init(data: [String],selected: [Int], title:String) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
             super.init(style: .plain)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
        formatData(data,selected)
        self.title = title
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor : UIColor.white ]
        
    }
    
    
    init(descriptor:ListSelectionControllerDescriptor) {
        super.init(style: descriptor.tableViewStyle)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
        formatData(descriptor.listVales,descriptor.selectedIndicies)
        self.listSelectionChangeClosure = descriptor.selectionChangeClosure
        self.title = descriptor.title
        self.allowsMultipleSelection = descriptor.allowsMultipleSelection
        self.sectionTile = descriptor.selectionMessage
        
        // navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
    }
    
    
    // MARK: - Loading -
    
    
    typealias ListSelectLoadingClosure = (ListSelectViewController) -> Void
    
    init(title:String,loadingClosure: @escaping ListSelectLoadingClosure, updateClosure: @escaping ListSelectionChangeClosure) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .plain)
        }
        self.title = title
        self.listSelectionChangeClosure = updateClosure
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        loadingClosure(self)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if searchEnabled {
            searchController.searchResultsUpdater = self
            searchController.searchBar.delegate = self
            searchController.searchBar.autocapitalizationType = .none
            
            if #available(iOS 11.0, *) {
                /// For iOS 11 and later, place the search bar in the navigation bar.
                navigationItem.searchController = searchController
                navigationItem.hidesSearchBarWhenScrolling = false
            } else {
                /// For iOS 10 and earlier, place the search controller's search bar in the table view's header.
                tableView.tableHeaderView = searchController.searchBar
            }
            
            definesPresentationContext = true
        }
        
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor : UIColor.white ]
    }
    
    
    @objc func donePressed() {
        if allowDismissal {
            dismiss(animated: true, completion: nil)
        } else {
            showDoNotDismiss()
        }
    }
    
    
    private func showDoNotDismiss() {
        let alert = UIAlertController(title: self.title ?? "",
                                      message: "Make a selection to continue.",
                                      preferredStyle: .alert
                   )
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
        present(alert, animated: true, completion: nil)
    }
    
    
    
    public func setUnformatedData(_ unformated: ([String],[Int])) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.unformatedData = unformated
        })
    }
    
    private func formatData(_ data:[String],_ selected:[Int]) {
        var newDataSource: [SelectionRow] = []
        for (i,entry) in data.enumerated() {
            if selected.contains(i) {
                newDataSource.append(SelectionRow(title: entry, selected: true))
            } else {
                newDataSource.append(SelectionRow(title: entry, selected: false))
            }
        }
        completeDataSource = newDataSource
        dataSource = newDataSource
    }
    
    
    
    //: MARK: - UISearchBarDelegate -
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    //: MARK: - UISearchResultsUpdating -
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            /// use a fresh copy of all entires
            let currentDataSource = completeDataSource
            let titles = currentDataSource.map({ $0.title })
            let filteredTitles = titles.filter { (title) -> Bool in
                let foundRange = title.range(of: searchText,
                                             options: .caseInsensitive,
                                             range: nil,
                                             locale: nil
                )
                return foundRange != nil
            }
            
            let searchedData = searchText.isEmpty ? titles : filteredTitles
            
            dataSource = currentDataSource.filter { searchedData.contains($0.title) }
        }
    }

    // MARK: - TableView functions -
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTile
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateMasterStorage(title: dataSource[indexPath.row].title, selected: false)
        let oldRow = dataSource[indexPath.row]
        dataSource[indexPath.row] = SelectionRow(title: oldRow.title, selected: false)
        tableView.reloadRows(at: [indexPath], with: .none)
        updateSeletion()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateMasterStorage(title: dataSource[indexPath.row].title, selected: true)
        if allowsMultipleSelection == false {
            // find the current selected item,
            if let selectedRow = dataSource.filter({ $0.selected == true }).first {
                if let selectedRowIndex = dataSource.firstIndex(of: selectedRow) {
                    /// Assign the New `unselected`
                    dataSource[selectedRowIndex] = SelectionRow(title: selectedRow.title, selected: false)
                    /// Update the current row to be `selected`
                    let oldRow = dataSource[indexPath.row]
                    dataSource[indexPath.row] = SelectionRow(title: oldRow.title, selected: true)
                    /// Reload the table Rows
                    tableView.reloadRows(at: [IndexPath(row: selectedRowIndex, section: 0),indexPath], with: .none)
                }
            } else {
                /// Update the current row to be `selected`
                let oldRow = dataSource[indexPath.row]
                dataSource[indexPath.row] = SelectionRow(title: oldRow.title, selected: true)
                /// Reload the table Rows
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            /// dissmiss the search Controller here...
            self.searchController.dismiss(animated: true, completion: nil)
            updateSeletion()
            dismiss(animated: true, completion: nil)
        } else {
            // Multi
            let oldRow = dataSource[indexPath.row]
            dataSource[indexPath.row] = SelectionRow(title: oldRow.title, selected: !oldRow.selected)
            /// Reload the table Rows
            tableView.reloadRows(at: [indexPath], with: .none)
            updateSeletion()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListSelectViewController.ReuseID, for: indexPath)
        let row = dataSource[indexPath.row]
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.textLabel?.text = row.title
        cell.accessoryType = row.selected ? .checkmark : .none
        return cell
    }
    
    /// Keep Master Data Source Current with Selection
    private func updateMasterStorage(title:String,selected:Bool) {
          for (index,selectionRow) in completeDataSource.enumerated() {
              if selectionRow.title == title {
                  completeDataSource[index] = SelectionRow(title: completeDataSource[index].title,
                                                           selected: selected
                  )
              }
          }
      }
    
 
    private func updateSeletion() {
        let selectedValues = dataSource.filter({ $0.selected }).map({ $0.title })
        delegate?.selectionUpdated(values: selectedValues)
        listSelectionChangeClosure(selectedValues)
    }
}

