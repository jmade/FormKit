
import UIKit


// MARK: - ListSelectionDelegate -
public protocol ListSelectionDelegate: class {
    func selectionUpdated(values: [String])
    
}

// MARK: - ListSelectionChangeClosure -
public typealias ListSelectionChangeClosure = ( ([String]) -> Void )

let DefaultChangeClosure: ListSelectionChangeClosure = { (changes) in
    print("[ListSelectionChangeClosure] Selection Changed: \(changes)")
}







// MARK: - ListSelectionControllerDescriptor -
public struct ListSelectionControllerDescriptor {
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



public protocol Selectable {
    var selected: Bool { get }
}

public protocol Displayable {
    var title: String { get }
}

public typealias ListSelectable = Displayable & Selectable








public protocol ListSelectRepresentable {
    var item:ListSelectViewController.ListItem {get set}
}



//: MARK: - ListSelectViewController -
public final class ListSelectViewController: UITableViewController {
    
    public struct ListItem {
        public var title:String
        public var selected:Bool = false
        public var identifier:String? = nil
        
        public init(_ title:String,_ selected:Bool = false) {
            self.title = title
            self.selected = selected
        }
        
        public init(_ title:String,_ identifier:String?,_ selected:Bool = false) {
            self.title = title
            self.selected = selected
            self.identifier = identifier
        }
    }
    
    
    
    
    
    
    
    static let ReuseID = "FormKit.ListSelectionCell"
    
    /// Closure
    var listSelectionChangeClosure: ListSelectionChangeClosure = { _ in }
    
    
    
    /// Delegation
    weak var delegate:ListSelectionDelegate?
    
    
    public var formValue:ListSelectionValue? = nil
    private var formIndexPath: IndexPath? = nil
    
    weak var formDelegate:UpdateFormValueDelegate?
    
    
    // MARK: - DataSource -
    private struct SelectionRow: ListSelectable, Equatable {
        
        var title: String
        
        var selected: Bool
        var valueIdentifier:String? = nil
        
        let identifier: UUID = UUID()
        
        public func hash(into hasher: inout Hasher) {
            return hasher.combine(identifier)
        }
        
        public static func == (lhs: SelectionRow, rhs: SelectionRow) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    
    private var completeDataSource:[SelectionRow] = []
    
    private var dataSource: [SelectionRow] = [] {
        didSet {
            
            
            guard tableView.window != nil else {
                print("got no window...")
                return
            }
            
            
            tableView.tableFooterView = nil
            guard tableView.numberOfSections == 0 else {
                tableView.reloadData()
                //tableView.reloadSections(IndexSet(integersIn: 0...0), with: .top)
                listSearchTable?.searchItems = dataSource.map({ SearchResultItem(primary: $0.title, secondary: nil, selected: $0.selected) })
                return
            }
            
            if dataSource.isEmpty {
                print("Empty Data")
            } else {
                print("Inserting Section 1: Datasource Count: \(dataSource.count)")
                
                UIViewPropertyAnimator(duration: 0.3, curve: .easeIn) {
                    self.tableView.insertSections(IndexSet(integersIn: 0...0), with: .top)
                }.startAnimation()
                
                
                listSearchTable?.searchItems = dataSource.map({
                    SearchResultItem(primary: $0.title, secondary: nil, selected: $0.selected)
                })
            }
            
            
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
    
    
    
    
    public var jsonPayload: [String:Any]? = nil
    
    
    // sectionTitles = []
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
    
    
    private var listSearchTable:ListSearchTable? = nil
    private var resultSearchController:UISearchController? = nil
    
    
    // MARK: - Init -
    required init?(coder aDecoder: NSCoder) {fatalError()}

   public  init(data: [String],selected: [Int], title:String) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
             super.init(style: .plain)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
        unformatedData = (data,selected)
        formatData(data,selected)
        self.title = title
    
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor : UIColor.white ]
        
    }
    
    
    public init(descriptor:ListSelectionControllerDescriptor) {
        super.init(style: descriptor.tableViewStyle)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
        unformatedData = (descriptor.listVales,descriptor.selectedIndicies)
        formatData(descriptor.listVales,descriptor.selectedIndicies)
        self.listSelectionChangeClosure = descriptor.selectionChangeClosure
        self.title = descriptor.title
        self.allowsMultipleSelection = descriptor.allowsMultipleSelection
        self.sectionTile = descriptor.selectionMessage
    }
    
    
    
