import UIKit
import QuickLook







// MARK: - FormValidationClosure -
public typealias FormValidationClosure = ( (FormDataSource,FormController) -> Void )

public typealias FormDataPublishClosure = ( (FormDataSource) -> (FormDataSource) )



extension UITableView {
    
    public func indexPathOfFirstResponder() -> IndexPath? {
        
        if let visiblePaths = indexPathsForVisibleRows {
            for path in visiblePaths {
                if let cell = cellForRow(at: path) {
                    for view in cell.contentView.subviews {
                        if view.isFirstResponder {
                            return path
                        }
                    }
                }
            }
        }
        
     
        
//        for section in Array(0...numberOfSections) {
//            for row in Array(0...numberOfRows(inSection: section)) {
//                if let cell = cellForRow(at: IndexPath(row: row, section: section)) {
//                    for view in cell.contentView.subviews {
//                        if view.isFirstResponder {
//
//                            return IndexPath(row: row, section: section)
//                        }
//                    }
//                }
//            }
//        }
        
        
        return nil
        
    }
    
    
    public func firstResponderIndexPaths() -> [IndexPath] {
        var responderPaths: [IndexPath] = []
        
        for section in Array(0...numberOfSections) {
            for row in Array(0...numberOfRows(inSection: section)) {
                if let cell = cellForRow(at: IndexPath(row: row, section: section)) {
                    for view in cell.contentView.subviews {
                        if view.isFirstResponder {
                            responderPaths.append(
                                IndexPath(row: row, section: section)
                            )
                        }
                    }
                }
            }
        }
        return responderPaths
        
    }
    
    
}



// MARK: - CustomTransitionable -
protocol CustomTransitionable: AnyObject {
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



public typealias DocumentInteractionControllerClosure = ( (FormController,UIDocumentInteractionController) -> Void )




// MARK: - BarItem -
public struct BarItem {
    
    public typealias ActionClosure = ((FormController,BarItem) -> Void)
    
    public enum Side {
        case leading, trailing
    }
    
    public var title:String? = nil
    public var imageName:String? = nil
    public var action: ActionClosure?
    public var side:Side = .trailing
    let identifier = UUID()
}


extension BarItem: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: BarItem, rhs: BarItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


public extension BarItem {
    
    init(title:String,action:ActionClosure?) {
        self.title = title
        self.imageName = nil
        self.action = action
    }
    
    
    init(title:String,_ side:Side,action:ActionClosure?) {
        self.title = title
        self.imageName = nil
        self.side = side
        self.action = action
    }
    
    
    init(imageName:String, action: @escaping ActionClosure) {
        self.action = action
        self.imageName = imageName
        self.title = nil
    }
    
    
    init(imageName:String,_ side:Side, action: @escaping ActionClosure) {
        self.action = action
        self.side = side
        self.imageName = imageName
        self.title = nil
    }
    
    
}



extension BarItem {
    
    static func Cancel(_ action: @escaping ActionClosure) -> BarItem {
        BarItem(title: "Cancel", .leading, action: action)
    }
    
    static func Done(_ action: @escaping ActionClosure) -> BarItem {
        BarItem(title: "Done", .trailing, action: action)
    }
    
}



extension BarItem {
    
    var isDone:Bool {
        if let text = title {
            if text == "Done" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    var isCancel:Bool {
        if let text = title {
            if text == "Cancel" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    
    enum BarItemType {
        case text, image
    }
    
    
    var type:BarItemType {
        if let _ = title {
            return .text
        } else {
            return .image
        }
    }
    
    
    var image:UIImage? {
        if let name = imageName {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: name)
            }
        }
        return nil
    }
    
    
    func barButtonItem(target: UIViewController,selector:Selector) -> UIBarButtonItem {
        switch self.type {
        case .image:
            return UIBarButtonItem(image: self.image ?? UIImage(), style: .plain, target: target, action: selector)
        case .text:
            return UIBarButtonItem(title: title, style: isDone ? .done : .plain, target: target, action: selector)
        }
    }
    
    
}




extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}






public typealias FormDismissalClosure = ( () -> Void )
public typealias FormControllerDismissalClosure = ( (FormController) -> Void )

// MARK: - FormController -
open class FormController: UITableViewController, CustomTransitionable, QLPreviewControllerDataSource {
    
    private var previewController:QLPreviewController?
    private var previewItem:FKPreview?
    
    public var publishClosure: FormDataPublishClosure?
    
    
    public var dismissalClosure: FormDismissalClosure?
    public var closeClosure: FormControllerDismissalClosure?
    
    private var contentSizeObserver : NSKeyValueObservation?
    
    var customTransitioningDelegate = PresentationTransitioningDelegate()
    
    public var transitionManager: UIViewControllerTransitioningDelegate?
    
    var bottomBarItems:[BottomBarActionItem] = []
    var leadingToolBarButtonTitle:String?
    var trailingToolBarButtonTitle:String?

    var selectedIndexPath: IndexPath? = nil
    private var reuseIdentifiers: Set<String> = []
    
    
    public var barItems:[BarItem] = [] {
        didSet {
            checkBarItems()
        }
    }
    
    
    public var leadingBarItems:[BarItem] {
        barItems.filter({ $0.side == .leading })
    }
    
    public var trailingBarItems:[BarItem] {
        get {
            barItems.filter({ $0.side == .trailing })
        }
    }
    
    private var currentInPlaceBarItem: BarItem?
    
    private var currentInPlaceBarButtonItem: UIBarButtonItem? {
        didSet {
            if currentInPlaceBarButtonItem != nil {
                generateHapticFeedback(.impact)
            } else {
                currentInPlaceBarItem = nil
            }
        }
    }

