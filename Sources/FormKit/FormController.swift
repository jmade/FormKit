import UIKit


// MARK: - CustomTransitionable -
protocol CustomTransitionable: class {
    var customTransitioningDelegate: PresentationTransitioningDelegate { get }
}



// MARK: - BottomBarActionItem -
public struct BottomBarActionItem {
    
    public enum Position {
        case leading, center, trailing
    }
    
    public typealias ActionClosure = (FormController) -> Void
    
    let position:Position
    let title:String
    let actionClosure:ActionClosure
    var spacer:Bool
    public init(title:String,position:Position,closure: @escaping ActionClosure) {
        self.title = title
        self.position = position
        self.actionClosure = closure
        self.spacer = false
    }
}

extension BottomBarActionItem {
    static func Spacer() -> BottomBarActionItem {
        var spacerItem = BottomBarActionItem(title: "", position: .center, closure: { _ in })
        spacerItem.spacer = true
        return spacerItem
    }
}




// MARK: - FormTableViewController -
open class FormController: UITableViewController, CustomTransitionable {
    
    var customTransitioningDelegate = PresentationTransitioningDelegate()
    
    var bottomBarItems:[BottomBarActionItem] = []
    var leadingToolBarButtonTitle:String?
    var trailingToolBarButtonTitle:String?

