
import UIKit


// MARK: - ListSelectionDelegate -
public protocol ListSelectionDelegate: AnyObject {
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

public protocol ListItemProvidable {
    var listItem:ListItem { get }
}




//: MARK: - ListSelectViewController -
public final class ListSelectViewController: UITableViewController {
    
    
    // MARK: - ListItem -
    public struct ListItem: PropertySearchable, Hashable, Equatable, DiffAware {
        
        public func hash(into hasher: inout Hasher) {
               return hasher.combine(uuid)
           }
           
           public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
               return lhs.uuid == rhs.uuid
           }
        
        var searchData: [(String,String)] {
            return (detail == nil) ? [("",title)] : [("",title),("",detail!)]
        }
        
        let uuid = UUID()
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
        
        
        public var encodedValue: String? {
            if let id = identifier {
                return id
            }
            
            if let det = detail {
                return det
            }
            
            return nil
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
        
        public func unselected() -> ListItem {
            var copy = self
            copy.selected = false
            return copy
        }
        
        public func asSelected() -> ListItem {
            var copy = self
            copy.selected = true
            return copy
        }
        
    }
    
    
    
    
    static let ReuseID = "com.jmade.FormKit.ListSelectionCell"
    
   
    
    /// Closure
    var listSelectionChangeClosure: ListSelectionChangeClosure = { _ in }
    
    /// Delegation
    weak var delegate:ListSelectionDelegate?
    
    // MARK: - ListSelectionValue -
    
    public var formValue:ListSelectionValue? {
        set {
            self._formValue = newValue
        }
        
        get {
            return _formValue
        }
    }
    
    
    public var listSelectValue:ListSelectionValue? {
        set {
            self._formValue = newValue
        }
        
        get {
            return _formValue
        }
    }
    
    
    private var _formValue:ListSelectionValue? = nil
    
    
     
    // MARK: - WriteIn -
    private var allowsWriteIn:Bool {
        if let listSelection = _formValue {
            return listSelection.allowsWriteIn
        }
        return false
    }
    
    enum WriteInState {
        case display, input, create
    }
    
    private var writeInState:WriteInState = .create
    
    
    private var textValue:TextValue?
    
    private var searchQueryInput = ""
    
    private var createNewLabel:String {
        "New: "
        /*
        var newMessage = "New: "
        if let contentTypeName  = _formValue?.writeInConfiguration?.contentTypeName {
            newMessage += " \(contentTypeName): "
        }
        return newMessage
        */
    }
    
    private var writeInAttributedString:NSAttributedString? {
        guard !searchQueryInput.isEmpty else {
            return nil
        }

        let mutableAS = NSMutableAttributedString()
        
        if #available(iOS 13.0, *) {
            
            mutableAS.append(
                .icon("plus.circle", textStyle: .body, tintColor: .systemGreen)
            )
            
            mutableAS.append(
                NSAttributedString(string: createNewLabel, attributes: [
                    .foregroundColor : UIColor.secondaryLabel
                ])
            )
            
            mutableAS.append(
                NSAttributedString(string: "'\(searchQueryInput)'", attributes: [
                    .foregroundColor : UIColor.label
                ])
            )
        }
        
        return NSAttributedString(attributedString: mutableAS)
    }
    
    private var createNewAttributedString:NSAttributedString {
        let mutableAS = NSMutableAttributedString()
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        if #available(iOS 13.0, *) {
            
            mutableAS.append(
                .icon("plus.circle", textStyle: .body, tintColor: .systemGreen)
            )
            
            mutableAS.append(
                NSAttributedString(string: createNewLabel, attributes: [
                    .foregroundColor : UIColor.secondaryLabel,
                    .paragraphStyle : style
                ])
            )
        }
        