    public init(descriptor:ListSelectionControllerDescriptor,loadingClosure: @escaping  ListSelectLoadingClosure) {
        super.init(style: descriptor.tableViewStyle)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
        unformatedData = (descriptor.listVales,descriptor.selectedIndicies)
        formatData(descriptor.listVales,descriptor.selectedIndicies)
        self.listSelectionChangeClosure = descriptor.selectionChangeClosure
        self.title = descriptor.title
        self.allowsMultipleSelection = descriptor.allowsMultipleSelection
        self.sectionTile = descriptor.selectionMessage
        loadingClosure(self)
    }
    
    
    public init(_ listSelectValue:ListSelectionValue,at path:IndexPath) {
        super.init(style: listSelectValue.makeDescriptor().tableViewStyle)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
        self.title = listSelectValue.title
        self.allowsMultipleSelection = listSelectValue.selectionType == .multiple
        self.sectionTile = listSelectValue.selectionTitle
        
        self.formIndexPath = path
        self.formValue = listSelectValue
        
        
       
        
        
        
        
        if let loading = listSelectValue.loading {
            if let loadingClosure = loading.loadingClosure {
                print("Calling Loading.Loading Closure")
                loadingClosure(self)
            }
        } else {
//            unformatedData = (listSelectValue.values,listSelectValue.selectedIndicies)
//            formatData(listSelectValue.values,listSelectValue.selectedIndicies)
//            if let loadingClosure = listSelectValue.loadingClosure {
//                loadingClosure(self)
//            }
        }
    }
    
    
    public func setValue(_ listSelectValue:ListSelectionValue) {
        self.formValue = listSelectValue
//        unformatedData = (listSelectValue.values,listSelectValue.selectedIndicies)
//        formatData(listSelectValue.values,listSelectValue.selectedIndicies)
//        crawlDelegate(listSelectValue)
    }
    
    
    // MARK: - Loading -
    
    
    public typealias ListSelectLoadingClosure = (ListSelectViewController) -> Void
    