    var selectedIndexPath: IndexPath?
    var reuseIdentifiers: Set<String> = []
    
    
    public var dataSource = FormDataSource(sections: []) {
        didSet {
            
            guard !dataSource.isEmpty else {
                /*
                if let loadingView = tableView.tableFooterView as? ItemsLoadingView {
                    loadingView.displayMessage("No Data")
                }
                */
                print("[FromController] Empty `FormDataSource` loaded")
                return
            }
            
            title = dataSource.title
            tableView.tableFooterView = nil
            
            if oldValue.isEmpty {
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let self = self else { return }
                    if self.tableView.numberOfSections == 0 {
                        self.tableView.insertSections(
                            IndexSet(integersIn: 0...(self.dataSource.sections.count-1)),
                            with: .top
                        )
                    } else {
                        self.tableView.reloadSections(
                            IndexSet(integersIn: 0...(self.dataSource.sections.count-1)),
                            with: .automatic
                        )
                    }
                })
            } else {
                
                let old = oldValue
                let new = dataSource
                
                struct SectionChange {
                    enum Operation {
                        case adding,deleting,reloading
                    }
                    let operation:Operation
                    let section: Int
                    var changes:[Change<FormItem>]?
                    var indexSet:IndexSet?
                }
                
                var sectionChanges:[SectionChange] = []
                
                for i in 0..<max(old.sections.count, new.sections.count) {
                    let isOldSectionEmpty = old.rowsForSection(i).isEmpty
                    let isNewSectionEmpty = new.rowsForSection(i).isEmpty
                    let changingSection = (isOldSectionEmpty == false) && (isNewSectionEmpty == false)
                    let addingSection = (isOldSectionEmpty == true) && (isNewSectionEmpty == false)
                    let removingSection = (isOldSectionEmpty == false) && (isNewSectionEmpty == true)
                    if changingSection {
                        let changes = diff(old: old.rowsForSection(i), new: new.rowsForSection(i))
                        sectionChanges.append(SectionChange(operation: .reloading, section: i, changes: changes, indexSet: nil))
                    }
                    if addingSection {
                        sectionChanges.append(SectionChange(operation: .adding, section: i, changes: nil, indexSet: IndexSet(arrayLiteral: i)))
                    }
                    if removingSection {
                        sectionChanges.append(SectionChange(operation: .deleting, section: i, changes: nil, indexSet: IndexSet(arrayLiteral: i)))
                    }
                }
                
                let inserts = sectionChanges.filter({ $0.operation == .adding }).map({$0.section})
                let deletes = sectionChanges.filter({ $0.operation == .deleting }).map({$0.section})
                let reloads = sectionChanges.filter({ $0.operation == .reloading })
                
                var sectionReloads:[Int] = []
                var actualInserts:[Int] = []
                for i in inserts {
                    if Array(0..<old.sections.count).contains(i) {
                        sectionReloads.append(i)
                    } else {
                        actualInserts.append(i)
                    }
                }
                
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let self = self else { return }
                    self.tableView.beginUpdates()
                    self.tableView.insertSections(IndexSet(actualInserts), with: .automatic)
                    self.tableView.deleteSections(IndexSet(deletes), with: .automatic)
                    self.tableView.reloadSections(IndexSet(sectionReloads), with: .automatic)
                    reloads.forEach({
                        if let sectionHeader = self.tableView.headerView(forSection: $0.section) as? FormHeaderCell {
                            sectionHeader.titleLabel.text = self.dataSource.sections[$0.section].title
                        }
                        if let changes = $0.changes {
                            self.tableView.reload(
                                changes: changes,
                                section: $0.section,
                                insertionAnimation: .automatic,
                                deletionAnimation:  .automatic,
                                replacementAnimation:  .automatic,
                                completion: nil
                            )
                        }
                    })
                    self.tableView.endUpdates()
                })
            }
            

        }
    }
    
    /// Loading
    
    public typealias FormDataLoadingClosure = ( () -> (FormDataSource) )
    public var loadingClosure: FormDataLoadingClosure? = nil
    
    private var loadingMessage: String? = nil
    
    private var checkInMessage: String? = nil
    
    
    // MARK: - shouldRefresh -
    public var shouldRefresh:Bool = false
    // MARK: - DoneButton -
    public var showsDoneButton:Bool = false
    
    
    
    
    // MARK: - init -
    required public init?(coder aDecoder: NSCoder) {fatalError()}
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
        controllerInitialize()
    }
    
    public init(formData: FormDataSource) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
        controllerInitialize()
        defer {
            self.dataSource = formData
        }
    }
    
    public init(checkInMessage:String) {
         if #available(iOS 13.0, *) {
                   super.init(style: .insetGrouped)
               } else {
                   super.init(style: .grouped)
               }
        self.checkInMessage = checkInMessage
        controllerInitialize()
    }

    // MARK: - Controller Base Initialize -
    private func controllerInitialize() {
        
        // Header Cell
        tableView.register(FormHeaderCell.self, forHeaderFooterViewReuseIdentifier: FormHeaderCell.identifier)
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = ItemsLoadingView()
        tableView.contentInset = UIEdgeInsets(top: 22.0, left: 0, bottom: 0, right: 0)
        
        /*
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(cancelPressed))
        */
        
        if showsDoneButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(barButtonItemPressed(_:)))
        }
        
        if shouldRefresh {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
               
        setupToolBar()
    }
    

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loadingMessage = checkInMessage {
            print("[FormController] we got `checkInMessage`")
            if #available(iOS 13.0, *) {
                tableView.tableFooterView = ItemsLoadingView(message: loadingMessage, textStyle: .body, color: .label)
            } else {
                tableView.tableFooterView = ItemsLoadingView(message: loadingMessage, textStyle: .body, color: .black)
            }
        }
        
    }
    
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if toolbarItems != nil {
            self.navigationController?.setToolbarHidden(false, animated: false)
        } else {
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
        
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let firstInputPath = dataSource.firstInputIndexPath {
            if let nextCell = tableView.cellForRow(at: firstInputPath) {
                if let activatabelCell = nextCell as? Activatable {
                    activatabelCell.activate()
                }
            }
        }
        
    }
    
    
    public func loadingMode(message:String) {
        if let loadingView = tableView.tableFooterView as? ItemsLoadingView {
            loadingView.displayMessage(message)
        }
        self.dataSource = FormDataSource()
    }
    
    
    @objc
    private func barButtonItemPressed(_ barButtonItem:UIBarButtonItem) {
        
        if let barButtonTitle = barButtonItem.title {
            print("Bar Button Item Pressed: \(barButtonTitle)")
            switch barButtonTitle  {
            case "Done":
                donePressed()
            default:
                ()
            }
        }
        
        
    }
    
    
    
}


// MARK: - Toolbar Setup -
extension FormController {
    