    //private var loadingBarButtonItem = UIBarButtonItem()

    
    /// Additional Closures
    public var documentInteractionWillBegin: DocumentInteractionControllerClosure?
    public var documentInteractionDidEnd: DocumentInteractionControllerClosure?
    
    
    public var validationClosure:FormValidationClosure?
    
    
    // MARK: - DataSource -
    public var dataSource = FormDataSource() {
       
        didSet {
            //print("ds: didSet")
            
            guard !dataSource.isEmpty, tableView.window != nil else {
                return
            }
            
            tableView.tableFooterView = nil
            
            self.title = self.dataSource.title
            
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
                            with: .fade
                        )
                    }
                })
            } else {
                handleDataEvaluation(
                    FormDataSource.evaluate(oldValue, new: dataSource)
                )
            }
            
            runValidation()
        }
    }
    
    private var isEvaluating: Bool = false
    
    
    private var headers:[HeaderValue] {
        return dataSource.headerValues()
    }
    
    private var footers:[FooterValue] {
        return dataSource.footerValues()
    }
    
    private var lastInvalidItems:[FormDataSource.InvalidItem] = []
    
    
    private var defaultContentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
    
    
    /// Loading
    public typealias FormDataLoadingClosure = (FormController) -> Void
    public var loadingClosure: FormDataLoadingClosure? = nil
    private var loadingClosureCalled = false
    private var didLoad = false
    
    private var loadingMessage: String? = nil
    
    private var checkInMessage: String? = nil
    
    
    // MARK: - ShouldRefresh -
    public var shouldRefresh:Bool = false
    
    
    // MARK: - DoneButton -
    private lazy var doneBarItem: BarItem = {
        return BarItem.Done { form,_ in
            form.donePressed()
        }
    }()
    
    public var showsDoneButton:Bool = false {
        didSet {
            if showsDoneButton {
                if !barItems.containsItem(doneBarItem) {
                    barItems.append(doneBarItem)
                }
                checkBarItems()
            } else {
                if barItems.containsItem(doneBarItem) {
                    barItems.removeObject(doneBarItem)
                }
            }
        }
    }
    
    
    
    // MARK: - Cancel Button -
    private lazy var cancelBarItem: BarItem = {
        return BarItem.Cancel { form,_ in
            form.cancelPressed()
        }
    }()
    
    
    public var showsCancelButton:Bool = false {
        didSet {
            if showsCancelButton {
                if !barItems.containsItem(cancelBarItem) {
                    barItems.append(cancelBarItem)
                }
            } else {
                if barItems.containsItem(cancelBarItem) {
                    barItems.removeObject(cancelBarItem)
                }
            }
        }
    }
    
    
    
    // MARK: - Activates Input On Appear -
    public var activatesInputOnAppear: Bool = false
    
    public var usesSwipeAction: Bool = false
    
    public typealias SwipeActionClosure = ((FormController,FormItem,IndexPath) -> Void)
    public var destructiveSwipeAction:SwipeActionClosure?
    
    public var usesContextMenus: Bool = false
    
    /*
    @available(iOS 13.0, *)
    public typealias ContextMenuClosure = ( (FormController,FormItem,IndexPath) -> UIMenu?)
    
    
    @available(iOS 13.0, *)
    private(set) lazy var contextMenuClosure:ContextMenuClosure = {_,_,_ in return nil}
    */
     
    public var allowModalDismissal:Bool = false {
        didSet {
            if #available(iOS 13.0, *) {
                isModalInPresentation = !allowModalDismissal
            }
        }
    }
    
    
    
    private var hasActivated = false
    
    private var alertTextFieldInput: String? = nil
    
    private var identifier:String = UUID().uuidString
    
    
    // MARK: - FormDisplayStyle -
    public enum FormDisplayStyle {
        case modern
        case classic
        case classicGrouped
        case custom(UITableView.Style)
        
        public func isModern() -> Bool {
            switch self {
            case .modern:
                return true
            default:
                return false
            }
        }
    }
    
    private var displayStyle:FormDisplayStyle = .modern
    
    private var colorSelectedClosure:( (UIColor?) -> Void)?
    
    private var pickedColor:UIColor? {
        didSet {
            colorSelectedClosure?(pickedColor)
        }
    }
    
    
    public var scrollsWithSectionExpansion: Bool = true
    
    
    // Notification center support
    public typealias NotificationClosure = (FormController,Notification) -> Void
    public var notificationHandler:NotificationClosure?
    
    private var notificationName:Notification.Name?
    private var notificationSet: Bool = false {
        didSet {
            print("Notification Set!")
        }
    }
    
    
    public var lastSegmentValue:SegmentValue?
    
    public var activeIndexPath:IndexPath?
    private var keyboardIsShowing:Bool = false
    
    private var imageResultClosure:((UIImage?) -> ())?
    
    // MARK: - deinit -
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    

    // MARK: - init -
    required public init?(coder aDecoder: NSCoder) {fatalError()}
    
    
    public init(configuration:FormControllerConfiguration) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
        
        self.title = configuration.title
        self.loadingMessage = configuration.loadingMessage
        self.loadingClosure = configuration.loadingClosure
        self.validationClosure = configuration.validationClosure
        
        if configuration.showsDoneButton {
            barItems.append(doneBarItem)
        }
        
        if configuration.showsCancelButton {
            barItems.append(cancelBarItem)
        }
        
        self.activatesInputOnAppear = configuration.activatesInputOnAppear
        self.allowModalDismissal = configuration.allowModalDismissal
        self.dataSource.updateClosure = configuration.updateClosure
        self.notificationName = configuration.notificationName
        self.notificationHandler = configuration.notificationHandler
        
    }
    
 
    public init(formData: FormDataSource) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
        self.dataSource = formData
        self.title = dataSource.title
    }
    
    
    
    
    public init(_ title:String,_ data: FormDataSource) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
        self.dataSource = data
        self.title = title
    }
    
    
    
    public init(_ data: FormDataSource, validation: @escaping FormValidationClosure) {
           if #available(iOS 13.0, *) {
               super.init(style: .insetGrouped)
           } else {
               super.init(style: .grouped)
           }
           self.dataSource = data
           self.validationClosure = validation
       }

    
    
    public init(loadingMessage:String?,loadingClosure: @escaping FormDataLoadingClosure) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
        self.loadingMessage = loadingMessage
        self.loadingClosure = loadingClosure
    }
    
    
    
    public init(title: String,style: FormDisplayStyle,loading: @escaping FormDataLoadingClosure) {
        switch style {
        case .modern:
            if #available(iOS 13.0, *) {
                super.init(style: .insetGrouped)
            } else {
                super.init(style: .grouped)
            }
        case .classic:
            super.init(style: .plain)
        case .classicGrouped:
            super.init(style: .grouped)
        case .custom(let customStyle):
            super.init(style: customStyle)
        }
        self.displayStyle = style
        self.title = title
        self.loadingClosure = loading
    }
    
    
    
    public init(data: FormDataSource,style: FormDisplayStyle) {
        switch style {
        case .modern:
            if #available(iOS 13.0, *) {
                super.init(style: .insetGrouped)
            } else {
                super.init(style: .grouped)
            }
        case .classic:
            super.init(style: .plain)
        case .classicGrouped:
            super.init(style: .grouped)
        case .custom(let customStyle):
            super.init(style: customStyle)
        }
        self.displayStyle = style
        self.title = data.title
        defer {
            self.dataSource = data
        }
        
    }
    
    
    public func setNewData(_ newData:FormDataSource) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
            guard let self = self else { return }
            let existingData = self.dataSource
            newData.updateClosure = existingData.updateClosure
            self.dataSource = newData
            self.refreshControl?.endRefreshing()
        }
    }
    
   

    // MARK: - Controller Base Initialize -
    private func controllerInitialize() { }
    
    // MARK: - setupUI -
    private func setupUI() {
        
        didLoad = true
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        
        switch displayStyle {
        case .modern:
            tableView.register(FormHeaderCell.self, forHeaderFooterViewReuseIdentifier: FormHeaderCell.identifier)
            tableView.register(FormHeaderCell.self, forHeaderFooterViewReuseIdentifier: FormHeaderCell.footerIdentifier)
            //tableView.contentInset = defaultContentInsets
        default:
            break
        }
        
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension

        //checkBarItems()
            
        if shouldRefresh {
            let refreshControl = UIRefreshControl()
            refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
            refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
        
        setupToolBar()
        
        if let _ = loadingClosure {
            tableView.tableFooterView = ItemsLoadingView(
                message: loadingMessage ?? "Loading",
                textStyle: .body,
                color: UIColor.FormKit.text
            )
        } else {
            if let loadingMessage = loadingMessage {
                tableView.tableFooterView = ItemsLoadingView(
                    message: loadingMessage,
                    textStyle: .body,
                    color: UIColor.FormKit.text
                )
            }
        }
        
        didLoad = true
        checkBarItems()
        //startNotificationCenterObservation()
    }
    
    
    @available(iOS 13.0, *)
    public func addBlurEffect(_ blurStyle: UIBlurEffect.Style = .systemThinMaterial) {
        self.tableView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.tableView.frame
        self.tableView.backgroundView = blurEffectView
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }

    
    private func _handleDataEvaluation(_ eval:FormDataSource.Evaluation) {
        
    }
    
    private func processEvaluationReloads(_ eval:FormDataSource.Evaluation, completionHandler: @escaping () -> Void) {
        
        
        guard let tv = self.tableView else {
            return
        }
        let ds = self.dataSource
        
        var hasReloaded = false
        
        eval.reloads.forEach({
            //print("Eval Reload Section: \($0.section)")
            
            if let sectionHeader = tv.headerView(forSection: $0.section) as? FormHeaderCell {
                if let formSection = ds.section(for: $0.section) {
                    sectionHeader.configureView(formSection.headerValue)
                }
            }
            //print(" - header finished")
            
            
            if let changes = $0.changes {
                //print(" - Changes: \(changes.count)")
                
                /*
                for change in changes {
                    if let replace = change.replace {
                        print("\(replace.index) Replace")
                    }
                    if let delete = change.delete {
                        print("\(delete.index) Delete")
                    }
                    if let insert = change.insert {
                        print("\(insert.index) Insert")
                    }
                    if let move = change.move {
                        print("\(move.fromIndex)->\(move.toIndex) Move")
                    }
                }
                */
                 
                if !changes.isEmpty {
                    //print(" - Reloading Changes")
                    hasReloaded = true
                    tv.reload(
                        changes: changes,
                        section: $0.section,
                        insertionAnimation: .fade,
                        deletionAnimation:  .fade,
                        replacementAnimation:  .fade,
                        updateData: {  },
                        completion: { _ in  completionHandler() }
                    )
                } else {
                    //print(" - No Changes")
                    //print(" - Change Operation Complete")
                }
            } else {
                //print(" - No Changes")
                //print(" - Change Operation Complete")
            }
            
        })
        
        
        if hasReloaded == false {
            completionHandler()
        }
        
        
    }
    
    
    
    
    
    private func handleDataEvaluation(_ eval:FormDataSource.Evaluation) {
        
        guard isEvaluating == false else {
            return
        }
        
        isEvaluating = true
        
        if eval.isReloadsOnly {
            processEvaluationReloads(eval, completionHandler: { [weak self] in
                self?.isEvaluating = false
            })
        } else {
            tableView.performBatchUpdates {
                
                if let sections = eval.sets.insert {
                    tableView.insertSections(sections, with: .fade)
                }
                
                if let sections = eval.sets.delete {
                    tableView.deleteSections(sections, with: .fade)
                }
                
                if let sections = eval.sets.reload {
                    tableView.reloadSections(sections, with: .fade)
                }
                
            }
        }
        
        isEvaluating = false
        
    }
    

    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        if didLoad == false {
            setupUI()
        }
        
        
        addKeyboardListeners()
        contentSizeObserver = tableView.observe(\.contentSize) { [weak self] tv, _ in
            guard let self = self else { return }
        
            let newContentSize = CGSize(width: tv.contentSize.width + tv.contentInset.left + tv.contentInset.right,
                   height: tv.contentSize.height + tv.contentInset.top + tv.contentInset.bottom)
           
           
           //
            
    
            if newContentSize.height < self.preferredContentSize.height {
                // ignore
            } else {
                
                if self.preferredContentSize.height != newContentSize.height {
                    self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: newContentSize.height)
                    self.view.setNeedsLayout()
                }
                
               
            }
            
        }
        
        
    }
    
    
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("[FormKit] (FormController) viewWillAppear")
        
        if toolbarItems != nil {
            self.navigationController?.setToolbarHidden(false, animated: false)
        } else {
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
        if didLoad == false {
            setupUI()
        }
        
        
    }
    
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
        contentSizeObserver?.invalidate()
        contentSizeObserver = nil
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("[FormKit] (FormController) viewDidAppear")
        
        if loadingClosureCalled == false {
            loadingClosureCalled = true
            loadingClosure?(self)
        }
        
        checkBarItems()
        checkForActiveInput()
        checkActiveIndexPath()
        runValidation()
    }
    
    
    
    // MARK: - Notification -

    public func setNotificationObservation(_ name:String,notificationClosure: @escaping NotificationClosure) {
        self.notificationName = Notification.Name(name)
        self.notificationHandler = notificationClosure
        startNotificationCenterObservation()
    }
    
    public func setNotificationObservation(_ notificationName:Notification.Name,notificationClosure: @escaping NotificationClosure) {
        self.notificationName = notificationName
        self.notificationHandler = notificationClosure
        startNotificationCenterObservation()
    }
    
    
    @objc func handleNotification(_ notification:Notification) {
        notificationHandler?(self,notification)
    }
    
    
    private func startNotificationCenterObservation() {
        guard let notificationName = notificationName,notificationSet == false else { return }
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotification(_:)),
            name: notificationName,
            object: nil
        )
        notificationSet = true
    }
    
    
    private func addKeyboardListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func keyboardWillShow() {
        keyboardIsShowing = true
    }
    
    @objc private func keyboardWillHide() {
        keyboardIsShowing = false
    }
    
    private func itemsToReload(new:[FormDataSource.InvalidItem]) -> [FormDataSource.InvalidItem] {
        
        var reload: [FormDataSource.InvalidItem] = []
        
        for oldItem in lastInvalidItems {
            if new.containsItem(oldItem) == false {
                // Item is now validated.
                reload.append(oldItem)
            }
        }
        
        for newItem in new {
            if lastInvalidItems.containsItem(newItem) == false {
                // Item is newly invalid.
                reload.append(newItem)
            }
        }
        
        lastInvalidItems = new
        return reload
        
    }
    
    
    private func runValidation() {
        guard validationClosure == nil else {
            legacyValidation()
            return
        }
        
        setLastSection(dataSource.isValid)
    }
    
    
    private func legacyValidation() {
        if !dataSource.isEmpty {
            validationClosure?(dataSource,self)
        }
    }
    
    
    private func setLastSection(_ enabled:Bool) {
        if let lastSection = dataSource.lastSection {
            let sectionIdx = dataSource.lastSectionIdx
            
            /*
            var update = false
            
            if lastSection.isValid {
                if enabled == false {
                    update = true
                }
            } else {
                if enabled {
                    update = true
                }
            }
            
            
            guard update else {
                print("[FormKit] No need to update last section")
                return
            }
            */
            
            for (i,formItem) in lastSection.rows.enumerated() {
                if let actionValue = formItem.asActionValue() {
                    updateActionValue(
                        enabled ? actionValue.enabled() : actionValue.disabled(),
                        at: IndexPath(row: i, section: sectionIdx)
                    )
                }
            }
            
        }
    }
    
    
    
    private func checkActiveIndexPath() {
        guard activeIndexPath == nil else {
            if let activePath = activeIndexPath {
                if let activeCell = tableView.cellForRow(at: activePath) {
                    if let activatabelCell = activeCell as? Activatable {
                        activatabelCell.activate()
                    }
                }
            }
            return
        }
    }
    
    
    private func checkForActiveInput() {
        guard hasActivated == false else { return }
        
        if activatesInputOnAppear {
            if let firstInputPath = dataSource.firstInputIndexPath {
                if let nextCell = tableView.cellForRow(at: firstInputPath) {
                    if let activatabelCell = nextCell as? Activatable {
                        activatabelCell.activate()
                        hasActivated = true
                    }
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
    
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let preview = previewItem else {
            return FKPreview("Error",URL(string: "")!)
        }
        return preview
    }
    
    public func setPreviewController(_ previewController:QLPreviewController) {
        self.previewController = previewController
    }
    
    public func showPreview(_ url:URL,_ title:String? = nil) {
        if previewController == nil {
            previewController = QLPreviewController()
        }
        
        previewController!.dataSource = self
        previewItem = FKPreview(title ?? "", url)
        navigationController?.pushViewController(previewController!, animated: true)
    }
    
    
    public func addFormValue(_ formValue:FormValue,toTopOf section:Int,_ title:String? = nil) {
        
        guard !dataSource.isEmpty else {
            return
        }
        
        dataSource.sections[section].rows.insert(formValue.formItem, at: 0)
        
        if let title = title {
            var headerValue = dataSource.sections[0].headerValue
            headerValue.title = title
            
            if let headerView = tableView.headerView(forSection: 0) as? FormHeaderCell  {
                headerView.headerValue = headerValue
            }
        }
        
        tableView.insertRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
    }

    
}



extension FormController {
    open override var description: String {
        """
        
        FormController: '\(title ?? "-")'
        Data: \(dataSource.params)
        Parent: \("\(String(describing: parent))" )
        
        """
    }
}


/*
@available(iOS 13.0, *)
extension FormController {
    
    public func setContextMenuClosure(_ closure: @escaping ContextMenuClosure) {
        self.contextMenuClosure = closure
        self.usesContextMenus = true
    }
    
}
*/


// MARK: - BarItem -
extension FormController {
    
    private func checkBarItems() {
        
         var leading:[UIBarButtonItem] = []
         for (i,item) in leadingBarItems.enumerated() {
             switch i {
             case 0:
                 leading.append(
                     item.barButtonItem(target: self, selector: #selector(firstLeadingBarItem) )
                 )
             case 1:
                 leading.append(
                     item.barButtonItem(target: self, selector: #selector(secondLeadingBarItem) )
                 )
             case 2:
                 leading.append(
                     item.barButtonItem(target: self, selector: #selector(thirdLeadingBarItem) )
                 )
             default:
                 print("Error too many `leading` BarItems.")
             }
         }
         
        
         
         var trailing:[UIBarButtonItem] = []
         for (i,item) in trailingBarItems.enumerated() {
             switch i {
             case 0:
                 trailing.append(
                     item.barButtonItem(target: self, selector: #selector(firstTrailingBarItem) )
                 )
             case 1:
                 trailing.append(
                     item.barButtonItem(target: self, selector: #selector(secondTrailingBarItem) )
                 )
             case 2:
                 trailing.append(
                     item.barButtonItem(target: self, selector: #selector(thirdTrailingBarItem) )
                 )
             default:
                 print("Error too many `trailing` BarItems.")
             }
         }
        
        navigationItem.setLeftBarButtonItems(leading, animated: true)
        navigationItem.setRightBarButtonItems(trailing, animated: true)
    }
    
    
    
    
    public func resetLoadingBarItem(_ withDelay:TimeInterval? = nil) {
        
        guard let currentBarItem = currentInPlaceBarItem,let currentBarButtonItem = currentInPlaceBarButtonItem else {
            return
        }
        
        if let result = getBarButtonItemFor(currentBarItem) {
            switch currentBarItem.side {
            case .leading:
                if let delay = withDelay {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                        guard let self = self else { return }
                        if result.index == 0 {
                            self.navigationItem.setLeftBarButtonItems([currentBarButtonItem], animated: true)
                        } else {
                            var newItems:[UIBarButtonItem] = []
                            if let items = self.navigationItem.leftBarButtonItems {
                                for (i,item) in items.enumerated() {
                                    if i != result.index {
                                        newItems.append(item)
                                    } else {
                                        newItems.append(currentBarButtonItem)
                                    }
                                }
                            }
                            self.navigationItem.setLeftBarButtonItems(newItems, animated: true)
                        }
                        self.currentInPlaceBarButtonItem = nil
                    }
                } else {
                    if result.index == 0 {
                        navigationItem.setLeftBarButtonItems([currentBarButtonItem], animated: true)
                    } else {
                        var newItems:[UIBarButtonItem] = []
                        if let items = navigationItem.leftBarButtonItems {
                            for (i,item) in items.enumerated() {
                                if i != result.index {
                                    newItems.append(item)
                                } else {
                                    newItems.append(currentBarButtonItem)
                                }
                            }
                        }
                        navigationItem.setLeftBarButtonItems(newItems, animated: true)
                    }
                    currentInPlaceBarButtonItem = nil
                }
            case .trailing:
               if let delay = withDelay {
                   DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                       guard let self = self else { return }
                       if result.index == 0 {
                           self.navigationItem.setRightBarButtonItems([currentBarButtonItem], animated: true)
                       } else {
                           var newItems:[UIBarButtonItem] = []
                           if let items = self.navigationItem.rightBarButtonItems {
                               for (i,item) in items.enumerated() {
                                   if i != result.index {
                                       newItems.append(item)
                                   } else {
                                       newItems.append(currentBarButtonItem)
                                   }
                               }
                           }
                           self.navigationItem.setRightBarButtonItems(newItems, animated: true)
                       }
                       self.currentInPlaceBarButtonItem = nil
                   }
               } else {
                   if result.index == 0 {
                       navigationItem.setRightBarButtonItems([currentBarButtonItem], animated: true)
                   } else {
                       var newItems:[UIBarButtonItem] = []
                       if let items = navigationItem.rightBarButtonItems {
                           for (i,item) in items.enumerated() {
                               if i != result.index {
                                   newItems.append(item)
                               } else {
                                   newItems.append(currentBarButtonItem)
                               }
                           }
                       }
                       navigationItem.setRightBarButtonItems(newItems, animated: true)
                   }
                   currentInPlaceBarButtonItem = nil
               }
            }
        }
        
    }
    
    
    
    public func setBarItemLoading(_ barItem:BarItem) {
        
        if let result = getBarButtonItemFor(barItem) {
            
            currentInPlaceBarButtonItem = result.barButtonItem
            currentInPlaceBarItem = barItem
            
            let activityIndicator = UIActivityIndicatorView(style: .white)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor, multiplier: 1.0).isActive = true
            activityIndicator.startAnimating()
            let loading = UIBarButtonItem(customView: activityIndicator)
            
           
            
            switch barItem.side {
            case .leading:
                if result.index == 0 {
                    navigationItem.setLeftBarButtonItems([loading], animated: true)
                } else {
                    var newItems:[UIBarButtonItem] = []
                    if let items = navigationItem.leftBarButtonItems {
                        for (i,item) in items.enumerated() {
                            if i != result.index {
                                newItems.append(item)
                            } else {
                                newItems.append(loading)
                            }
                        }
                    }
                    navigationItem.setLeftBarButtonItems(newItems, animated: true)
                }
            case .trailing:
                if result.index == 0 {
                    navigationItem.setRightBarButtonItems([loading], animated: true)
                } else {
                    var newItems:[UIBarButtonItem] = []
                    if let items = navigationItem.rightBarButtonItems {
                        for (i,item) in items.enumerated() {
                            if i != result.index {
                                newItems.append(item)
                            } else {
                                newItems.append(loading)
                            }
                        }
                    }
                    navigationItem.setRightBarButtonItems(newItems, animated: true)
                }
                
            }
            
            
            
        }
        
        
        
    }
    
    
    
    private func getBarButtonItemFor(_ barItem:BarItem) -> (barButtonItem:UIBarButtonItem,index:Int)? {
        switch barItem.side {
        case .leading:
            if let index = leadingBarItems.indexOf(barItem) {
                if let items = navigationItem.leftBarButtonItems {
                    return (items[index],index)
                }
            }
            break
        case .trailing:
            if let index = trailingBarItems.indexOf(barItem) {
                if let items = navigationItem.rightBarButtonItems {
                    return (items[index],index)
                }
            }
            break
        }
        return nil
    }
    
    public func setBarItems(_ items:[BarItem]) {
        let existingBarItems = self.barItems
        var newItems:[BarItem] = []
        for item in items {
            if !existingBarItems.containsItem(item) {
                newItems.append(item)
            }
        }
        self.barItems.append(contentsOf: newItems)
    }
    
    
    // MARK: - addBarItem -
    public func addBarItem(_ barItem:BarItem) {
       appendBarItem(barItem)
    }
    
    
    private func appendBarItem(_ barItem:BarItem) {
        switch barItem.side {
        case .leading:
            let newPosition = leadingBarItems.count + 1
            switch newPosition {
            case 0:
                let barButtonItem = barItem.barButtonItem(target: self, selector: #selector(firstTrailingBarItem))
                navigationItem.setLeftBarButton(barButtonItem, animated: true)
            case 1:
                let barButtonItem = barItem.barButtonItem(target: self, selector: #selector(secondTrailingBarItem))
                let newItems = [ (navigationItem.leftBarButtonItems ?? []), [barButtonItem] ].reduce([],+)
                navigationItem.setLeftBarButtonItems(newItems, animated: true)
            case 2:
                let barButtonItem = barItem.barButtonItem(target: self, selector: #selector(thirdTrailingBarItem))
                let newItems = [ (navigationItem.leftBarButtonItems ?? []), [barButtonItem] ].reduce([],+)
                navigationItem.setLeftBarButtonItems(newItems, animated: true)
            default:
                print("Error too many `trailing` BarItems.")
            }
        case .trailing:
            let newPosition = trailingBarItems.count + 1
            switch newPosition {
            case 0:
                let barButtonItem = barItem.barButtonItem(target: self, selector: #selector(firstTrailingBarItem))
                navigationItem.setRightBarButton(barButtonItem, animated: true)
            case 1:
                let barButtonItem = barItem.barButtonItem(target: self, selector: #selector(secondTrailingBarItem))
                let newItems = [ (navigationItem.rightBarButtonItems ?? []), [barButtonItem] ].reduce([],+)
                navigationItem.setRightBarButtonItems(newItems, animated: true)
            case 2:
                let barButtonItem = barItem.barButtonItem(target: self, selector: #selector(thirdTrailingBarItem))
                let newItems = [ (navigationItem.rightBarButtonItems ?? []), [barButtonItem] ].reduce([],+)
                navigationItem.setRightBarButtonItems(newItems, animated: true)
            default:
                print("Error too many `trailing` BarItems.")
            }
            
        }
        
        barItems.append(barItem)
    }

    
    
    
    @objc
    private func firstLeadingBarItem() {
        guard leadingBarItems.count > 0 else { return }
        leadingBarItems[0].action?(self,leadingBarItems[0])
    }
    
    @objc
    private func secondLeadingBarItem() {
        guard leadingBarItems.count > 1 else { return }
        leadingBarItems[1].action?(self,leadingBarItems[1])
    }
    
    @objc
    private func thirdLeadingBarItem() {
        guard leadingBarItems.count > 2 else { return }
        leadingBarItems[2].action?(self,leadingBarItems[2])
    }
    
    
    @objc
    private func firstTrailingBarItem() {
        guard trailingBarItems.count > 0 else { return }
        trailingBarItems[0].action?(self,trailingBarItems[0])
    }
    
    @objc
    private func secondTrailingBarItem() {
        guard trailingBarItems.count > 1 else { return }
        trailingBarItems[1].action?(self,trailingBarItems[1])
    }
    
    @objc
    private func thirdTrailingBarItem() {
        guard trailingBarItems.count > 2 else { return }
        trailingBarItems[2].action?(self,trailingBarItems[2])
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
        closeController()
    }
    
    @objc
    func donePressed(){
        closeController()
    }
    
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        
        refreshControl.beginRefreshing()
        
        if let closure = loadingClosure {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {  [weak self] in
                guard let self = self else { return }
                self.generateHapticFeedback(.mediumImpact)
                closure(self)
                self.refreshControl?.endRefreshing()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  [weak self] in
                guard let self = self else { return }
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    public func reloadRefresh() {
        if let closure = loadingClosure {
            closure(self)
        }
    }
    
}


extension FormController {
    

    
    private func closeController() {
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            self.dismissalClosure?()
            self.closeClosure?(self)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    public func end() {
        closeController()
    }
    
    public func close() {
        closeController()
    }
    
    
}
    



// MARK: - TableView -
extension FormController {
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }
    
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.style == .plain || tableView.style == .grouped && !displayStyle.isModern() {
            return dataSource.sectionTitle(at: section)
        } else {
            return nil
        }
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let formSection = dataSource.sections[section]
        return (formSection.headerValue.state == .collapsed) ? 0 : formSection.rows.count
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
        
        var shouldHighlight = true
        
        if let formItem = dataSource.itemAt(indexPath) {
            if let selectableFormItem = formItem as? TableViewSelectable {
                shouldHighlight = selectableFormItem.isSelectable
            }
        }
        
        return shouldHighlight
    }
    
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        if keyboardIsShowing {
            if let firstResponder = view.window?.firstResponder {
                if let containingCell = firstResponder.superview?.superview?.superview?.superview as? UITableViewCell {
                    if let containingCellPath = tableView.indexPath(for: containingCell) {
                        activeIndexPath = containingCellPath
                    }
                }
            }
            self.tableView.endEditing(true)
        } else {
            activeIndexPath = nil
        }
        
        if let item = dataSource.itemAt(indexPath) {
            item.cellDescriptor.didSelect(self,indexPath)
        }
        
        dataSource.lastPath = (indexPath.row,indexPath.section)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard displayStyle.isModern() else {
            return nil
        }
        
        
        if !dataSource.sections[section].title.isEmpty {
            if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: FormHeaderCell.identifier) as? FormHeaderCell {
                headerCell.configureView(headers[section])
                headerCell.delegate = self
                return headerCell
            }
        }
        
        return nil
    }
    
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard displayStyle.isModern() else {
            return nil
        }
        
        if let footer = footers.filter({ $0.section == section }).first {
            if let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: FormHeaderCell.footerIdentifier) as? FormHeaderCell {
                footerCell.configureView(footer)
                //footerCell.delegate = self
                return footerCell
            }
        }
        
        
        return nil
        
    }

    
//    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//        if !dataSource.sections[section].title.isEmpty {
//            return 0
//        } else {
//            return UITableView.automaticDimension
//        }
//
////        if dataSource.sections[section].title.isEmpty {
////            return 0
////        } else {
////            return UITableView.automaticDimension
////        }
//    }
    
    
    open override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
    
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dataSource.yOffset = scrollView.contentOffset.y
        //let yOffset = scrollView.contentOffset.y
        
    }
    

    override open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}



// MARK: - ValidationStatus -
extension FormController {
    
    
    public enum ValidationStatus {
        case enabled, disabled
    }
    
    
    public func setValidationStatus(_ status:ValidationStatus, at path:IndexPath) -> Bool {
        var success = false
        if let actionValue = actionValueAt(path) {
            switch status {
            case .enabled:
                let newValue = actionValue.enabled()
                updateActionValue(newValue, at: path)
                success = true
            case .disabled:
                let newValue = actionValue.disabled()
                updateActionValue(newValue, at: path)
                success = true
            }
        }
        return success
    }
    
    
    public func validationStatus(for path:IndexPath) -> ValidationStatus? {
        if let actionValue = actionValueAt(path) {
            if actionValue.isValid() {
                return .enabled
            } else {
                return .disabled
            }
        }
        return nil
    }
    
    
}



// MARK: - UISwipeActions -

extension FormController {

    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if usesSwipeAction == true {
            if let _ = dataSource.itemAt(indexPath) {
                if #available(iOS 13.0, *) {
                    let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
                    return UISwipeActionsConfiguration(actions: [deleteAction])
                }
            }
        }
        
        return nil
        
    }
    
}

// MARK: - UIContextMenu -


@available(iOS 13.0, *)
extension FormController {
    
    open override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let formItem = dataSource.itemAt(indexPath) else {
            return nil
        }

        
        if usesContextMenus {
            
            // TODO...
            
            
        } else {
            
            if let customValue = formItem.asCustomValue() {
                
                if customValue.shouldShowCopyMenu {
                    let copyMenu = UIMenu(title: "", children: [makeCopyUIAction(customValue.contentValue)])
                    return UIContextMenuConfiguration(
                        identifier: nil,
                        previewProvider: nil,
                        actionProvider: { suggestedActions in
                            return copyMenu
                    })
                }
                
                
            }
            
        }
        
        return nil
        
        }
    
}


@available(iOS 13.0, *)
extension FormController {
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        //generateHapticFeedback(.success)
        
        // 2
        let action =  UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, handler:(Bool) -> Void) in
            guard let self = self else { return }
            
            if self.dataSource.sections[indexPath.section].rows.count == 1 {
                // Delete the Section
                let removedSection = self.dataSource.sections.remove(at: indexPath.section)
                if let removedItem = removedSection.firstRow {
                    self.destructiveSwipeAction?(self,removedItem,indexPath)
                }
                self.tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section) , with: .fade)
            } else {
                let removedItem = self.dataSource.sections[indexPath.section].rows.remove(at: indexPath.row)
                self.destructiveSwipeAction?(self,removedItem,indexPath)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            /*
            self.dataSource.lastPath = (indexPath.row,indexPath.section)
            let r = self.tableView.rect(forSection: indexPath.section)
            self.dataSource.lastRect = (
                Double(r.origin.x),
                Double(r.origin.y),
                Double(r.size.width),
                Double(r.size.height)
            )
            */
            
            self.generateHapticFeedback(.impact)
            handler(true)
        }
        
        //
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = .systemRed
        
        return action
    }
    
    
    private func contextualCopyAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action =  UIContextualAction(style: .normal, title: "Copy") { [weak self] (action, view, handler:(Bool) -> Void) in
            guard let self = self else { return }
            
            if let formItem = self.dataSource.itemAt(indexPath) {
                UIPasteboard.general.string = formItem.copyValue
            }
            
            self.generateHapticFeedback(.impact)
            handler(true)
        }
        
        //
        action.image = UIImage(systemName: "doc.on.doc")
        action.backgroundColor = .systemBlue
        
        return action
    }
    
    
    private func makeCopyContextMenu(_ formItem:FormItem,_ indexPath: IndexPath) -> UIMenu {
        
        
        let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { action in
            // Show system share sheet
            UIPasteboard.general.string = formItem.copyValue
            
        }
        
        // Create our menu with both the edit menu and the share action
        return UIMenu(title: "", children: [copy])
    }
    
    
    private func makeCopyUIAction(_ text:String) -> UIAction {
        UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { action in
            // Show system share sheet
            UIPasteboard.general.string = text
        }
    }
    
    
    
    // MARK: - Context Menu -
    func makeContextMenu(_ formItem:FormItem,_ indexPath: IndexPath) -> UIMenu? {
        return nil
        //contextMenuClosure(self,formItem,indexPath)
        
        /*
        if let providedContextMenu = contextMenuClosure(self,formItem,indexPath) {
            return providedContextMenu
        }
        
        let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
            // Show system share sheet
            
        }
        
        // Create our menu with both the edit menu and the share action
        return UIMenu(title: "", children: [share])
        */
    }
        
    
}