        return NSAttributedString(attributedString: mutableAS)
    }
    
    
    private var loadedTextValue:TextValue? {
        return _formValue?.writeInConfiguration?.textValue
    }
    
    private func generateWriteInTextValue() -> TextValue {
         
        func inputConfiguration() -> TextValue.InputConfiguration {
            if let loadedConfig = loadedTextValue?.inputConfiguration {
                let newConfig = TextValue.InputConfiguration(loadedConfig.displaysInputBar,
                                                             loadedConfig.useDirectionButtons,
                                                             loadedConfig.returnKeyType) { [weak self] in
                    loadedConfig.returnPressedClosure?($0)
                    self?.returnPressed($0.value)
                }
                return newConfig
            } else {
                let newConfig = TextValue.InputConfiguration(true, false, .done) { [weak self] in
                    self?.returnPressed($0.value)
                }
                return newConfig
            }
        }
        
        var tv = loadedTextValue ?? TextValue("", "✍🏻", "Custom")
        tv.inputConfiguration = inputConfiguration()
        if tv.allowedChars == nil {
            tv.allowedChars = "'%#,"
        }
        
        tv.style = .writeIn
        
        if !searchQueryInput.isEmpty {
            tv.value = searchQueryInput
        }
        
        return tv
    }
    
    
    enum WriteInStyle {
        case topSection, bottomSection, firstRow
    }
    
    
    private var writeInStyle:WriteInStyle {
        if let placement = _formValue?.writeInConfiguration?.placement {
            switch placement {
            case .topSection:
                return .topSection
            case .topRow:
                return .firstRow
            case .bottomSection:
                return .bottomSection
            }
        }
        return .firstRow
    }
    
    
    private var preventValueUpdate:Bool {
        if let listSelection = _formValue {
            return listSelection.preventValueUpdate
        }
        return false
    }
    
    
    
    private var formIndexPath: IndexPath? = nil
    
    weak var formDelegate:UpdateFormValueDelegate?
    
    
    // MARK: - DataSource -
    public typealias SelectionRow = ListItem
    
    private var completeDataSource:[SelectionRow] = []
    
    private var dataSource: [SelectionRow] = [] {
        didSet {
            //handleSearchPlaceholder()
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
    private var sectionTitles = [""] {
        didSet {
            if let header = tableView.headerView(forSection: 0) {
                header.textLabel?.text = sectionTitles.first
            }
        }
    }
    

    // ***
    /// setting the data from outside
    private var unformatedData: ([String],[Int]) = ([],[]) {
        didSet {
            formatData(unformatedData.0, unformatedData.1)
        }
    }
    
    
    public var allowsMultipleSelection: Bool = true {
        didSet {
            tableView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    
    
    private var selectedIndexPaths:[IndexPath] = []
    
    private var lastSelectedIndexPath:IndexPath? {
        get {
           return selectedIndexPaths.first
        }
    }
    
    
    private var writeInSection:Int {
        switch writeInStyle {
        case .topSection:
            return 0
        case .bottomSection:
            return 1
        case .firstRow:
            return 0
        }
    }
    
    private var writeInPath:IndexPath {
        IndexPath(row: 0, section: writeInSection)
    }
    
    
    
    
    
    
    // MARK: - Searching -
    private var searchEnabled = true
    //private var searchTextField: UISearchTextField? = nil
    
    /// ***
    private var listSearchTable:ListSearchTable? = nil
    private var resultSearchController:UISearchController? = nil
    
    
    var isSeachBarAnimationCompleted: Bool = false
    private var setupWasCalled:Bool = false
    
    private lazy var displayLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "No Results found"
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 68),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        return label
    }()

    public var displayMessage:String? {
        didSet {
            if let displayMessage = displayMessage {
                if displayLabel.alpha.isZero {
                    displayLabel.text = displayMessage
                    UIViewPropertyAnimator(duration: 1/3, curve: .easeIn) { [unowned self] in
                        self.displayLabel.alpha = 1.0
                    }.startAnimation()
                } else {
                    UIViewPropertyAnimator(duration: 1/3, curve: .easeIn) { [unowned self] in
                        self.displayLabel.text = displayMessage
                    }.startAnimation()
                }
            } else {
                UIViewPropertyAnimator(duration: 1/3, curve: .easeIn) { [unowned self] in
                    self.displayLabel.text = nil
                    self.displayLabel.alpha = 0.0
                }.startAnimation()
            }
        }
    }
    
    
    private var shouldSwitchWriteInStateToCreate = true
    
    private let feedbackGenerator = UIImpactFeedbackGenerator()
    
    
    // MARK: - Init -
    required init?(coder aDecoder: NSCoder) {fatalError()}

    /// Init
    public init(_ listSelectValue:ListSelectionValue,at path:IndexPath) {
        super.init(style: listSelectValue.makeDescriptor().tableViewStyle)
        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.ReuseID)
        tableView.register(WriteInCell.self, forCellReuseIdentifier: WriteInCell.ReuseID)
        tableView.register(CreateNewCell.self, forCellReuseIdentifier: CreateNewCell.ReuseID)
        tableView.register(TextCell.self, forCellReuseIdentifier: TextCell.ReuseID)
        tableView.register(FormHeaderCell.self, forHeaderFooterViewReuseIdentifier: FormHeaderCell.identifier)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        
        self.title = listSelectValue.title
        self.allowsMultipleSelection = listSelectValue.selectionType == .multiple
        self.sectionTitles = [listSelectValue.selectionTitle]
        self.formIndexPath = path
        self._formValue = listSelectValue
        
        if allowsMultipleSelection {
            if listSelectValue.allowSelectAll {
                if listSelectValue.isAllSelected {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Deselect All", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleDeSelectAllTapped))
                } else {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select All", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleSelectAllTapped))
                }
            }
        }
        
    }
    
    @objc
    private func handleSelectAllTapped() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Deselect All", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleDeSelectAllTapped))
        performSelectAll()
    }
    
    private func performSelectAll() {
        guard let formValue = formValue else {
            return
        }
        
        let newValue = formValue.newWithAllSelected()
        self._formValue = newValue
        completeDataSource = newValue.listItems
        handleNewDataSource(newValue.listItems)
        crawlDelegate(newValue, false)
    }
    
    private func performDeSelectAll() {
        guard let formValue = formValue else {
            return
        }
        
        let newValue = formValue.newWithoutSelection()
        self._formValue = newValue
        completeDataSource = newValue.listItems
        handleNewDataSource(newValue.listItems)
        crawlDelegate(newValue, false)
    }
    
    
    @objc
    private func handleDeSelectAllTapped() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select All", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleSelectAllTapped))
        performDeSelectAll()
    }
    
    
    public func setValue(_ listSelectValue:ListSelectionValue) {
        self._formValue = listSelectValue
        completeDataSource = listSelectValue.listItems
        self.dataSource = listSelectValue.listItems

        if allowsWriteIn {
            tableView.reloadData()
            tableView.tableFooterView = nil
        } else {
            tableView.tableFooterView = nil
            if tableView.numberOfSections == 0 {
                tableView.insertSections(IndexSet(integer: 0), with: .top)
            } else {
                tableView.insertRows(at: Array(0..<dataSource.count).map({ IndexPath(row: $0, section: 0) }), with: .top)
            }
        }
        
    }
    
    private func handleSearchPlaceholder() {
        if #available(iOS 13.0, *) {
            if let searchController = self.navigationItem.searchController {
                guard dataSource.isEmpty else {
                    if dataSource.count == 1 {
                        searchController.searchBar.searchTextField.placeholder = "Search \(dataSource.count)"
                    } else {
                        searchController.searchBar.searchTextField.placeholder = "Search \(dataSource.count)"
                    }
                    return
                }
                searchController.searchBar.searchTextField.placeholder = "Search"
            }
        }
    }
    
    
    // MARK: - Loading -
    
    
    public typealias ListSelectLoadingClosure = (ListSelectViewController) -> Void

    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if setupWasCalled == false {
            setup()
        }
        
    }
    
    
    private func textValueDidResignActive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            guard let self = self else { return }
            self.checkWriteInState()
        }
    }
    
    private func checkWriteInState() {
        guard shouldSwitchWriteInStateToCreate else {
            return
        }
        if self.writeInState == .input {
            self.writeInState = .create
            performFeedback(0.25)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
                self?.performFeedback(0.67)
            }
        }
    }
    
    
    private func performFeedback(_ intensity:CGFloat) {
        if #available(iOS 13.0, *) {
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred(intensity:intensity)
        }
    }
    
    
    private func returnPressed(_ value:String?) {
        shouldSwitchWriteInStateToCreate = false
        
        guard let listSelctionValue = formValue, let t = textValue, !t.value.isEmpty else {
            return
        }
        
        var writeItem = ListItem(t.value)
        writeItem.selected = true
        
        if allowsMultipleSelection {
            crawlDelegate(
                listSelctionValue.newWith(
                    [ [writeItem], listSelctionValue.listItems ].reduce([],+)
                )
            )
        } else {
            var nonSelected:[ListItem] = listSelctionValue.listItems
            for (i,_) in nonSelected.enumerated() {
                nonSelected[i].selected = false
            }
            
            crawlDelegate(
                listSelctionValue.newWith(
                    [ [writeItem], nonSelected ].reduce([],+)
                )
            )
        }

    }
    
    
    private func writeInSelectedWhileSearching(_ writtenValue:String) {
        
        guard let listSelctionValue = formValue, !writtenValue.isEmpty else {
            return
        }
        
        var writeItem = ListItem(writtenValue)
        writeItem.selected = true
        
        if allowsMultipleSelection {
            crawlDelegate(
                listSelctionValue.newWith(
                    [ [writeItem], listSelctionValue.listItems ].reduce([],+)
                )
            )
        } else {
            var nonSelected:[ListItem] = listSelctionValue.listItems
            for (i,_) in nonSelected.enumerated() {
                nonSelected[i].selected = false
            }
            
            crawlDelegate(
                listSelctionValue.newWith(
                    [ [writeItem], nonSelected ].reduce([],+)
                )
            )
        }
    }
    
    
    private func setup() {
        setupWasCalled = true
        
        displayLabel.alpha = 0
        
        /*
        if navigationItem.largeTitleDisplayMode != .never {
            tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        }
        */
        
        if let listSelectValue = _formValue {
            
            if let loading = listSelectValue.loading {
                if let loadingClosure = loading.loadingClosure {
                    prepareTableForLoading()
                    loadingClosure(self)
                }
            } else {
                if let loadingClosure = listSelectValue.loadingClosure {
                    prepareTableForLoading()
                    loadingClosure(self)
                } else {
                    dataSource = listSelectValue.listItems
                    completeDataSource = listSelectValue.listItems
                }
            }
        }
        
        setupSearch()
    }
    
    
    @objc func donePressed() {
        if allowDismissal {
            dismiss(animated: true, completion: nil)
        } else {
            showDoNotDismiss()
        }
    }
    
    
    public func setLoading() {
        guard tableView.tableFooterView == nil else {
            return
        }
        prepareTableForLoading()
    }
    
    
    
    private func prepareTableForLoading() {
        dataSource = []
        sectionTitles = [""]
        
        if allowsWriteIn {
            if tableView.numberOfSections == 2 {
                tableView.tableFooterView = ItemsLoadingView()
            }
        } else {
            if tableView.numberOfSections == 1 {
                tableView.tableFooterView = ItemsLoadingView()
            }
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
    
    
    private func writeInTapped() {
        switch writeInState {
        case .create:
            if searchQueryInput.isEmpty {
                self.writeInState = .input
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
                        guard let self = self else { return }
                        if let textCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell {
                            textCell.activate()
                        }
                }
            } else {
                writeInSelectedWhileSearching(searchQueryInput)
            }
        case .display:
            self.writeInState = .input
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
                    guard let self = self else { return }
                    if let textCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell {
                        textCell.activate()
                    }
            }
        case .input:
            if let textCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell {
                textCell.activate()
            }
        }
    }
    
    
    
    public func setSectionTitles(_ titles:[String]) {
        self.sectionTitles = titles
    }
    
    
    private func firstSectionTitle() -> String? {
        if allowsMultipleSelection {
            let count = completeDataSource.filter({ $0.selected }).count
            if count == 0 {
                return "0 SELECTED"
            } else {
                if count == completeDataSource.count {
                    return "All \(completeDataSource.filter({ $0.selected }).count) Selected".uppercased()
                } else {
                    return "\(completeDataSource.filter({ $0.selected }).count) Selected".uppercased()
                }
            }
        } else {
            return sectionTitles.first?.uppercased()
        }
    }
  
    
    
    /// ***
    public func reloadExistingData() {
          let existingData = self.unformatedData
          setUnformatedData(existingData)
      }
      
    /// ***
      public func setUnformatedData(_ unformated: ([String],[Int])) {
          DispatchQueue.main.async(execute: { [weak self] in
              self?.unformatedData = unformated
          })
      }
        
    
    /// ***
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

    

    private var numberOfSections:Int {
        if allowsWriteIn {
            if writeInStyle == .firstRow {
                return 1
            } else {
                return 2
            }
        } else {
            return 1
        }
    }

    // MARK: - TableView functions -
    public override func numberOfSections(in tableView: UITableView) -> Int {
        numberOfSections
    }
    
    
    private func headerValue() -> HeaderValue {
        let section = allowsWriteIn ? 1 : 0
        var headerValue = HeaderValue(title: "", section: section)
        headerValue.subtitle = headerTitleForSection(section)
        return headerValue
    }
    
    private func headerTitleForSection(_ section: Int) -> String? {
        if allowsWriteIn {
            switch writeInStyle {
            case .topSection:
                if section == 1 {
                    return firstSectionTitle()
                } else {
                    return nil
                }
            case .bottomSection:
                if section == 0 {
                    return firstSectionTitle()
                } else {
                    return nil
                }
            case .firstRow:
                if section == 0 {
                    return firstSectionTitle()
                } else {
                    return nil
                }
            }
        } else {
            return firstSectionTitle()
        }
    }
    
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allowsWriteIn {
            switch writeInStyle {
                case .topSection:
                    if section == 0 {
                        return 1
                    } else {
                        return dataSource.count
                    }
                case .bottomSection:
                    if section == 0 {
                        return dataSource.count
                    } else {
                        return 1
                    }
            case .firstRow:
                if section == 0 {
                    return dataSource.count + 1
                } else {
                    return dataSource.count
                }
            }
        } else {
            return dataSource.count
        }
    }
    
    
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: FormHeaderCell.identifier) as? FormHeaderCell {
            headerCell.configureView(headerValue())
            return headerCell
        }
        
        return nil
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowsWriteIn {
            if indexPath == writeInPath {
                writeInTapped()
            } else {
                _newDidSelect(indexPath)
            }
        } else {
            newDidSelect(indexPath)
        }
    }
    

    private func newDidSelect(_ indexPath: IndexPath) {
       
        var uncheckedRows:[ListItem] = []
        if allowsMultipleSelection {
            
            if dataSource[indexPath.row].selected {
                uncheckedRows.append(dataSource[indexPath.row])
            }
           
            dataSource[indexPath.row].selected.toggle()
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = dataSource[indexPath.row].selected ? .checkmark : .none
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else { /// Single Selection Mode
            let selectedIndicies = getFilteredSelectedIndicies(removingIndex: nil)
            
            if selectedIndicies.isEmpty {
                /// No Selection
                dataSource[indexPath.row].selected = true
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else {
                // Has Selection
                let selectedRow = selectedIndicies[0]
                if selectedRow == indexPath.row {
                    // Tapping The Selected Row
                    dataSource[indexPath.row].selected = false
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .none
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                
                } else {
                    
                    for (i,_) in dataSource.enumerated() {
                        dataSource[i].selected = false
                    }
                    
                    
                    /// does not remove the last selected one...
                    if (dataSource.count-1) >= selectedRow {
                        dataSource[selectedRow].selected = false
                    } else {
                        /// remove the currently selected on in the completed datra source
                        for (i,_) in completeDataSource.enumerated() {
                            completeDataSource[i].selected = false
                        }
                    }
                    
                    
                    dataSource[indexPath.row].selected = true
                    
                    let section = allowsWriteIn ? 1 : 0
                   
                    if let selectedCell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: section)) {
                        selectedCell.accessoryType = .none
                    }
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .checkmark
                    }
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                }
            }
            
        }
        
        let selectedItems = dataSource.filter({ $0.selected })

        if !allowsMultipleSelection {
            for (i,item) in completeDataSource.enumerated() {
                if let lastItem = selectedItems.last {
                    completeDataSource[i].selected = (lastItem == item)
                }
            }
        } else {
            for (i,item) in completeDataSource.enumerated() {
                if selectedItems.contains(item) {
                    completeDataSource[i].selected = true
                }
                if uncheckedRows.contains(item) {
                    completeDataSource[i].selected = false
                }
            }
        }
        
        
        if !allowsMultipleSelection && selectedItems.isEmpty {
            for (i,_) in completeDataSource.enumerated() {
                completeDataSource[i].selected = false
            }
        }
        
        
        
        if let currentListSelectValue = _formValue {
            let newListSelectValue = currentListSelectValue.newWith(completeDataSource)
            crawlDelegate(newListSelectValue)
        }
        
        tableView.beginUpdates()
        //tableView.headerView(forSection: allowsWriteIn ? 1 : 0)?.textLabel?.text = firstSectionTitle()
        if let headerCell = tableView.headerView(forSection: allowsWriteIn ? 1 : 0) as? FormHeaderCell {
            headerCell.headerValue = headerValue()
        }
        tableView.endUpdates()
    }
    
    
    
    private func _newDidSelect(_ indexPath: IndexPath) {
        
        var dataPath = indexPath
        
        switch writeInStyle {
        case .firstRow:
            dataPath = IndexPath(row: indexPath.row-1, section: indexPath.section)
        case .bottomSection:
            dataPath = indexPath
        case .topSection:
            dataPath = indexPath
        }
        
        let dataRow = dataPath.row
       
        var uncheckedRows:[ListItem] = []
        if allowsMultipleSelection {
            
            if dataSource[dataRow].selected {
                uncheckedRows.append(dataSource[indexPath.row])
            }
           
            dataSource[dataRow].selected.toggle()
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = dataSource[dataRow].selected ? .checkmark : .none
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else { /// Single Selection Mode
            let selectedIndicies = getFilteredSelectedIndicies(removingIndex: nil)
            
            if selectedIndicies.isEmpty {
                /// No Selection
                dataSource[dataRow].selected = true
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else {
                // Has Selection
                let selectedRow = selectedIndicies[0]

                if selectedRow+1 == indexPath.row {
                    // Tapping The Selected Row
                    dataSource[dataRow].selected = false
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .none
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                
                } else {
                    
                    for (i,_) in dataSource.enumerated() {
                        dataSource[i].selected = false
                    }
                    
                    
                    /// does not remove the last selected one...
                    if (dataSource.count-1) >= selectedRow {
                        dataSource[selectedRow].selected = false
                    } else {
                        /// remove the currently selected on in the completed datra source
                        for (i,_) in completeDataSource.enumerated() {
                            completeDataSource[i].selected = false
                        }
                    }
                    
                    
                    dataSource[dataRow].selected = true
                    
                    let section = allowsWriteIn ? writeInSection : 0
                   
                    if let selectedCell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: section)) {
                        selectedCell.accessoryType = .none
                    }
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .checkmark
                    }
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                }
            }
            
        }
        
        let selectedItems = dataSource.filter({ $0.selected })

        if !allowsMultipleSelection {
            for (i,item) in completeDataSource.enumerated() {
                if let lastItem = selectedItems.last {
                    completeDataSource[i].selected = (lastItem == item)
                }
            }
        } else {
            for (i,item) in completeDataSource.enumerated() {
                if selectedItems.contains(item) {
                    completeDataSource[i].selected = true
                }
                if uncheckedRows.contains(item) {
                    completeDataSource[i].selected = false
                }
            }
        }
        
        
        if !allowsMultipleSelection && selectedItems.isEmpty {
            for (i,_) in completeDataSource.enumerated() {
                completeDataSource[i].selected = false
            }
        }
        
        
        
        if let currentListSelectValue = _formValue {
            let newListSelectValue = currentListSelectValue.newWith(completeDataSource)
            crawlDelegate(newListSelectValue)
        }
        
        tableView.beginUpdates()
        
        if let headerCell = tableView.headerView(forSection: allowsWriteIn ? 1 : 0) as? FormHeaderCell {
            headerCell.headerValue = headerValue()
        }
        
        tableView.endUpdates()
    }
    
    

    
    private func crawlDelegate(_ new:ListSelectionValue,_ pop:Bool = true) {
        
        if let nav = navigationController {
            
            var formControllers:[FormController] = []
            for vc in nav.viewControllers {
                if let form = vc as? FormController {
                    formControllers.append(form)
                }
            }
            
            for form in formControllers.reversed() {
                if let path = formIndexPath {
                    if let section = form.dataSource.section(for: path.section) {
                        if let row = section.row(for: path.row) {
                            switch row {
                            case .listSelection(let value):
                                if value.matchesContent(new) {
                                    
                                    if let selectionClosure = formValue?.listItemSelection {
                                        if let item = new.selectedListItem {
                                            selectionClosure(item,nav)
                                        }
                                    } else {
                                        new.valueChangeClosure?(new,form,path)
                                        
                                        if preventValueUpdate {
                                            var deselected = new
                                            deselected.removeSelection()
                                            form.dataSource.updateWith(formValue: deselected, at: path)
                                        } else {
                                            form.dataSource.updateWith(formValue: new, at: path)
                                        }
                                        
                                        form.tableView.reloadRows(at: [path], with: .fade)
                                    }
                                    if pop {
                                        performPop()
                                    }
                                    
                                }
                                
                                /*
                                if new.title == value.title {
                                    form.dataSource.updateWith(formValue: new, at: path)
                                    form.tableView.reloadRows(at: [path], with: .none)
                                    performPop()
                                }
                                */
                            default:
                                break
                            }
                        }
                    }
                }
            }

            
        }
    }
    
    
    
    
    private func performPop() {
        guard !allowsMultipleSelection else { return }
        if let nav = navigationController {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                nav.popViewController(animated: true)
            }
        }
    }

    
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if allowsWriteIn {
            
            if indexPath == writeInPath {

                switch writeInState {
                case .create:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: CreateNewCell.ReuseID, for: indexPath) as? CreateNewCell {
                        if let writeInAttributedString {
                            cell.setValue(writeInAttributedString)
                        } else {
                            cell.setValue(createNewAttributedString)
                        }
                        return cell
                    }
                case .display:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: WriteInCell.ReuseID, for: indexPath) as? WriteInCell {
                        return cell
                    }
                case .input:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.ReuseID, for: indexPath) as? TextCell {
                        cell.formValue = generateWriteInTextValue()
                        cell.updateFormValueDelegate = self
                        cell.indexPath = indexPath
                        cell.didResignActiveClosure = { [weak self] in
                            self?.textValueDidResignActive()
                        }
                        return cell
                    }
                }
            } else {
                switch writeInStyle {
                case .topSection:
                    if indexPath.section == 1 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.ReuseID, for: indexPath) as? ListItemCell {
                            cell.configureCell(dataSource[indexPath.row])
                            return cell
                        }
                    }
                case .firstRow:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.ReuseID, for: indexPath) as? ListItemCell {
                        cell.configureCell(dataSource[indexPath.row-1])
                        return cell
                    }
                case .bottomSection:
                    if indexPath.section == 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.ReuseID, for: indexPath) as? ListItemCell {
                            cell.configureCell(dataSource[indexPath.row])
                            return cell
                        }
                    }
                }
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.ReuseID, for: indexPath) as? ListItemCell {
                cell.configureCell(dataSource[indexPath.row])
                return cell
            }
        }
        return .init()
    }
    
    
    
    private func getSelectedIndicies(removingIndex:Int?) -> [Int] {
        var selectedPaths: [Int] = []
        
        for (row,value) in completeDataSource.enumerated() {
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
    
    
    private func getFilteredSelectedIndicies(removingIndex:Int?) -> [Int] {
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

}


extension ListSelectViewController: UpdateFormValueDelegate {
    
    
    public func updatedFormValue(_ formValue:FormValue,_ indexPath:IndexPath?) {
        if let textValue = formValue as? TextValue {
            self.textValue = textValue
        }
    }
    
    public func toggleTo(_ direction:Direction,_ from:IndexPath) {
        /* Intentionally left blank  */
    }
    
}



extension ListSelectViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.selectedScopeButtonIndex != 0 {
            useListItemsStoreAt(0,"")
        } else {
            handleSearchQuery("")
        }
    }
    
    
    private func setupSearch() {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
       // searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        
        if let listSelect = formValue {
            
            if listSelect.qualifiesForScopeTitles {
                if #available(iOS 13.0, *) {
                    searchController.automaticallyShowsScopeBar = true
                }
                searchController.searchBar.scopeButtonTitles = listSelect.listItemStores.map({ $0.key })
            }
        }
        
        self.navigationItem.searchController = searchController
        
        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.backgroundColor = .systemBackground
            searchController.searchBar.tintColor = .label
        }
        
        definesPresentationContext = true
        tableView.keyboardDismissMode = .interactive
    }
    
    
    var writeInListItem:ListItem? {
        if allowsWriteIn {
            return ListItem("✍🏻")
        }
        return nil
    }

    
    private func handleSearchQuery(_ query:String) {
        
        searchQueryInput = query
        
        if allowsWriteIn {
            
            switch writeInStyle {
            case .topSection:
                let old = dataSource
                let new = filterItems(query)
                let changes = diff(old: old, new: new)
                self.dataSource = new
                
                tableView.reload(changes: changes,
                                 section: 1,
                                 insertionAnimation: .fade,
                                 deletionAnimation: .fade,
                                 replacementAnimation: .fade,
                                 updateData: {},
                                 completion: nil
                )
            case .firstRow:
                let filtered = filterItems(query)
                let old:[ListItem] = [[self.writeInListItem].compactMap({ $0 }),dataSource].reduce([],+)
                let new:[ListItem] = [[self.writeInListItem].compactMap({ $0 }),filtered].reduce([],+)
                let changes = diff(old: old, new: new)
                
                self.dataSource = filtered
                
                tableView.reload(changes: changes,
                                 section: 0,
                                 insertionAnimation: .fade,
                                 deletionAnimation: .fade,
                                 replacementAnimation: .fade, updateData: {},
                                 completion: nil
                )
            case .bottomSection:
                let old = dataSource
                let new = filterItems(query)
                let changes = diff(old: old, new: new)
                self.dataSource = new
                tableView.reload(changes: changes,
                                 section: 0,
                                 insertionAnimation: .fade,
                                 deletionAnimation: .fade,
                                 replacementAnimation: .fade, updateData: {},
                                 completion: nil
                )
            }
        } else {
            let old = dataSource
            let new = filterItems(query)
            let changes = diff(old: old, new: new)
            self.dataSource = new
            tableView.reload(changes: changes,
                             section: 0,
                             insertionAnimation: .fade,
                             deletionAnimation: .fade,
                             replacementAnimation: .fade, updateData: {},
                             completion: nil
            )
            
        }
        
        
        displayMessage = dataSource.isEmpty ? "No Results Found" : nil
    }
    
    
    private func handleNewDataSource(_ newDataSource: [SelectionRow]) {
        if allowsWriteIn {
            switch writeInStyle {
            case .topSection:
                self.dataSource = newDataSource
                tableView.reloadSections(IndexSet(integer: 1), with: .fade)
            case .firstRow:
                let new:[ListItem] = [[self.writeInListItem].compactMap({ $0 }),newDataSource].reduce([],+)
                self.dataSource = new
                tableView.reloadSections(.zero, with: .fade)
            case .bottomSection:
                self.dataSource = newDataSource
                tableView.reloadSections(.zero, with: .fade)
            }
        } else {
            self.dataSource = newDataSource
            tableView.reloadSections(.zero, with: .fade)
        }
    }
    

    
    
    func filterItems(_ filter:String) -> [ListItem] {
        return completeDataSource
            .filter(matchesUserFilter(filter))
    }
    
    func matchesUserFilter(_ userFilter : String) -> (ListItem) -> Bool {
        return {
            return $0.searchData.map({($0.0, "\($0.1)")}).reduce(false){
                return $0 || $1.1.localizedStandardContains(userFilter) || userFilter == ""
            }
        }
    }

    
}


