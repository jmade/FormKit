import UIKit

// MARK: - PickerValue -
public struct PickerSelectionValue {
    
    public var title:String
    public var values:[String]
    public var selectedIndex: Int = 0
    public var selectionMessage:String?
    public var ids:[Int]?
    
    public enum Mode {
        case display,selection
    }

    public var mode:Mode = .display
    public var customKey: String? = nil
    public let identifier = UUID()
    public var validators: [Validator] = []
    
    public var selectionChangedClosure: ( (FormController,IndexPath,PickerSelectionValue) -> Void )?
    public var selectedValueClosure: ( (FormController,IndexPath,String?) -> Void )?
}


extension PickerSelectionValue: Equatable, Hashable {
    
    public static func == (lhs: PickerSelectionValue, rhs: PickerSelectionValue) -> Bool {
        lhs.computedID == rhs.computedID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(computedID)
    }
    
    
    var computedID:String {
        "\(title),\(values),\(selectedIndex),\(mode),\(customKey ?? "-")"
    }
    
}


// MARK: - Initialization -
extension PickerSelectionValue {
    
    public init(title:String,values:[String],_ selectedIndex:Int = 0,_ selectionMessage:String?){
        self.values = values
        self.selectedIndex = selectedIndex
        self.title = title
        self.mode = .display
        self.selectionMessage = selectionMessage
    }
    
    public init(_ title:String,_ customKey:String,_ values:[String],_ selectedIndex:Int = 0) {
        self.values = values
        self.customKey = customKey
        self.selectedIndex = selectedIndex
        self.title = title
    }
    
    public init(_ title:String,_ customKey:String,_ values:[String],_ ids:[Int]) {
        self.values = values
        self.customKey = customKey
        self.selectedIndex = 0
        self.title = title
        self.ids = ids
    }
    
    
    public init(_ title:String,_ customKey:String,_ values:[String],_ ids:[Int],_ selectionMessage:String?) {
        self.values = values
        self.customKey = customKey
        self.selectedIndex = 0
        self.title = title
        self.ids = ids
        self.selectionMessage = selectionMessage
    }
    
}


// MARK: - Utility -
extension PickerSelectionValue {
    
    public func newWith(_ newSelectedIndex:Int) -> PickerSelectionValue {
        var new = PickerSelectionValue(
            title: self.title,
            values: self.values,
            selectedIndex: newSelectedIndex,
            selectionMessage: self.selectionMessage,
            mode: .display,
            customKey: self.customKey,
            selectionChangedClosure: self.selectionChangedClosure,
            selectedValueClosure: self.selectedValueClosure
        )
        
        new.ids = self.ids
        return new
    }
    
    
    public func newToggled() -> PickerSelectionValue {
        var new = PickerSelectionValue(
            title: self.title,
            values: self.values,
            selectedIndex: self.selectedIndex,
            selectionMessage: self.selectionMessage,
            mode: (self.mode == .selection) ? .display : .selection,
            customKey: self.customKey,
            selectionChangedClosure: self.selectionChangedClosure,
            selectedValueClosure: self.selectedValueClosure
        )
        
        new.ids = self.ids
        return new
    }
    
}



extension PickerSelectionValue {
    
    var cellId:String {
        return "picSel_\(identifier.uuidString)"
    }
    
    mutating func switchToSelection(){
        self.mode = .selection
    }
    
    mutating func toggleMode(){
        switch self.mode {
        case .display:
            self.mode = .selection
        case .selection:
            self.mode = .display
        }
    }
    
    
    var selectedId:Int? {
        guard let identifiers = ids, identifiers.count > selectedIndex else {
            return nil
        }
        return identifiers[selectedIndex]
    }
    
    
    public func selectedValue() -> String? {
        if let selectedId = selectedId {
            return "\(selectedId)"
        }
        guard !values.isEmpty, values.count > selectedIndex else {
            return nil
        }
        return values[selectedIndex]
    }
    
    
    public var selectedValueDefinitive: String {
        get {
            if let selectedValue = selectedValue() {
                return selectedValue
            }
            return "?"
        }
    }

}



// MARK: - FormValue -
extension PickerSelectionValue: FormValue {
    
    public var formItem: FormItem {
        get {
            return FormItem.pickerSelection(self)
        }
    }
    
    public func encodedValue() -> [String : String] {
        return [ customKey ?? title : selectedValue() ?? "" ]
    }
    
}


// MARK: - FormValueDisplayable -
extension PickerSelectionValue: FormValueDisplayable {
    
    public typealias Cell = PickerSelectionCell
    public typealias Controller = FormController
    