extension FormController {
    
    public func params() -> [String:String] {
        return dataSource.activeParams
    }
    
}


// MARK: - Update/Invalidation -

extension FormController {
    
    // MARK: - DatePickerValue -
    
    /*
    public func invalidateDatePickerValue(_ value:DatePickerValue, at path:IndexPath) {
        
    }
    
    
    public func validateDatePickerValue(_ value:DatePickerValue, at path:IndexPath) {
        
    }
    */
    
    
    public func setNewDatePickerValue(_ value:DatePickerValue, at path:IndexPath) {
        dataSource.updateWith(formValue: value, at: path)
        if let cell = tableView.cellForRow(at: path) as? DatePickerValueCell {
            cell.setNewDatePickerValue(value)
        }
    }
    
    
    
    // MARK: - TimeInputValue -
    
    public func setNewTimeInputValue(_ value:TimeInputValue, at path:IndexPath) {
        dataSource.updateWith(formValue: value, at: path)
        if let cell = tableView.cellForRow(at: path) as? TimeInputCell {
            cell.setTimeInputValue(value)
        }
    }
    
    
}


// MARK: - ExpandingCellDelegate -

protocol ExpandingCellDelegate: UIViewController {
    func cellNeedsToExpand(at path:IndexPath)
}


extension FormController: ExpandingCellDelegate {
    func cellNeedsToExpand(at path: IndexPath) {
        if let _ = tableView.cellForRow(at: path) {
            tableView.reloadRows(at: [path], with: .automatic)
            
            /*
            UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
                self.tableView.beginUpdates()
                cell.contentView.layoutSubviews()
                self.tableView.endUpdates()
            }.startAnimation()
            */
        }
    }
    
    
    
    
    func cellNeedsToExpand(closure: () -> Void) {
        tableView.beginUpdates()
        closure()
        tableView.endUpdates()
    }
    
}



