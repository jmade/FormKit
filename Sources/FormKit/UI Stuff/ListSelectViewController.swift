
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
    
    // MARK: - ListItem -
    public struct ListItem {
        public var title:String
        public var selected:Bool = false
        public var detail:String? = nil
        public var identifier:String? = nil
        
        public var underlyingObject:Any? = nil
        
        public typealias ValueExtractionClosure = (Any?) -> Any?
        public var valueExtractionClosure: ValueExtractionClosure? = { _ in return nil }
        
        
        public var extractedValue:Any? {
            get {
                if let underlying = underlyingObject {
                    if let closure = valueExtractionClosure {
                        return closure(underlying)
                    }
                }

                return identifier
            }
        }
        
        
        public var valueIdentifier: String? {
            get {
                return identifier
            }
        }
        
        
        public init(_ title:String,_ selected:Bool = false) {
            self.title = title
            self.selected = selected
        }
        
        public init(title:String, selected:Bool = false) {
            self.title = title
            self.selected = selected
        }
        
        public init(title:String, detail:String?,_ selected:Bool = false) {
            self.title = title
            self.selected = selected
            self.detail = detail
        }
        
        public init(_ title:String,_ identifier:String?,_ selected:Bool = false) {
            self.title = title
            self.selected = selected
            self.identifier = identifier
        }
        
        public init(title:String, selected:Bool, valueIdentifier:String?) {
            self.title = title
            self.selected = selected
            self.identifier = valueIdentifier
        }

        
        public init(title:String,detail:String?,selected:Bool, underlyingObject:Any?, valueExtractionClosure: ValueExtractionClosure?) {
            self.title = title
            self.detail = detail
            self.selected = selected
            self.underlyingObject = underlyingObject
            self.valueExtractionClosure = valueExtractionClosure
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
    public typealias SelectionRow = ListItem
    /*
    public struct SelectionRow: ListSelectable, Equatable {
        
        public var title: String
        public var detail:String? = nil
        
        public var selected: Bool
        var valueIdentifier:String? = nil
        
        let uuid: UUID = UUID()
        
        public func hash(into hasher: inout Hasher) {
            return hasher.combine(uuid)
        }
        
        public static func == (lhs: SelectionRow, rhs: SelectionRow) -> Bool {
            return lhs.uuid == rhs.uuid
        }
    }
    */
    
    
    private var completeDataSource:[SelectionRow] = []
    
    private var dataSource: [SelectionRow] = [] {
        didSet {
            
            guard tableView.window != nil, !dataSource.isEmpty else {
                return
            }
            
            tableView.tableFooterView = nil
            guard tableView.numberOfSections == 0 else {
                tableView.reloadData()
                listSearchTable?.searchItems = dataSource.map({
                    SearchResultItem(primary: $0.title, secondary: nil, selected: $0.selected)
                })
                return
            }
            
            print("Inserting Section 1: Datasource Count: \(dataSource.count)")
            tableView.insertSections(IndexSet(integersIn: 0...0), with: .top)
            
            listSearchTable?.searchItems = dataSource.map({
                SearchResultItem(primary: $0.title, secondary: nil, selected: $0.selected)
            })
            
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
    
    
    
    private var selectedIndexPaths:[IndexPath] = []
    
    private var lastSelectedIndexPath:IndexPath? {
        get {
           return selectedIndexPaths.first
        }
    }
    
    
    
    // MARK: - Searching -
    private var searchEnabled = true
    
    
    private var listSearchTable:ListSearchTable? = nil
    private var resultSearchController:UISearchController? = nil
    
    
    // MARK: - Init -
    required init?(coder aDecoder: NSCoder) {fatalError()}

    /*
    public init(data: [String],selected: [Int], title:String) {
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
    */
    
//    public init(descriptor:ListSelectionControllerDescriptor) {
//        super.init(style: descriptor.tableViewStyle)
//        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.ReuseID)
//        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
//        unformatedData = (descriptor.listVales,descriptor.selectedIndicies)
//        formatData(descriptor.listVales,descriptor.selectedIndicies)
//        self.listSelectionChangeClosure = descriptor.selectionChangeClosure
//        self.title = descriptor.title
//        self.allowsMultipleSelection = descriptor.allowsMultipleSelection
//        self.sectionTile = descriptor.selectionMessage
//    }
    
    
    
//    public init(descriptor:ListSelectionControllerDescriptor,loadingClosure: @escaping  ListSelectLoadingClosure) {
//        super.init(style: descriptor.tableViewStyle)
//        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.ReuseID)
//        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListSelectViewController.ReuseID)
//        unformatedData = (descriptor.listVales,descriptor.selectedIndicies)
//        formatData(descriptor.listVales,descriptor.selectedIndicies)
//        self.listSelectionChangeClosure = descriptor.selectionChangeClosure
//        self.title = descriptor.title
//        self.allowsMultipleSelection = descriptor.allowsMultipleSelection
//        self.sectionTile = descriptor.selectionMessage
//        loadingClosure(self)
//    }
    
    
    /// Using
    public init(_ listSelectValue:ListSelectionValue,at path:IndexPath) {
        print("LSCinit")
        super.init(style: listSelectValue.makeDescriptor().tableViewStyle)
        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.ReuseID)
        self.title = listSelectValue.title
        self.allowsMultipleSelection = listSelectValue.selectionType == .multiple
        self.sectionTile = listSelectValue.selectionTitle
        
        self.formIndexPath = path
        self.formValue = listSelectValue
        
        
       
        
        if let loading = listSelectValue.loading {
            if let loadingClosure = loading.loadingClosure {
                loadingClosure(self)
            }
        } else {
            print("No Loading")
            print(" listSelectValue.listItems  -> \(listSelectValue.listItems ) ")
            dataSource = listSelectValue.listItems //  listSelectValue.selectionRows
        }
        
        
        
    }
    
    
    public func setValue(_ listSelectValue:ListSelectionValue) {
        self.formValue = listSelectValue
        dataSource = listSelectValue.listItems
    }
    
    
    // MARK: - Loading -
    
    
    public typealias ListSelectLoadingClosure = (ListSelectViewController) -> Void
    
//   public init(title:String,loadingClosure: @escaping ListSelectLoadingClosure, updateClosure: @escaping ListSelectionChangeClosure) {
//        if #available(iOS 13.0, *) {
//            super.init(style: .insetGrouped)
//        } else {
//            super.init(style: .plain)
//        }
//        self.title = title
//        self.listSelectionChangeClosure = updateClosure
//        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.ReuseID)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
//        loadingClosure(self)
//    }
//
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let listSelectValue = formValue {
            print("[LSC] viewDidLoad Setting dataSource: \(listSelectValue.selectionRows.count) ")
            dataSource = listSelectValue.listItems
            
            print(" listSelectValue -> \(listSelectValue) ")
        }
        
        
        print("viewDidLoad")
        print(" dataSource -> \(dataSource) ")
        addBackbutton(title: " ")
        
        listSearchTable = ListSearchTable()
        
        listSearchTable?.itemSelectedClosure = { [weak self] (item,ctrl,path) in
            ctrl.dismiss(animated: true, completion: nil)
            self?.handleSearchedSelection(item: item,at: path)
        }
        
        
        listSearchTable?.searchItems = dataSource.map({ SearchResultItem(primary: $0.title, secondary: $0.detail, selected: $0.selected) })
        resultSearchController = UISearchController(searchResultsController: listSearchTable)
        resultSearchController?.searchResultsUpdater = listSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Items"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        //tableView.reloadSections(IndexSet(integer: 0), with: .none)
        
        //navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor : UIColor.white ]
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
        
        if allowsMultipleSelection {
            dataSource[indexPath.row].selected.toggle()
            
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = dataSource[indexPath.row].selected ? .checkmark : .none
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            /// Single Selection Mode
            let selectedCount = dataSource.filter({ $0.selected }).count
            print(" selectedCount -> \(selectedCount) ")
            
            if let currentSelectedPath = selectedIndexPaths.first {
                /// Has A Selected Row
                if currentSelectedPath == indexPath {
                    // Turning Selected Row Off
                    dataSource[currentSelectedPath.row].selected = false
                    selectedIndexPaths = []
                    
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .none
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                    
                    //tableView.reloadRows(at: [currentSelectedPath], with: .fade)
                } else {
                    // Changing to new Selection
                    // Turn current Row off...
                    dataSource[currentSelectedPath.row].selected = false
                    // Turn New Row On
                    dataSource[indexPath.row].selected = true
                    selectedIndexPaths = [indexPath]
                    // Reload Rows
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .checkmark
                        tableView.deselectRow(at: indexPath, animated: true)
                    }

                    tableView.reloadRows(at: [currentSelectedPath], with: .none)
                }
            } else {
                // No Selected Row
                dataSource[indexPath.row].selected = true
                selectedIndexPaths = [indexPath]
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                    tableView.deselectRow(at: indexPath, animated: true)
                }
                //tableView.reloadRows(at: [indexPath], with: .fade)
            }
            
        }
    
        
        
        if let currentListSelectValue = formValue {
            //let listItems = dataSource.map({ ListItem($0.title, $0.valueIdentifier, $0.selected) })
            let newListSelectValue = currentListSelectValue.newWith(dataSource)
            crawlDelegate(newListSelectValue)
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
            return .init(title: title ?? "",
                         values: dataSource.map({ $0.title }),
                         selected: selectedIndicies
            )
        }
        
        var new = currentValue
        new.values = dataSource.map({ $0.title })
        new.selectedIndicies = selectedIndicies
        new.listItems = dataSource
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
    
    
    
//    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.accessoryType = dataSource[indexPath.row].selected ? .checkmark : .none
//    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.ReuseID, for: indexPath) as? ListItemCell {
             let row = dataSource[indexPath.row]
            cell.configureCell(row)
            return cell
        }
        return .init()
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




// MARK: - ListItemCell -
final class ListItemCell: UITableViewCell {
    
    static let ReuseID = "FormKit.ListItemCell"
    
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
        accessoryType = .none
    }
    
    
    public func configureCell(_ item:ListItem) {
        secondaryTextLabel.text = item.detail
        primaryTextLabel.text = item.title
        accessoryType = item.selected ? .checkmark  : .none
        
    }
    
}