    func setupToolBar(){
        if bottomBarItems.isEmpty { return }
        var barItems:[UIBarButtonItem] = []
        for item in bottomBarItems {
            if item.spacer {
                barItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
            } else {
                switch item.position {
                case .leading:
                    barItems.append(
                        UIBarButtonItem(customView:
                            RoundButton(
                                titleText: item.title,
                                target: self,
                                action: #selector(leadingButtonBarPressed),
                                color: .lightGray,
                                style: .bar
                            )
                    ))
                case .center:
                    barItems.append(UIBarButtonItem(title: item.title, style: .plain, target: self, action: #selector(centerBarButtonPressed)))
                case .trailing:
                    barItems.append(
                        UIBarButtonItem(customView:
                            RoundButton(
                                titleText: item.title,
                                target: self,
                                action: #selector(trailingBarButtonPressed),
                                color: .lightGray,
                                style: .bar
                            )
                    ))
                }
            }
        }
        toolbarItems = barItems
    }
    
    // ToolBar Presses
    @objc
    func leadingButtonBarPressed(){
        
        if let toolbarRoundButton = (toolbarItems?.first?.customView as? RoundButton) {
            toolbarRoundButton.animateTitleAndColor("Copied", #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
        }
        
        for item in bottomBarItems where item.position == .leading {
            item.actionClosure(self)
        }
    }
    
    @objc
    func trailingBarButtonPressed(){
        
        if let toolbarRoundButton = (toolbarItems?.last?.customView as? RoundButton) {
            toolbarRoundButton.animateTitleAndColor("Pasted", #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
        }
        
        for item in bottomBarItems where item.position == .trailing {
            item.actionClosure(self)
        }
        
    }
    
    @objc
    func centerBarButtonPressed(){
        
        for item in bottomBarItems where item.position == .center {
            item.actionClosure(self)
        }
        
    }
    
    
    // Navigation Bar Buttons
    @objc
    func cancelPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func donePressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  [weak self] in
            guard let self = self else { return }
            //self.dataSource = FormDataSource.Random()
            self.refreshControl?.endRefreshing()
        }
    }
    
}



// MARK: - TableView -
extension FormController {
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.sections[section].rows.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let formItem = dataSource.itemAt(indexPath) {
            let descriptor = formItem.cellDescriptor
            if !reuseIdentifiers.contains(descriptor.reuseIdentifier) {
                tableView.register(descriptor.cellClass, forCellReuseIdentifier: descriptor.reuseIdentifier)
                reuseIdentifiers.insert(descriptor.reuseIdentifier)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: descriptor.reuseIdentifier, for: indexPath)
            descriptor.configure(self, cell, indexPath)
            return cell
        }
        return .init()
    }
    
    override open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        if let formItem = dataSource.itemAt(indexPath) {
            if let selectableFormItem = formItem as? TableViewSelectable {
                return selectableFormItem.isSelectable
            }
        }
        
        return true
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        if let item = dataSource.itemAt(indexPath) {
            item.cellDescriptor.didSelect(self,indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !dataSource.sections[section].title.isEmpty {
            if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: FormHeaderCell.identifier) as? FormHeaderCell {
                headerCell.titleLabel.text = dataSource.sections[section].title
                return headerCell
            }
        }
        return nil
    }
    
    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.sections[section].title.isEmpty ? 0 : UITableView.automaticDimension
    }
    
    override open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}


extension FormController {
    
    public func updateSection(_ newSection:FormSection,at path:IndexPath) {
        dataSource.sections[path.section] = newSection
        tableView.reloadSections(IndexSet(integer: path.section), with: .automatic)
    }
    
}


// MARK: - UpdateFormValueDelegate -
extension FormController: UpdateFormValueDelegate {
    