// MARK: - Update FormSection -
extension FormController {
    
    private func actionValueAt(_ path:IndexPath) -> ActionValue? {
        if let section = dataSource.section(for: path.section) {
            if let formValue = section.itemForRowAt(path.row) {
                switch formValue {
                case .action(let actionValue):
                    return actionValue
                default:
                    break
                }
            }
        }
        return nil
    }
    
    
    
    
    public func update(_ value:ActionValue,_ withDelay:TimeInterval? = nil) {
        
        if let delay = withDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                if let actionValuePath = self.dataSource.pathForActionValue(value) {
                    self.dataSource.sections[actionValuePath.section].rows[actionValuePath.row] = value.formItem
                    
                    if let _ = self.tableView.cellForRow(at: actionValuePath) {
                        self.tableView.reloadRows(at: [actionValuePath], with: .fade)
                    }
                } else {
                    print("Error finding ActionValue \(value)")
                }
            }
        } else {
            DispatchQueue.main.async(execute: { [weak self] in
                guard let self = self else { return }
                if let actionValuePath = self.dataSource.pathForActionValue(value) {
                    self.dataSource.sections[actionValuePath.section].rows[actionValuePath.row] = value.formItem
                    
                    if let _ = self.tableView.cellForRow(at: actionValuePath) {
                        self.tableView.reloadRows(at: [actionValuePath], with: .fade)
                    }
                } else {
                    print("Error finding ActionValue \(value)")
                }
            })
        }
    }
    
    
    
    
    
    
    
    
    
    public func updateActionValue(_ value:ActionValue, at path:IndexPath) {
        
        if let section = dataSource.section(for: path.section) {
            if let formItem = section.itemForRowAt(path.row) {
                
                switch formItem {
                case .action(let actionValue):
                    if value.state != actionValue.state {
                        
                        if section.rows.count > 1 {
                            if path.row == 0 {
                                let newItems:[FormItem] = [.action(value),section.lastRow].compactMap({ $0 })
                                dataSource.sections[path.section] = FormSection(newItems)
                            } else {
                                let newItems:[FormItem] = [section.firstRow,.action(value)].compactMap({ $0 })
                                dataSource.sections[path.section] = FormSection(newItems)
                            }
                        } else {
                            dataSource.sections[path.section] = FormSection(section.title, value)
                            if tableView.numberOfSections-1 >= path.section {
                                tableView.reloadRows(at: [path], with: .none)
                            }
                        }
                    }
                default:
                    dataSource.sections[path.section] = FormSection([value])
                    break
                }
            }
        }

    }
    
    
    public func updateValue(_ formValue:FormValue, at path:IndexPath,_ animated:Bool = true) {
        if let section = dataSource.section(for: path.section) {
            if let _ = section.itemForRowAt(path.row) {
                dataSource.sections[path.section].rows[path.row] = formValue.formItem
                if animated {
                    tableView.reloadRows(at: [path], with: .fade)
                } else {
                    tableView.reloadRows(at: [path], with: .none)
                }
            }
        }
    }
    
    
    public func updateSection(_ newSection:FormSection, at path:IndexPath,_ activateInputs:Bool = true,_ animated:Bool = true) {
        self.update(newSection, path: path, activateInputs: activateInputs, preservingTitle: false, animated)
    }
    
    public func reloadSection(_ newSection:FormSection, at path:IndexPath, preservingTitle:Bool,_ activateInputs:Bool = true,_ animated:Bool = true) {
        self.update(newSection, path: path, activateInputs: activateInputs, preservingTitle: preservingTitle, animated)
    }
    
    public func reloadSection(_ newSection:FormSection, at path:IndexPath, _ animated:Bool = true) {
        self.update(newSection, path: path, activateInputs: true, preservingTitle: true, animated)
    }
    
    
    // Update
    private func update(_ newSection:FormSection, path:IndexPath, activateInputs:Bool = true, preservingTitle:Bool, _ animated:Bool = true) {
        // Title
        var section = newSection
        
        if preservingTitle {
            section = FormSection(dataSource.sections[path.section].title, newSection.rows)
            section.setHeaderValue(newSection.headerValue)
            section.updateClosure = newSection.updateClosure
        }
        
        dataSource.sections[path.section] = section
        
        if animated {
            tableView.reloadSections(IndexSet(integer: path.section), with: .automatic)
        } else {
            tableView.reloadSections(IndexSet(integer: path.section), with: .none)
        }
        
        guard activateInputs else {
            return
        }
        /// Check for Inputs and Activate them
        if let inputRow = section.firstInputRow {
            let firstInputPath = IndexPath(row: inputRow, section: path.section)
            if let nextCell = tableView.cellForRow(at: firstInputPath) {
                if let activatabelCell = nextCell as? Activatable {
                    activatabelCell.activate()
                }
            }
        }
    }
    
    
    
    public func updateSections(_ newSections:[FormSection]) {
        setNewData(dataSource.newWith(newSections))
    }
    
    
    
    
    
    
    // MARK: - ListItem Update -
    public func addListItemsToListSelectValues(_ listItemsData:[String:ListItem]) {
        
        var vals:[(IndexPath,FormItem)] = []
        
        for (key,newListItem) in listItemsData {
            if let lsv = dataSource.getListSelectionValueForKey(key) {
                var existingList = lsv.0
                existingList.addListItem(newListItem)
                vals.append((lsv.1, existingList.formItem))
            }
        }
        
        for item in vals {
            dataSource.sections[item.0.section].rows[item.0.row] = item.1
        }
        
        tableView.reloadRows(at: vals.map({ $0.0 }), with: .none)
    }
    
    
    
    public func addListItems(_ listItems:[ListItem],withKeys keys:[String]) {
        var listItemsData:[String:ListItem] = [:]
        
        for value in zip(listItems, keys) {
            listItemsData.updateValue(value.0, forKey: value.1)
        }
        
        addListItemsData(listItemsData)
    }
    
    
    public func addListItem(_ listItem:ListItem,toListSelectionWithKey key:String) {
        addListItemsData([key:listItem])
    }
    
    
    public func addListItemsWithData(_ data:[String:ListItem],_ insertAtTop:Bool = false) {
        addListItemsData(data,insertAtTop)
    }
    
    
    private func addListItemsData(_ data:[String:ListItem],_ insertAtTop:Bool = false) {
        
        var vals:[(IndexPath,FormItem)] = []
        
        for (key,newListItem) in data {
            
            if let lsv = dataSource.getListSelectionValueForKey(key) {
                
                //print("List Item: \(lsv)")
                
                
                var existingList = lsv.0
                
                if insertAtTop {
                    existingList.listItems.insert(newListItem, at: 0)
                    
                    for (i,_) in existingList.listItemStores.enumerated() {
                        var store = existingList.listItemStores[i]
                        store.listItems.insert(newListItem, at: 0)
                        let newlistItemStore = store.newWithSelectedIndicies([0])
                        existingList.listItemStores[i] = newlistItemStore
                    }
                } else {
                    let newItems = [[newListItem],existingList.listItems.unselected()]
                        .reduce([],+)
                        .sorted { (a, b) -> Bool in
                        a.title < b.title
                    }
                    
                    var newIndex = 0
                    for (i,listItem) in newItems.enumerated() {
                        if listItem.title == newListItem.title {
                            newIndex = i
                        }
                    }
                    
                    existingList.listItems = newItems
                    existingList.selectedIndicies = [newIndex]
                    
                    for (i,_) in existingList.listItemStores.enumerated() {
                        
                        var store = existingList.listItemStores[i]
                        let existingListItems = store.listItems.unselected()
                        
                        let newItems = [[newListItem],existingListItems]
                            .reduce([],+)
                            .sorted { (a, b) -> Bool in
                            a.title < b.title
                        }
                        var newIndex = 0
                        for (i,listItem) in newItems.enumerated() {
                            if listItem.title == newListItem.title {
                                newIndex = i
                            }
                        }
                        
                        store.listItems = newItems
                        let newlistItemStore = store.newWithSelectedIndicies([newIndex])
                        existingList.listItemStores[i] = newlistItemStore
                    }
                }
                
                vals.append((lsv.1, existingList.formItem))
            } else {
                print("[FormKit] unable to find `ListSelectionValue` for key: '\(key)'")
            }
            
        }
        
        
        for item in vals {
            dataSource.sections[item.0.section].rows[item.0.row] = item.1
        }
        
        tableView.reloadRows(at: vals.map({ $0.0 }), with: .none)
    }
    
    
    public func addFormItems(_ formItems:[FormItem],toBottomOfSection section:Int) {
        //let existingRowCount = tableView.numberOfRows(inSection: section)
        //let newRow = tableView.numberOfRows(inSection: section)
        
        guard !formItems.isEmpty else { return }

        var paths:[IndexPath] = []
        var row = tableView.numberOfRows(inSection: section)
        for formItem in formItems {
            dataSource.sections[section].rows.append(formItem)
            paths.append(
                IndexPath(row: row, section: section)
            )
            row += 1
        }
        
        tableView.insertRows(at: paths, with: .top)
    }
    
    
    
    public func addFormItem(_ formItem:FormItem,toBottomOfSection section:Int) {
        let newRow = tableView.numberOfRows(inSection: section)
        dataSource.sections[section].rows.append(formItem)
        tableView.insertRows(at: [IndexPath(row: newRow, section: section)], with: .automatic)
    }
    
    
    public func addFormItem(_ formItem:FormItem,secondToLastInSection section:Int) {
        let numRows = tableView.numberOfRows(inSection: section)
        if let lastRow = dataSource.sections[section].rows.popLast() {
            tableView.deleteRows(at: [IndexPath(row: numRows-1, section: section)], with: .fade)
            dataSource.sections[section].rows.append(formItem)
            dataSource.sections[section].rows.append(lastRow)
            tableView.insertRows(at: [IndexPath(row: numRows-1, section: section),IndexPath(row: numRows, section: section)], with: .fade)
        }
        
       
    }
    
    /*
    public func addFormValue(_ formValue:FormValue,toTopOf section:Int,_ title:String? = nil) {
        
        guard !dataSource.isEmpty else {
            return
        }
        
        dataSource.sections[section].rows.insert(formValue.formItem, at: 0)
        
        if let title = title {
            var headerValue = dataSource.sections[0].headerValue
            headerValue.title = title
            
            if let headerView = tableView.headerView(forSection: 0) as? FormHeaderCell  {
                headerView.headerValue = headerValue
            }
        }
        
        tableView.insertRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
    }
    */
     
    public func addFormValues(_ formValues:[FormValue],toTopOf section:Int) {
        var paths:[IndexPath] = []
        var row = 0
        for formValue in formValues {
            paths.append(
                IndexPath(row: row, section: section)
            )
            dataSource.sections[section].rows.insert(formValue.formItem, at: 0)
            row += 1
        }
        tableView.insertRows(at: paths, with: .automatic)
    }
    
    
    public func addFormItem(_ formItem:FormItem,toTopOf section:Int) {
        dataSource.sections[section].rows.insert(formItem, at: 0)
        
       
        
        
        tableView.insertRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
    }
    
    
    
}