// MARK: - UISearchResultsUpdating -
extension ListSelectViewController: UISearchResultsUpdating {
    
  
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            handleSearchQuery(text)
        }
    }
    
    
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        useListItemsStoreAt(selectedScope,searchBar.text)
    }
    
}


extension ListSelectViewController {
    
    private func useListItemsStoreAt(_ index:Int,_ searchText:String?) {
        
        guard let listSelect = formValue else { return }
        
        guard listSelect.listItemStores.count >= index else {
            return
        }
        
        var newItems = listSelect.listItemStores[index].listItems
        
        if !newItems.isEmpty {
            for (i,value) in completeDataSource.enumerated() {
                if newItems.count >= i {
                    newItems[i].selected = value.selected
                }
            }
        }
        
        completeDataSource = newItems
        handleSearchQuery(searchText ?? "")
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
        label.textColor = UIColor.FormKit.valueText
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
            
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: secondaryTextLabel.bottomAnchor),
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



// MARK: - WriteInCell -  
final class WriteInCell: UITableViewCell {
    
    static let ReuseID = "FormKit.WriteInCell"
    
    private lazy var primaryTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Custom ..."
        if #available(iOS 13.0, *) {
            label.textColor = .systemBlue
        }
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle:  .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
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
            
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: primaryTextLabel.bottomAnchor),
            
        ])
        
    }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        //primaryTextLabel.text = nil
    }
  
}




// MARK: - CreateNewCell -
final class CreateNewCell: UITableViewCell {
    
    static let ReuseID = "FormKit.ListSelect.CreateNewCell"
    
    private lazy var primaryTextLabel: UILabel = {
        let label = UILabel()
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
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: primaryTextLabel.bottomAnchor),
        ])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        primaryTextLabel.attributedText = nil
    }
    
    public func setValue(_ value:NSAttributedString) {
        primaryTextLabel.attributedText = value
    }
    
}