    public func updatedFormValue(_ formValue: FormValue, _ indexPath: IndexPath?) {
        if let path = indexPath {
            
            if let formItem = dataSource.itemAt(path) {
                switch formItem {
                case .stepper(let stepper):
                    if let stepperValue = formValue as? StepperValue {
                        if stepperValue != stepper {
                            dataSource.updateWith(formValue: stepperValue, at: path)
                        }
                    }
                case .text(let text):
                    if let textValue = formValue as? TextValue {
                        if textValue != text {
                            dataSource.updateWith(formValue: textValue, at: path)
                        }
                    }
                case .time(let time):
                    if let timeValue = formValue as? TimeValue {
                        if timeValue != time {
                            dataSource.updateWith(formValue: timeValue, at: path)
                            tableView.reloadRows(at: [path], with: .none)
                        }
                    }
                case .button(_):
                    break
                case .note(let note):
                    if let noteValue = formValue as? NoteValue {
                        if noteValue != note {
                            dataSource.updateWith(formValue: noteValue, at: path)
                        }
                    }
                case .segment(let segment):
                    if let segmentValue = formValue as? SegmentValue {
                        if segmentValue != segment {
                            dataSource.updateWith(formValue: segmentValue, at: path)
                        }
                    }
                case .numerical(let numerical):
                    if let numericalValue = formValue as? NumericalValue {
                        if numericalValue != numerical {
                            dataSource.updateWith(formValue: numericalValue, at: path)
                        }
                    }
                case .readOnly(let readOnly):
                    if let readOnlyValue = formValue as? ReadOnlyValue {
                        if readOnlyValue != readOnly {
                            dataSource.updateWith(formValue: readOnlyValue, at: path)
                        }
                    }
                case .picker(let picker):
                    if let pickerValue = formValue as? PickerValue {
                        if pickerValue != picker {
                            dataSource.updateWith(formValue: pickerValue, at: path)
                        }
                    }
                case .pickerSelection(let pickerSelection):
                    if let pickerSelectionValue = formValue as? PickerSelectionValue {
                        if pickerSelectionValue != pickerSelection {
                            dataSource.updateWith(formValue: pickerSelectionValue, at: path)
                            tableView.reloadRows(at: [path], with: .automatic)
                        }
                    }
                case .action(let actionValue):
                    if let localActionValue = formValue as? ActionValue {
                        if localActionValue != actionValue {
                            dataSource.updateWith(formValue: localActionValue, at: path)
                            tableView.reloadRows(at: [path], with: .automatic)
                        }
                    }
                case .listSelection(let list):
                    if let listSelectionValue = formValue as? ListSelectionValue {
                        if listSelectionValue != list {
                            dataSource.updateWith(formValue: listSelectionValue, at: path)
                            tableView.reloadRows(at: [path], with: .automatic)
                        }
                    }
                case .timeInput(let time):
                    if let timeInputValue = formValue as? TimeInputValue {
                        if timeInputValue != time {
                            dataSource.updateWith(formValue: timeInputValue, at: path)
                            tableView.reloadRows(at: [path], with: .none)
                        }
                    }
                }
            }
        }
    }
    

    public func toggleTo(_ direction: Direction, _ from: IndexPath) {
        
        if let currentCell = tableView.cellForRow(at: from) {
            currentCell.resignFirstResponder()
        }
        
        switch direction {
        case .previous:
            if let previousIndexPath = dataSource.previousIndexPath(from) {
                tableView.scrollToRow(at: previousIndexPath, at: .none, animated: false)
                if let previousCell = tableView.cellForRow(at: previousIndexPath) {
                    if let activatabelCell = previousCell as? Activatable {
                        activatabelCell.activate()
                    }
                }
            }
        case .next:
            if let nextIndexPath = dataSource.nextIndexPath(from) {
                tableView.scrollToRow(at: nextIndexPath, at: .none, animated: false)
                if let nextCell = tableView.cellForRow(at: nextIndexPath) {
                    if let activatabelCell = nextCell as? Activatable {
                        activatabelCell.activate()
                    }
                }
            }
        }
        
        FormConstant.makeSelectionFeedback()
    }
}


// MARK: - ButtonActionDelegate -
extension FormController: ButtonActionDelegate {
    
    public func performAction(_ action: String) {
        print("Button Was Tapped: \(action)")
        pushNewRandomForm()
    }
    
    func pushNewRandomForm(){
        if #available(iOS 13.0, *) {
            let newFormController = FormController(style: .insetGrouped)
            newFormController.dataSource = FormDataSource.Random()
            navigationController?.pushViewController(newFormController, animated: true)
        } else {
            let newFormController = FormController(style: .grouped)
            newFormController.dataSource = FormDataSource.Random()
            navigationController?.pushViewController(newFormController, animated: true)
        }
    }
    
}



// MARK: - FormHeaderCell -
public final class FormHeaderCell: UITableViewHeaderFooterView {
    static let identifier = "FormKit.FormHeaderCell"
    let titleLabel = UILabel()
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .headline).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        
        let trailingConstraint = contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        trailingConstraint.priority = UILayoutPriority(rawValue: 999)
        trailingConstraint.isActive = true
        
        let bottomConstraint = contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        bottomConstraint.isActive = true
        
        let heightAnchorConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
        heightAnchorConstraint.isActive = true
    }
    public override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