extension FormController {
    
    private func handleActionCellChanging(enabled:Bool) {
        for cell in tableView.visibleCells {
            if let actionCell = cell as? ActionCell {
                if enabled {
                    actionCell.setEnabled()
                } else {
                    actionCell.setDisabled()
                }
            }
        }
    }
    
    
    private func handleActionCellChanging(for rows:[IndexPath],enabled:Bool) {
        
        if let visiblePaths = tableView.indexPathsForVisibleRows {
            for row in rows {
                if visiblePaths.contains(row) {
                    if let actionCell = tableView.cellForRow(at: row) as? ActionCell {
                        enabled ? actionCell.setEnabled() : actionCell.setDisabled()
                    }
                }
            }
        }
    }
    
    
    
    
    public func changeLastSection(_ newSection:FormSection,_ activate:Bool = false) {
        
       
        changeSection(newSection, at: IndexPath(row: 0, section: dataSource.sections.count-1),activate,.fade)
    }
    
    
    
    public func changeSecondToLastSection(_ newSection:FormSection,_ activate:Bool = false) {
        let secondToLastSection = dataSource.sections.count-2
        guard secondToLastSection >= 0 else {
            return
        }
        
        changeSection(newSection, at: IndexPath(row: 0, section: dataSource.sections.count-2),activate)
    }
    
    
    