    public func configureCell(_ formController: FormController, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        let newToggled = self.newToggled()
        
        formController.dataSource.sections[path.section].rows[path.row] = newToggled.formItem
        
        /// TODO: Adjust contentInset here or fitting new content policy
        formController.tableView.reloadRows(at: [path], with: .automatic)
        newToggled.selectionChangedClosure?(formController,path,newToggled)
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier+identifier.uuidString, configureCell, didSelect)
    }
    
}



extension PickerSelectionValue {
    public static func Random() -> PickerSelectionValue {
        let values = ["Orange","Tree","Rock","Saturday","Rocket","Guitar","Tacos","Video Games","Water Slides","Green","Christmas"].shuffled()
        let selected = Int.random(in: 0...values.count-1)
        return PickerSelectionValue(title: "Picker", values: values, selected, "Pick Something")
    }
    
    public static func Demo() -> PickerSelectionValue {
        let values = stride(from: 0, to: 33, by: 1).map({ "Selection \($0)" })
        let selected = Int.random(in: 0...values.count-1)
        return PickerSelectionValue(title: "Picker-Selection",
                                    values: values,
                                    selected,
                                    "Pick/Select Something!"
        )
    }
}




// MARK: - PickerSelectionCell -
public final class PickerSelectionCell: UITableViewCell {
    static let identifier = "FormKit.PickerSelectionCell"
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    var pickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    lazy var selectedValue: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "-"
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .right
        label.font = UIFont.preferredFont(forTextStyle: .body)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        }
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    lazy var selectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .lightGray
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = ""
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    var standardHeightConstraint = NSLayoutConstraint()
    var pickerBottomConstriant = NSLayoutConstraint()
    var selectedBottomConstraint = NSLayoutConstraint()
    
    var pickerDataSource:[String] = [] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    var formValue : PickerSelectionValue? {
        didSet {
            
            guard let formValue = formValue else { return }
            
            title.text = formValue.title
            
            guard !(formValue.selectedIndex >= formValue.values.count) else {
                selectedValue.text = "-"
                return
            }
            
            title.text = formValue.title
            selectionLabel.text = formValue.selectionMessage ?? formValue.title
            
            if formValue.values.isEmpty {
                selectedValue.text = "-"
            } else {
                selectedValue.text = formValue.values[formValue.selectedIndex]
            }
            
            pickerDataSource = formValue.values
            
            switch formValue.mode {
            case .display:
                renderForDisplay()
            case .selection:
                renderForSelection()
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [title,selectedValue,selectionLabel,pickerView].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        
        standardHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 44.0)
        standardHeightConstraint.priority = UILayoutPriority(499.0)
        standardHeightConstraint.isActive = true
        
        title.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        
        selectedValue.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        selectedValue.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        selectedValue.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 2.0).isActive = true
        selectedBottomConstraint = selectedValue.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        
        selectionLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        selectionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        selectionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        
        pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        pickerView.topAnchor.constraint(equalTo: selectionLabel.bottomAnchor).isActive = true
        pickerBottomConstriant = pickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = nil
        self.selectionLabel.text = nil
        self.formValue = nil
        
    }
    
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        guard let value = formValue, !value.values.isEmpty else {
            super.setSelected(false, animated: false)
            return
        }
    }
    
    func renderForDisplay() {
        UIViewPropertyAnimator(duration: 1/3, curve: .easeOut) { [weak self] in
            guard let self = self else { return }
            self.selectionLabel.isHidden = true
            self.title.isHidden = false
            self.selectedValue.isHidden = false
            self.selectedBottomConstraint.isActive = true
            
            self.standardHeightConstraint.isActive = true
            self.pickerBottomConstriant.isActive = false
            self.pickerView.isHidden = true
        }.startAnimation()
    }
    
    
    func renderForSelection(){
        UIViewPropertyAnimator(duration: 1/3, curve: .easeIn) { [weak self] in
            guard let self = self else { return }
            self.title.isHidden = true
            self.selectedValue.isHidden = true
            self.selectedBottomConstraint.isActive = false
            self.selectionLabel.isHidden = false
            self.pickerView.isHidden = false
            self.standardHeightConstraint.isActive = false
            self.pickerBottomConstriant.isActive = true
            if let pickerValue = self.formValue {
                 self.pickerView.selectRow(pickerValue.selectedIndex, inComponent: 0, animated: true)
            }
        }.startAnimation()
    }
    
}


extension PickerSelectionCell: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
}

extension PickerSelectionCell: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerDataSource.isEmpty {
            return nil
        }
        
        if row > pickerDataSource.count-1 {
            return nil
        } else {
            return pickerDataSource[row]
        }
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let pickerValue = formValue {
            updateFormValueDelegate?.updatedFormValue(pickerValue.newWith(row), indexPath)
        }
       
        
    }
    
    
}
