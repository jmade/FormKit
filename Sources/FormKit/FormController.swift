import UIKit



// MARK: - FormValidationClosure -
public typealias FormValidationClosure = ( (FormDataSource,FormController) -> Void )




extension UITableView {
    
    public func indexPathOfFirstResponder() -> IndexPath? {
        
        for section in Array(0...numberOfSections) {
            for row in Array(0...numberOfRows(inSection: section)) {
                if let cell = cellForRow(at: IndexPath(row: row, section: section)) {
                    for view in cell.contentView.subviews {
                        if view.isFirstResponder {
                            return IndexPath(row: row, section: section)
                        }
                    }
                }
            }
        }
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











public typealias FormDismissalClosure = ( () -> Void )

// MARK: - FormController -
open class FormController: UITableViewController, CustomTransitionable {
    
    public var dismissalClosure: FormDismissalClosure?
    
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
        get {
            return barItems.filter({ $0.side == .leading })
        }
    }
    
    public var trailingBarItems:[BarItem] {
        get {
            return barItems.filter({ $0.side == .trailing })
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
    
    public var dataSource = FormDataSource(sections: []) {
        didSet {
            
            guard !dataSource.isEmpty else {
                return
            }
            
            tableView.tableFooterView = nil
            
            guard tableView.window != nil else {
                return
            }
            
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
                            with: .automatic
                        )
                    }
                })
                runValidation()
            } else {
                handleDataEvaluation(
                    FormDataSource.evaluate(oldValue, new: dataSource)
                )
            }

        }
    }
    
    
    private var headers:[HeaderValue] {
        return dataSource.headerValues()
    }
    
    private var footers:[FooterValue] {
        return dataSource.footerValues()
    }
    
    private var defaultContentInsets = UIEdgeInsets(top: 20, left: 0, bottom: 30, right: 0)
    
    
    /// Loading
    public typealias FormDataLoadingClosure = (FormController) -> Void
    public var loadingClosure: FormDataLoadingClosure? = nil
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
    
    public var usesContextMenus: Bool = false
    
    
    
   
    public var allowModalDismissal:Bool = false {
        didSet {
            if #available(iOS 13.0, *) {
                isModalInPresentation = !allowModalDismissal
            }
        }
    }
    
    
    
    private var hasActivated = false
    
    private var alertTextFieldInput: String? = nil
    
    
    
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
    
    
    
    // MARK: - INIT -
    required public init?(coder aDecoder: NSCoder) {fatalError()}
 
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
           self.title = dataSource.title
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
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            let existingData = self.dataSource
            newData.updateClosure = existingData.updateClosure
            self.dataSource = newData
        })
    }
    
   

    // MARK: - Controller Base Initialize -
    private func controllerInitialize() { }
    
    // MARK: - setupUI -
    private func setupUI() {
        //print("[FromKit] Form Controller (setupUI)")
        // Header Cell
        
        switch displayStyle {
        case .modern:
            tableView.register(FormHeaderCell.self, forHeaderFooterViewReuseIdentifier: FormHeaderCell.identifier)
            tableView.register(FormHeaderCell.self, forHeaderFooterViewReuseIdentifier: FormHeaderCell.footerIdentifier)
            tableView.contentInset = defaultContentInsets
        default:
            break
        }
        
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension

        checkBarItems()
            
        if shouldRefresh {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
        
        setupToolBar()
        
        if let message = loadingMessage {
            if #available(iOS 13.0, *) {
                tableView.tableFooterView = ItemsLoadingView(message: message, textStyle: .body, color: .label)
            } else {
                tableView.tableFooterView = ItemsLoadingView(message: message, textStyle: .body, color: .black)
            }
        }
        
        
        if let closure = loadingClosure {
            if #available(iOS 13.0, *) {
                tableView.tableFooterView = ItemsLoadingView(message: "Loading", textStyle: .body, color: .label)
            } else {
                tableView.tableFooterView = ItemsLoadingView(message: "Loading", textStyle: .body, color: .black)
            }
            closure(self)
        }
        
        didLoad = true
        
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
    
    
    
    

    
    private func handleDataEvaluation(_ eval:FormDataSource.Evaluation) {
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            self.tableView.beginUpdates()
            self.tableView.insertSections(eval.sets.insert, with: .fade)
            self.tableView.deleteSections(eval.sets.delete, with: .fade)
            self.tableView.reloadSections(eval.sets.reload, with: .fade)
            eval.reloads.forEach({
                if let sectionHeader = self.tableView.headerView(forSection: $0.section) as? FormHeaderCell {
                    if let formSection = self.dataSource.section(for: $0.section) {
                        sectionHeader.configureView(formSection.headerValue)
                    }
                }
                if let changes = $0.changes {
                    self.tableView.reload(
                        changes: changes,
                        section: $0.section,
                        insertionAnimation: .fade,
                        deletionAnimation:  .fade,
                        replacementAnimation:  .fade,
                        completion: nil
                    )
                }
            })
            self.tableView.endUpdates()
        })
    }
    

    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if didLoad == false {
            setupUI()
        }
        
        contentSizeObserver = tableView.observe(\.contentSize) { [weak self] tv, _ in
            guard let self = self else { return }
            

            
            let newContentSize = CGSize(width: tv.contentSize.width + tv.contentInset.left + tv.contentInset.right,
                   height: tv.contentSize.height + tv.contentInset.top + tv.contentInset.bottom)
            
            
            //let newContentSize = tableView.contentSize
            if self.preferredContentSize != newContentSize {
                self.preferredContentSize = newContentSize
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
        checkForActiveInput()
        runValidation()
    }
    
    
    private func runValidation() {
        if !dataSource.isEmpty {
            validationClosure?(dataSource,self)
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
        dismissalClosure?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func donePressed(){
        dismissalClosure?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  [weak self] in
            guard let self = self else { return }
            //self.dataSource = FormDataSource.Random()
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    public func reloadRefresh() {
        if let closure = loadingClosure {
            closure(self)
        }
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
        
        if let item = dataSource.itemAt(indexPath) {
            item.cellDescriptor.didSelect(self,indexPath)
        }
        
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
            
            guard usesContextMenus, let formItem = dataSource.itemAt(indexPath) else {
                return nil
            }
            
            
            let contextMenu = makeContextMenu(formItem)
            
            return UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: nil,
                actionProvider: { suggestedActions in
                    return contextMenu
            })

        }
    
}


@available(iOS 13.0, *)
extension FormController {
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        generateHapticFeedback(.success)
        
        // 2
        let action =  UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, handler:(Bool) -> Void) in
            guard let self = self else { return }
            
            if self.dataSource.sections[indexPath.section].rows.count == 1 {
                // Delete the Section
                let _ = self.dataSource.sections.remove(at: indexPath.section)
                self.tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section) , with: .fade)
            } else {
                let _ = self.dataSource.sections[indexPath.section].rows.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            self.generateHapticFeedback(.impact)
            handler(true)
        }
        
        //
        
        
        
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = .systemRed
        
        return action
        
        
        
    }
    
    
  
    
    
    /// Context Menu
    func makeContextMenu(_ formItem:FormItem) -> UIMenu {
          

    //        // The "title" will show up as an action for opening this menu
    //        let edit = UIMenu(title: "Edit...", children: [rename, delete])

                // Create a UIAction for sharing
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                // Show system share sheet
                
            }
        
            


            // Create our menu with both the edit menu and the share action
            return UIMenu(title: "Main Menu", children: [share])
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
    
    
    public func updateValue(_ formValue:FormValue, at path:IndexPath) {
        if let section = dataSource.section(for: path.section) {
            if let _ = section.itemForRowAt(path.row) {
                dataSource.sections[path.section].rows[path.row] = formValue.formItem
                tableView.reloadRows(at: [path], with: .fade)
            }
        }
    }
    
    
    public func updateSection(_ newSection:FormSection, at path:IndexPath,_ activateInputs:Bool = true) {
        self.update(newSection, path: path, activateInputs: activateInputs, preservingTitle: false)
    }
    
    public func reloadSection(_ newSection:FormSection, at path:IndexPath, preservingTitle:Bool,_ activateInputs:Bool = true) {
        self.update(newSection, path: path, activateInputs: activateInputs, preservingTitle: preservingTitle)
    }
    
    public func reloadSection(_ newSection:FormSection, at path:IndexPath) {
        self.update(newSection, path: path, activateInputs: true, preservingTitle: true)
    }
    
    
    // Update
    private func update(_ newSection:FormSection, path:IndexPath, activateInputs:Bool = true, preservingTitle:Bool) {
        // Title
        var section = newSection
        
        if preservingTitle {
            section = FormSection(dataSource.sections[path.section].title, newSection.rows)
            section.setHeaderValue(newSection.headerValue)
            section.updateClosure = newSection.updateClosure
        }
        
        dataSource.sections[path.section] = section
        
        if preservingTitle {
            tableView.reloadSections(IndexSet(integer: path.section), with: .automatic)
        } else {
            tableView.reloadSections(IndexSet(integer: path.section), with: .automatic)
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
    
    
    // MARK: - ListItem Update -
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
    
    
    public func addListItemsWithData(_ data:[String:ListItem]) {
        addListItemsData(data)
    }
    
    
    private func addListItemsData(_ data:[String:ListItem]) {
        
        var vals:[(IndexPath,FormItem)] = []
        
        for (key,listItem) in data {
            
            if let lsv = dataSource.getListSelectionValueForKey(key) {
                let existingList = lsv.0
                let newItems = [[listItem],existingList.listItems]
                    .reduce([],+)
                    .sorted { (a, b) -> Bool in
                    a.title < b.title
                }
                let newLSV = existingList.newWith(newItems)
                vals.append((lsv.1, newLSV.formItem))
            }
            
        }
        
        
        for item in vals {
            dataSource.sections[item.0.section].rows[item.0.row] = item.1
        }
        
        tableView.reloadRows(at: vals.map({ $0.0 }), with: .none)
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
                        //print("Changing Action Cell at:\(row) | \(actionCell)")
                        enabled ? actionCell.setEnabled() : actionCell.setDisabled()
                    }
                }
            }
        }
    }
    
    
    
    
    public func changeLastSection(_ newSection:FormSection,_ activate:Bool = false) {
        
       
        changeSection(newSection, at: IndexPath(row: 0, section: dataSource.sections.count-1),activate)
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
    
    
    public func changeSection(_ newSection:FormSection,at path:IndexPath,_ activate:Bool = false) {
        guard !dataSource.sections.isEmpty else { return }
        _changeSection(newSection,at: path, activateInput: activate)
    }
    
    
    private func _changeSection(_ newSection:FormSection,
                                at path:IndexPath,
                                activateInput:Bool,
                                _ animation:UITableView.RowAnimation = .fade) {
      
        let myCompletion: ((Bool) -> Void) = { (bool) in
            
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
    

        if let currentSection = dataSource.section(for: path) {
            
            let changes = diff(old: currentSection.rows, new: newSection.rows)
            dataSource.sections[path.section] = newSection
            
            if newSection.hasOnlyActionValues {
                 let changingRows = Array(0..<newSection.rows.count).map({ IndexPath(row: $0, section: path.section) })
                
                if currentSection.isEnabled && !newSection.isEnabled {
                    handleActionCellChanging(for: changingRows, enabled: false)
                } else if !currentSection.isEnabled && newSection.isEnabled  {
                    handleActionCellChanging(for: changingRows, enabled: true)
                }
            } else {
                tableView.reload(changes: changes,
                                 section: path.section,
                                 insertionAnimation: animation,
                                 deletionAnimation: animation,
                                 replacementAnimation: animation,
                                 completion: activateInput ? myCompletion : nil
                )
            }
        }
    }
    
}






// MARK: - FormAlertAction -
public struct FormAlertAction {
    let title:String
    let action: (() -> Void)
    var actionText: ((String?) -> Void)? = nil
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
        destructiveExamples.contains(title)
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
        present(alert, animated: true) { [weak self] in
            self?.generateHapticFeedback(.heavyImpact)
        }
    }
    
    
    public func showAlertSaying(_ title:String,_ message:String = "",with actions:[FormAlertAction]) {
        let alert = makeAlertController(title, message)
        actions.forEach({
            alert.addAction($0.alertAction)
        })
        present(alert, animated: true) { [weak self] in
            self?.generateHapticFeedback(.heavyImpact)
        }
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
        
        present(alert, animated: true) { [weak self] in
            self?.generateHapticFeedback(.heavyImpact)
        }
        
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
        case lightImpact, heavyImpact, impact, selection, error, warning, success, failure
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
                        }
                    }
                case .segment(let segment):
                    if let segmentValue = formValue as? SegmentValue {
                        if segmentValue.selectedValue != segment.selectedValue {
                            handleUpdatedFormValue(segmentValue , at: path)
                            segmentValue.valueChangeClosure?(segmentValue,self,path)
                            runValidation()
                        }
                    }
                case .numerical(let numerical):
                    if let numericalValue = formValue as? NumericalValue {
                        if numericalValue != numerical {
                            handleUpdatedFormValue(numericalValue, at: path)
                        }
                    }
                case .readOnly(let readOnly):
                    if let readOnlyValue = formValue as? ReadOnlyValue {
                        if readOnlyValue != readOnly {
                            handleUpdatedFormValue(readOnlyValue, at: path)
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
                case .switchValue(let switchValue):
                    if let switchInputValue = formValue as? SwitchValue {
                        if switchInputValue != switchValue {
                            handleUpdatedFormValue(switchInputValue , at: path)
                        }
                    }
                case .slider(let sliderValue):
                    if let sliderInputValue = formValue as? SliderValue {
                        if sliderInputValue != sliderValue {
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
    
    public func updateFormValue(_ formValue: FormValue, at path: IndexPath) {
        handleUpdatedFormValue(formValue, at: path)
    }
    
    private func handleUpdatedFormValue(_ formValue: FormValue, at path: IndexPath) {
        dataSource.updateWith(formValue: formValue, at: path)
        runValidation()
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
            if let last = formSection.indexPaths(section).last {
                tableView.scrollToRow(at: last, at: .bottom, animated: true)
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


































// MARK: - FormHeaderCell -
public final class FormHeaderCell: UITableViewHeaderFooterView {
    static let identifier = "com.jmade.FormKit.FormHeaderCell"
    static let footerIdentifier = "com.jmade.FormKit.FormHeaderCell.Footer"
    
    public weak var delegate:SectionTapDelegate?
    
    var headerValue:HeaderValue? {
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
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        }
        labelContainer.addSubview(label)
        label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.0).isActive = true
        labelContainer.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
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