    public func changeFirstSection(_ newSection:FormSection,_ activate:Bool = false) {
        changeSection(newSection, at: IndexPath(row: 0, section: 0),activate)
    }
    
    
    public func changeSection(_ newSection:FormSection,at path:IndexPath,_ activate:Bool = false,_ animation:UITableView.RowAnimation = .none) {
        guard !dataSource.sections.isEmpty else { return }
        _changeSection(newSection,at: path, activateInput: activate, animation)
    }
    
    
    private func _changeSection(_ newSection:FormSection,
                                at path:IndexPath,
                                activateInput:Bool,
                                _ animation:UITableView.RowAnimation = .fade) {
        //print("[FormKit] (_changeSection)")

        guard let currentSection = dataSource.section(for: path) else {
            return
        }
        
        guard newSection.hasOnlyActionValues == false else {
            dataSource.sections[path.section] = newSection
            let changingRows = Array(0..<newSection.rows.count).map({ IndexPath(row: $0, section: path.section) })
            if currentSection.isEnabled && !newSection.isEnabled {
                handleActionCellChanging(for: changingRows, enabled: false)
            } else if !currentSection.isEnabled && newSection.isEnabled  {
                handleActionCellChanging(for: changingRows, enabled: true)
            }
            return
        }
        
        dataSource.sections[path.section] = newSection

        /* Sarted crashing in iOS 17 ???
         tableView.reload(changes: changes,
                          section: path.section,
                          insertionAnimation: animation,
                          deletionAnimation: animation,
                          replacementAnimation: animation,
                          updateData: {},
                          completion: activateInput ? myCompletion : nil
         )
         */
        
        /// This is the only thing that seems to work.
        tableView.reloadData()
        
        
        guard activateInput else { return }
        
        if let inputRow = newSection.firstInputRow {
            let firstInputPath = IndexPath(row: inputRow, section: path.section)
            if let nextCell = self.tableView.cellForRow(at: firstInputPath) {
                if let activatabelCell = nextCell as? Activatable {
                    self.feedback(.impact)
                    activatabelCell.activate()
                }
            }
        }
       
         
    }
    
}






// MARK: - FormAlertAction -
public struct FormAlertAction {
    let title:String
    let action: (() -> Void)
    var actionText: ((String?) -> Void)? = nil
    var isDestructive: Bool = false
}


extension FormAlertAction {
    
    public init(_ title:String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public init(_ title:String, actionText: @escaping (String?) -> Void) {
        self.title = title
        self.action = {}
        self.actionText = actionText
    }
}



extension FormAlertAction {
    
    private var destructiveExamples: [String] {
        [ "Delete","delete"]
    }
    
    var soundsDestructive: Bool {
        if isDestructive {
            return true
        } else {
           return destructiveExamples.contains(title)
        }
        
    }
    
    var alertAction: UIAlertAction {
        UIAlertAction(title: title,
                      style: soundsDestructive ? .destructive : .default
        ) { _ in
            self.action()
        }
    }
    
}




// MARK: - Alert -
extension FormController {
    