   public init(title:String,loadingClosure: @escaping ListSelectLoadingClosure, updateClosure: @escaping ListSelectionChangeClosure) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .plain)
        }
        self.title = title
        self.listSelectionChangeClosure = updateClosure
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        loadingClosure(self)
    }
    
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let listSelectValue = formValue {
            dataSource = listSelectValue.listItems.map({ SelectionRow(title: $0.title, selected: $0.selected, valueIdentifier: $0.identifier) })
        }
        
        addBackbutton(title: " ")
        
        listSearchTable = ListSearchTable()
        
        listSearchTable?.itemSelectedClosure = { [weak self] (item,ctrl,path) in
            ctrl.dismiss(animated: true, completion: nil)
            self?.handleSearchedSelection(item: item,at: path)
        }
        
        
        listSearchTable?.searchItems = dataSource.map({ SearchResultItem(primary: $0.title, secondary: nil, selected: $0.selected) })
        resultSearchController = UISearchController(searchResultsController: listSearchTable)
        resultSearchController?.searchResultsUpdater = listSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Items"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        
        /*
        
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
        
         */
        
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor : UIColor.white ]
    }
    
    
    @objc func donePressed() {
        if allowDismissal {
            dismiss(animated: true, completion: nil)
        } else {
            showDoNotDismiss()
        }
    }
    
    
   
    
    
    public func setLoading() {
        prepareTableForLoading()
    }
    
    private func prepareTableForLoading() {
           dataSource = []
           sectionTile = ""
           tableView.deleteSections(IndexSet(integersIn: 0..<tableView.numberOfSections), with: .top)
           tableView.tableFooterView = ItemsLoadingView()
       }
    
    
    public func reloadExistingData() {
        let existingData = self.unformatedData
        setUnformatedData(existingData)
    }
    

    public func setUnformatedData(_ unformated: ([String],[Int])) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.unformatedData = unformated
        })
    }
      

    
    
    private func showDoNotDismiss() {
        let alert = UIAlertController(title: self.title ?? "",
                                      message: "Make a selection to continue.",
                                      preferredStyle: .alert
                   )
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
        present(alert, animated: true, completion: nil)
    }
    
    
  
    
    
    
    private func formatData(_ data:[String],_ selected:[Int]) {
        var newDataSource: [SelectionRow] = []
        for (i,entry) in data.enumerated() {
            if selected.contains(i) {
                newDataSource.append(SelectionRow(title: entry, selected: true ))
            } else {
                newDataSource.append(SelectionRow(title: entry, selected: false))
            }
        }
        completeDataSource = newDataSource
        dataSource = newDataSource
    }
    
    
    /*
    //: MARK: - UISearchBarDelegate -
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    //: MARK: - UISearchResultsUpdating -
    public func updateSearchResults(for searchController: UISearchController) {
        
        
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
    */
    
    
    
    
    

    // MARK: - TableView functions -
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.isEmpty ? 0 : 1
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(getSelectedIndicies(removingIndex: nil).count) Selected"
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newDidSelect(indexPath)
    }
    

    
    private func crawlDelegate(_ new:ListSelectionValue) {
        print(" new -> \(new) ")
        
       print("matching string vals: \( new.loading!.matchingStringValues!)")
        
        
        if let nav = navigationController {
            for vc in nav.viewControllers {
                if let form = vc as? FormController {
                    if let path = formIndexPath {
                        form.dataSource.updateWith(formValue: new, at: path)
                        form.tableView.reloadRows(at: [path], with: .none)
                    }
                }
            }
        }
    }
    
    
    private func newDidSelect(_ indexPath: IndexPath) {
        
//        let newIndicies = newSelectedIndicies(indexPath)
//        print(" newIndicies -> \(newIndicies) ")
//
//        let newListValue = makeNewListSelectValue(newIndicies)
//
//        print("NEw List value \(newListValue.selectedIndicies)")
//
//        crawlDelegate(newListValue)
        
        if allowsMultipleSelection {
            dataSource[indexPath.row].selected.toggle()
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
        } else {
            let selectedRow = dataSource[indexPath.row]
            if selectedRow.selected {
                dataSource[indexPath.row].selected = false
                //formatData(newListValue.values, [])
                tableView.reloadSections(IndexSet(integer: 0), with: .none)
            } else {
                dataSource = makeNewDataSourceSingleSelectionAt(indexPath.row)
                tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            
        }
    
        print("About to set the Delegate")
        let listItems = dataSource.map({ ListItem($0.title, $0.valueIdentifier, $0.selected) })
        
        if let currentListSelectValue = formValue {
            print("got a form value ")
            let newListSelectValue = currentListSelectValue.newWith(listItems)
            crawlDelegate(newListSelectValue)
        } else {
            print("Error no formvalue ")
        }
        
        
    }
    
    
    
    private func makeNewDataSourceSingleSelectionAt(_ selectedIndex:Int?) -> [SelectionRow] {
        
        var newData: [SelectionRow] = []
        
        if let newSelected = selectedIndex {
            for (row,value) in dataSource.enumerated() {
                newData.append(
                    SelectionRow(title: value.title,
                                 selected: (newSelected == row),
                                 valueIdentifier: value.valueIdentifier
                    )
                )
            }
        } else {
            newData = dataSource.map({
                SelectionRow(title: $0.title, selected: false, valueIdentifier: $0.valueIdentifier)
                
            })
        }
        
        return newData
    }
    
     
    private func newSelectedIndicies(_ indexPath: IndexPath) -> [Int] {
        if allowsMultipleSelection {
            let selectedRow = dataSource[indexPath.row]
            if selectedRow.selected {
                return getSelectedIndicies(removingIndex: indexPath.row)
            } else {
                var currentIndicies = getSelectedIndicies(removingIndex: nil)
                currentIndicies.append(indexPath.row)
                return currentIndicies
            }
        } else {
            let selectedRow = dataSource[indexPath.row]
            if selectedRow.selected {
                return []
            } else {
                return [indexPath.row]
            }
        }
    }
    
    
    
    private func makeNewListSelectValue(_ selectedIndicies:[Int]) -> ListSelectionValue {
        
        guard let currentValue = formValue else {
            print("ERROR could not get the listSelectValue")
            return .init(title: title ?? "",
                         values: dataSource.map({ $0.title }),
                         selected: selectedIndicies
            )
        }
        
        var new = currentValue
        new.values = dataSource.map({ $0.title })
        new.selectedIndicies = selectedIndicies
        return new
    }
    
    /*
    private func handleDidSelectRowAt(_ path:IndexPath) {
        let indexPath = path
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
    */
    
    
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = dataSource[indexPath.row].selected ? .checkmark : .none
    }
    
    
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListSelectViewController.ReuseID, for: indexPath)
        let row = dataSource[indexPath.row]
        
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.textLabel?.text = row.title
        cell.accessoryType = row.selected ? .checkmark : .none
        return cell
    }
    
    
    
    
    
    /*
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
    */
    
    
    private func getSelectedIndicies(removingIndex:Int?) -> [Int] {
        var selectedPaths: [Int] = []
        
        for (row,value) in dataSource.enumerated() {
            if value.selected {
                if let indexToSkip = removingIndex {
                    if row != indexToSkip {
                        selectedPaths.append(
                            row
                        )
                    }
                } else {
                    selectedPaths.append(
                        row
                    )
                }
            }
        }
        
        
        return selectedPaths
    }
    
    
    private func handleSearchedSelection(item:SearchResultItem, at path:IndexPath) {
        if let title = item.primary {
            for (index,value) in dataSource.enumerated() {
                if value.title == title {
                    let foundPath = IndexPath(row: index, section: path.section)
                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let self = self else { return }
                        self.newDidSelect(foundPath)
                    })
                }
            }
        }
    }
 
    /// When a selection is made, we need to make a new `ListSelectValue`
    
    private func updateSeletion() {
        let selectedValues = dataSource.filter({ $0.selected }).map({ $0.title })
        delegate?.selectionUpdated(values: selectedValues)
        listSelectionChangeClosure(selectedValues)
    }
}