    private func makeAlertController(_ title: String,_ message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
    
    public func showAlertConfirmation(_ title:String,_ message:String = "",with action:FormAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(action.alertAction)
        generateHapticFeedback(.mediumImpact)
        present(alert, animated: true,completion: nil)
    }
    
    
    public func showAlertSaying(_ title:String,_ message:String = "",with actions:[FormAlertAction]) {
        let alert = makeAlertController(title, message)
        actions.forEach({
            alert.addAction($0.alertAction)
        })
        generateHapticFeedback(.mediumImpact)
        present(alert, animated: true,completion: nil)
    }
    
    
    public func showDestructiveSheet(_ title:String,_ message:String = "",_ destructiveOptionTitle:String,actionHandler: @escaping (() -> Void)) {
        let alert = makeAlertController(title, message)
        
        var formAlertAction = FormAlertAction(destructiveOptionTitle, action: actionHandler)
        formAlertAction.isDestructive = true
        alert.addAction(formAlertAction.alertAction)
 
        generateHapticFeedback(.mediumImpact)
        present(alert, animated: true,completion: nil)
    }
    
    
    public func showDestructiveAlert(_ title:String,_ message:String = "",_ destructiveOptionTitle:String,actionHandler: @escaping (() -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var formAlertAction = FormAlertAction(destructiveOptionTitle, action: actionHandler)
        formAlertAction.isDestructive = true
        alert.addAction(formAlertAction.alertAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
 
        generateHapticFeedback(.mediumImpact)
        present(alert, animated: true,completion: nil)
    }
    
    
    
    // MARK: - AlertEditingText -
    public func showAlertEditingText(_ title:String,_ message:String? = nil, placeholderText:String, with actions:[FormAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField { [weak self] (textField) in
            guard let self = self else { return }
            textField.text = placeholderText
            textField.addTarget(self, action: #selector(self.handleTextFieldInput(_:)), for: .allEvents)
            textField.selectAll(nil)
        }
        
        actions.forEach({
            if let actionTextCallback = $0.actionText {
                alert.addAction(UIAlertAction(title: $0.title, style: .default, handler: { [weak self] (alertAction) in
                    actionTextCallback(self?.alertTextFieldInput)
                    self?.alertTextFieldInput = nil
                }))
            } else {
                alert.addAction($0.alertAction)
            }
        })
        
        generateHapticFeedback(.mediumImpact)
        present(alert, animated: true,completion: nil)
        
    }
    
    
    @objc
    private func handleTextFieldInput(_ textField:UITextField) {
        self.alertTextFieldInput = textField.text
    }
    
}



// MARK: - HapticFeedback -
extension FormController {
    
    public func feedback(_ feedbackType:FeedbackType) {
           generateHapticFeedback(feedbackType)
       }
    
    public enum FeedbackType {
        case lightImpact, mediumImpact, heavyImpact, impact, selection, error, warning, success, failure
    }
    
   
    
    private func generateHapticFeedback(_ feedbackType:FeedbackType) {
        switch feedbackType {
        case .lightImpact:
            let gen = UIImpactFeedbackGenerator()
            gen.prepare()
            if #available(iOS 13.0, *) {
                gen.impactOccurred(intensity: 0.25)
            } else {
                gen.impactOccurred()
            }
        case .mediumImpact:
            let gen = UIImpactFeedbackGenerator()
            gen.prepare()
            if #available(iOS 13.0, *) {
                gen.impactOccurred(intensity: 0.66)
            } else {
                gen.impactOccurred()
            }
        case .heavyImpact:
            let gen = UIImpactFeedbackGenerator()
            gen.prepare()
            if #available(iOS 13.0, *) {
                gen.impactOccurred(intensity: 1.0)
            } else {
                gen.impactOccurred()
            }
        case .impact:
            let gen = UIImpactFeedbackGenerator()
            gen.prepare()
            gen.impactOccurred()
        case .selection:
            let gen = UISelectionFeedbackGenerator()
            gen.prepare()
            gen.selectionChanged()
        case .warning:
            let gen = UINotificationFeedbackGenerator()
            gen.prepare()
            gen.notificationOccurred(.warning)
        case .success:
            let gen = UINotificationFeedbackGenerator()
            gen.prepare()
            gen.notificationOccurred(.success)
        case .failure, .error:
            let gen = UINotificationFeedbackGenerator()
            gen.prepare()
            gen.notificationOccurred(.error)
        }
    }
    
    
    
}



// MARK: - UpdateFormValueDelegate -
extension FormController: UpdateFormValueDelegate {
    
    
    public func update(_ formValue: FormValue,_ row:Int,_ section:Int = 0) {
        self.updatedFormValue(formValue, IndexPath(row: row, section: section))
    }
    
 
    public func updatedFormValue(_ formValue: FormValue, _ indexPath: IndexPath?) {
        if let path = indexPath {
            
            if let formItem = dataSource.itemAt(path) {
                switch formItem {
                case .stepper(let stepper):
                    if let stepperValue = formValue as? StepperValue {
                        if stepperValue != stepper {
                            handleUpdatedFormValue(stepperValue, at: path)
                        }
                    }
                case .text(let text):
                    if let textValue = formValue as? TextValue {
                        if textValue != text {
                            handleUpdatedFormValue(textValue, at: path)
                        }
                    }
                case .time(let time):
                    if let timeValue = formValue as? TimeValue {
                        if timeValue != time {
                            handleUpdatedFormValue(timeValue , at: path)
                            tableView.reloadRows(at: [path], with: .none)
                        }
                    }
                case .button(_):
                    break
                case .note(let note):
                    if let noteValue = formValue as? NoteValue {
                        if noteValue != note {
                            handleUpdatedFormValue(noteValue, at: path)
                            //tableView.reloadRows(at: [path], with: .none)
                        }
                    }
                case .segment(let segment):
                    if let segmentValue = formValue as? SegmentValue {
                        if segmentValue.selectedValue != segment.selectedValue {
                            lastSegmentValue = segment
                            handleUpdatedFormValue(segmentValue , at: path)
                            segmentValue.valueChangeClosure?(segmentValue,self,path)
                            //runValidation()
                        }
                    }
                case .numerical(let numerical):
                    if let numericalValue = formValue as? NumericalValue {
                        if numericalValue != numerical {
                            numericalValue.valueChangedClosure?(numericalValue,self,path)
                            handleUpdatedFormValue(numericalValue, at: path)
                        }
                    }
                case .readOnly(let readOnly):
                    if let readOnlyValue = formValue as? ReadOnlyValue {
                        if readOnlyValue != readOnly {
                            handleUpdatedFormValue(readOnlyValue, at: path)
                            tableView.reloadRows(at: [path], with: .none)
                        }
                    }
                case .picker(let picker):
                    if let pickerValue = formValue as? PickerValue {
                        if pickerValue != picker {
                            handleUpdatedFormValue(pickerValue , at: path)
                        }
                    }
                case .pickerSelection(let pickerSelection):
                    if let pickerSelectionValue = formValue as? PickerSelectionValue {
                        if pickerSelectionValue != pickerSelection {
                            handleUpdatedFormValue(pickerSelectionValue , at: path)
                            tableView.reloadRows(at: [path], with: .fade)
                            pickerSelectionValue.selectedValueClosure?(self,path,pickerSelectionValue.selectedValue())
                        }
                    }
                case .action(let actionValue):
                    if let localActionValue = formValue as? ActionValue {
                        if localActionValue != actionValue {
                            handleUpdatedFormValue(localActionValue , at: path)
                            tableView.reloadRows(at: [path], with: .fade)
                        }
                    }
                case .listSelection(let list):
                    if let listSelectionValue = formValue as? ListSelectionValue {
                        if listSelectionValue != list {
                            listSelectionValue.valueChangeClosure?(listSelectionValue,self,path)
                            handleUpdatedFormValue(listSelectionValue, at: path)
                            tableView.reloadRows(at: [path], with: .none)
                        }
                    }
                case .timeInput(let time):
                    if let timeInputValue = formValue as? TimeInputValue {
                        if timeInputValue != time {
                            runValidation()
                            handleUpdatedFormValue(timeInputValue , at: path)
                        }
                    }
                case .switchValue(_):
                    if let switchInputValue = formValue as? SwitchValue {
                        switchInputValue.valueChangedClosure?(switchInputValue,self,path)
                        handleUpdatedFormValue(switchInputValue , at: path)
                        self.dataSource.setNeedsUpdate()
                    }
                case .slider(let sliderValue):
                    if let sliderInputValue = formValue as? SliderValue {
                        if sliderInputValue != sliderValue {
                            sliderInputValue.valueChangedClosure?(self,path,sliderInputValue)
                            handleUpdatedFormValue(sliderInputValue , at: path)
                        }
                    }
                case .map(let mapValue):
                    if let mapInputValue = formValue as? MapValue {
                        if mapInputValue != mapValue {
                            handleUpdatedFormValue(mapInputValue , at: path)
                        }
                    }
                case .mapAction(let mapAction):
                    if let mapActionInputValue = formValue as? MapActionValue {
                        if mapActionInputValue != mapAction {
                            handleUpdatedFormValue(mapActionInputValue , at: path)
                            tableView.reloadRows(at: [path], with: .automatic)
                        }
                    }
                case .custom(let customValue):
                    if let customInputValue = formValue as? CustomValue {
                        if customInputValue != customValue {
                            handleUpdatedFormValue(customInputValue, at: path)
                            tableView.reloadRows(at: [path], with: .fade)
                        }
                    }
                case .input(let input):
                    if let inputValue = formValue as? InputValue {
                        if inputValue != input {
                            handleUpdatedFormValue(inputValue, at: path)
                        }
                    }
                case .date(let date):
                    if let dateValue = formValue as? DateValue {
                        if dateValue != date {
                            handleUpdatedFormValue(dateValue, at: path)
                        }
                    }
                case .datePicker(let datePickerValue):
                    if let pickerValue = formValue as? DatePickerValue {
                        if pickerValue != datePickerValue {
                            handleUpdatedFormValue(pickerValue, at: path)
                        }
                    }
                case .push(let push):
                    if let pushValue = formValue as? PushValue {
                        if pushValue != push {
                            handleUpdatedFormValue(pushValue, at: path)
                        }
                    }
                case .dateTime(let dateTime):
                    if let dateTimeValue = formValue as? DateTimeValue {
                        if dateTimeValue != dateTime {
                            handleUpdatedFormValue(dateTimeValue, at: path)
                        }
                    }
                case .token(let token):
                    if let tokenValue = formValue as? TokenValue {
                        if tokenValue != token {
                            handleUpdatedFormValue(tokenValue, at: path)
                        }
                    }
                case .color(let color):
                    if let colorValue = formValue as? ColorValue {
                        if colorValue != color {
                            handleUpdatedFormValue(colorValue, at: path)
                            tableView.reloadRows(at: [path], with: .automatic)
                            colorValue.formClosure?(colorValue,self,path)
                        }
                    }
                case .web(let web):
                    if let webValue = formValue as? WebViewValue {
                        if webValue != web {
                            handleUpdatedFormValue(webValue, at: path)
                            tableView.reloadRows(at: [path], with: .automatic)
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
                if tableView.isScrollEnabled {
                    tableView.scrollToRow(at: previousIndexPath, at: .none, animated: true)
                }
                if let previousCell = tableView.cellForRow(at: previousIndexPath) {
                    if let activatabelCell = previousCell as? Activatable {
                        activatabelCell.activate()
                    }
                }
            }
        case .next:
            if let nextIndexPath = dataSource.nextIndexPath(from) {
                if tableView.isScrollEnabled {
                    tableView.scrollToRow(at: nextIndexPath, at: .none, animated: true)
                }
                if let nextCell = tableView.cellForRow(at: nextIndexPath) {
                    if let activatabelCell = nextCell as? Activatable {
                        activatabelCell.activate()
                    }
                }
            }
        }
        

    }
}


extension FormController {
    
    public func performLiveUpdates(_ stopAnimation:Bool = false) {

        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            
            if stopAnimation {
                UIView.setAnimationsEnabled(false)
                
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                
                let scrollTo = self.tableView.contentSize.height - self.tableView.frame.size.height
                self.tableView.setContentOffset(CGPoint(x: 0, y: scrollTo), animated: false)
                
                UIView.setAnimationsEnabled(true)
            } else {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        })
    }
    
    
    public func updateFormValue(_ formValue: FormValue, at path: IndexPath) {
        handleUpdatedFormValue(formValue, at: path)
    }
    
    private func handleUpdatedFormValue(_ formValue: FormValue, at path: IndexPath) {
        dataSource.yOffset = tableView.contentOffset.y
        dataSource.updateWith(formValue: formValue, at: path)
        runValidation()
        
        let r = self.tableView.rect(forSection: path.section)
        self.dataSource.lastRect = (
            Double(r.origin.x),
            Double(r.origin.y),
            Double(r.size.width),
            Double(r.size.height)
        )
        
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
            navigationController?.pushViewController(FormController(formData: .Random()), animated: true)
        } else {
            navigationController?.pushViewController(FormController(formData: .Random()), animated: true)
        }
    }
    
}






// MARK: - SectionTapDelegate -
extension FormController: SectionTapDelegate {
    
    public func didSelectHeaderAt(_ section:Int) {
        
        guard
            let formSection = dataSource.section(for: section),
            formSection.headerValue.isInteractable
        else { return }
        
        let sectionRect = tableView.rect(forSection: section)
        dataSource.sections[section].toggleState(Double(sectionRect.height))
    
        if let sectionHeader = self.tableView.headerView(forSection: section) as? FormHeaderCell {
            var headerValue = dataSource.sections[section].headerValue
            headerValue.updateSection(section,formSection.title)
            sectionHeader.configureView(headerValue)
        }
        
        switch self.dataSource.sections[section].headerValue.state {
        case .collapsed:
            tableView.deleteRows(at: formSection.indexPaths(section), with: .fade)
        case .expanded:
            tableView.insertRows(at: formSection.indexPaths(section), with: .fade)
            
            if scrollsWithSectionExpansion {
                if let last = formSection.indexPaths(section).last {
                    tableView.scrollToRow(at: last, at: .bottom, animated: true)
                }
            }
            
        }
    }
    
}


// MARK: - UIDocumentInteractionControllerDelegate -  
extension FormController: UIDocumentInteractionControllerDelegate {
    
    
    public func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        documentInteractionWillBegin?(self,controller)
    }
    

    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        documentInteractionDidEnd?(self,controller)
    }
    
    public func documentInteractionControllerWillPresentOptionsMenu(_ controller: UIDocumentInteractionController) {
        //
    }

    
    
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    
    public func showDocument(_ documentURL:URL?) {
        if let url = documentURL {
            DispatchQueue.main.async(execute: { [weak self] in
                guard let self = self else { return }
                let viewer = UIDocumentInteractionController(url: url)
                viewer.delegate = self
                viewer.presentPreview(animated: true)
                self.generateHapticFeedback(.impact)
            })
        }
    }

}



extension FormController {
    
    public func presentColorPicker(_ color:UIColor?,completionHandler: @escaping (UIColor?) -> Void) {
        
        if #available(iOS 14.0, *) {
            
            
            let colorPickerController = UIColorPickerViewController()
            colorPickerController.delegate = self
            if let color = color {
                colorPickerController.selectedColor = color
            }
            
            self.colorSelectedClosure = completionHandler
            present(colorPickerController, animated: true)
            
        }
        
    }
    
}

@available(iOS 14.0, *)
extension FormController: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    public func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        pickedColor = viewController.selectedColor
    }

    
    public func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        pickedColor = color
    }
    
}



extension FormController: UIImagePickerControllerDelegate {
    
    public func showImagePicker(_ imageClosure:((UIImage?) -> ())?) {
        self.imageResultClosure = imageClosure
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        imageResultClosure?(image)
    }
}


extension FormController: UINavigationControllerDelegate { }


































// MARK: - FormHeaderCell -
public final class FormHeaderCell: UITableViewHeaderFooterView {
    static let identifier = "com.jmade.FormKit.FormHeaderCell"
    static let footerIdentifier = "com.jmade.FormKit.FormHeaderCell.Footer"
    
    public weak var delegate:SectionTapDelegate?
    
    public  var headerValue:HeaderValue? {
        didSet {
            if let header = headerValue {
                applyHeader(header)
            }
        }
    }
    
    var footerValue: FooterValue? {
        didSet {
            if let footer = footerValue {
                applyFooter(footer)
            }
        }
    }

    public var textStyle:UIFont.TextStyle = .title2
    public var subtitleTextStyle:UIFont.TextStyle = .subheadline
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: textStyle).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        //label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        
        labelContainer.addSubview(label)
        label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: labelContainer.topAnchor).isActive = true
        //labelContainer.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        return label
    }()
    
    private lazy var subTitleLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: subtitleTextStyle)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        //label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 900) , for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 900), for: .vertical)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        }
        labelContainer.addSubview(label)
        label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor).isActive = true
        
        //labelContainer.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        return label
    }()
    
    
    private lazy var labelContainer:UIView = {
        let container = UIView()
        container.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        container.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var imageContainer:UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    
    private lazy var indicatorView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.FormKit.text
        if #available(iOS 13.0, *) {
            imageView.preferredSymbolConfiguration = .init(textStyle: textStyle, scale: .medium)
        } else {
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 36.0).isActive = true
        }
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageContainer.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        return imageView
    }()
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTap)))
        return stackView
    }()
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    
    private func applyFooter(_ footer:FooterValue) {
        titleLabel.text = footer.title.uppercased()
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .secondaryLabel
        }
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        
        titleLabel.sizeToFit()
        subTitleLabel.text = nil
        
        let views = stackView.arrangedSubviews
        
        if !views.containsItem(labelContainer) {
            stackView.addArrangedSubview(labelContainer)
        }
    }
    
    private func applyHeader(_ header:HeaderValue) {
        
        let data:(image:UIImage?,color:UIColor?) = getImage(header)
        
        self.titleLabel.text = header.title
        self.subTitleLabel.text = header.subtitle
        self.titleLabel.sizeToFit()
        
        
        if let color = data.color {
            indicatorView.tintColor = color
        } else {
            indicatorView.tintColor = UIColor.FormKit.text
        }
        
        
        let views = stackView.arrangedSubviews
        
        if let image = data.image {

            indicatorView.image = image
            
            switch header.iconStyle {
            case .none:
                if views.contains(imageContainer) {
                    stackView.removeArrangedSubview(imageContainer)
                }
                
                if !views.containsItem(labelContainer) {
                    stackView.addArrangedSubview(labelContainer)
                }
            case .trailing:
                for view in views {
                    stackView.removeArrangedSubview(view)
                }
                stackView.addArrangedSubview(labelContainer)
                stackView.addArrangedSubview(imageContainer)
            case .leading:
                for view in views {
                    stackView.removeArrangedSubview(view)
                }
                stackView.addArrangedSubview(imageContainer)
                stackView.addArrangedSubview(labelContainer)
            }
        } else {
            indicatorView.image = nil
            if !views.containsItem(labelContainer) {
                stackView.addArrangedSubview(labelContainer)
            }
            
            if views.contains(imageContainer) {
                stackView.removeArrangedSubview(imageContainer)
            }
        }
    }
    
   
    
    public override func prepareForReuse() {
        headerValue = nil
        footerValue = nil
        titleLabel.text = nil
        subTitleLabel.text = nil
        indicatorView.image = nil
        super.prepareForReuse()
    }
    
    
    public func configureView(_ header:HeaderValue) {
        self.headerValue = header
    }
    
    public func configureView(_ footer:FooterValue) {
        self.footerValue = footer
    }
    
    
    @objc private func didTap() {
        if let header = headerValue {
            delegate?.didSelectHeaderAt(header.section)
        }
    }
    
}







extension FormHeaderCell {
    
    private func getImage(_ header:HeaderValue) -> (UIImage?,UIColor?) {
        switch header.imageType {
        case .addPerson:
            switch header.state {
            case .collapsed:
               return (nil,nil)
            case .expanded:
                return (nil,nil)
            }
        case .addPhone:
            switch header.state {
            case .collapsed:
               return (nil,nil)
            case .expanded:
                return (nil,nil)
            }
        case .chevron:
            switch header.state {
            case .collapsed:
                return (HeaderValue.Image.chevronCollapsed,UIColor.FormKit.text)
            case .expanded:
                return (HeaderValue.Image.chevronExpanded,UIColor.FormKit.text)
            }
        case .none:
            return (nil,nil)
        case .plus:
            switch header.state {
            case .collapsed:
                return (HeaderValue.Image.plusFilled,UIColor.FormKit.text)
            case .expanded:
                return (nil,nil)
            }
        case .plusMinus:
            switch header.state {
            case .collapsed:
                return (HeaderValue.Image.plusFilled,.success)
            case .expanded:
                return (HeaderValue.Image.minusFilled,.delete)
            }
        case .expand:
            switch header.state {
            case .collapsed:
                return (HeaderValue.Image.plusFilled,UIColor.FormKit.text)
            case .expanded:
                return (HeaderValue.Image.minusFilled,UIColor.FormKit.text)
            }
        case .custom(let customValue):
            switch header.state {
            case .collapsed:
                if #available(iOS 13.0, *) {
                    return (UIImage(systemName: customValue),nil)
                }
                return (nil,nil)
            case .expanded:
               if #available(iOS 13.0, *) {
                   return (UIImage(systemName: customValue),nil)
               }
               return (nil,nil)
            }
        }
    }
    
}







