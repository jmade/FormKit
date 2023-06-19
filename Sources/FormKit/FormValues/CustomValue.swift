import UIKit


// MARK: - CustomValue -
public struct CustomValue {
    
    var identifier: UUID = UUID()
    public var customKey:String? = "CustomValue"
    
    public typealias CellConfigurationClosure = (CustomValue,CustomValueCell) -> Void
    public var cellConfigurationClosure:CellConfigurationClosure? = nil
    
    public typealias CustomValueSelectionClosure = ( (CustomValue,FormController,IndexPath) -> Void )
    public var selectionClosure:CustomValueSelectionClosure? = nil
    
    public typealias CellDidTapClosure = (CustomValue,CustomValueCell) -> Bool
    public var cellDidTapClosure:CellDidTapClosure? = nil
    
    public var validators: [Validator] = []
    
    public var customStore:[String:Any] = [:]
    
    public var attributedText:NSAttributedString?
    
    public var shouldShowCopyMenu: Bool = false
    
}


// init

public extension CustomValue {
    
    init(attributedText:NSAttributedString?) {
        self.attributedText = attributedText
        self.shouldShowCopyMenu = true
    }
    
    init(cellConfiguration: @escaping CellConfigurationClosure) {
        self.cellConfigurationClosure = cellConfiguration
    }
    
    init(cellConfiguration: @escaping CellConfigurationClosure, cellDidTap: @escaping CellDidTapClosure) {
        self.cellConfigurationClosure = cellConfiguration
        self.cellDidTapClosure = cellDidTap
    }
    
    init(cellConfiguration: @escaping CellConfigurationClosure, selectionClosure: @escaping CustomValueSelectionClosure) {
        self.cellConfigurationClosure = cellConfiguration
        self.selectionClosure = selectionClosure
    }
    
    func withNewIdentifier() -> CustomValue {
        var copy = self
        copy.identifier = UUID()
        return copy
    }
    
}


// MARK: - FormValue -
extension CustomValue: FormValue {

    public var formItem: FormItem {
        .custom(self)
    }
    
    public var contentValue:String {
        if let attributedText {
            return attributedText.string
        }
        return ""
    }
    
    public func encodedValue() -> [String : String] {
        [(customKey ?? "CustomValue") : contentValue]
    }
}


//: MARK: - FormValueDisplayable -
extension CustomValue: FormValueDisplayable {
    
    public typealias Cell = CustomValueCell
    public typealias Controller = FormController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.ReuseID, configureCell, didSelect)
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let selectedFormItem = formController.dataSource.itemAt(path) {
            switch selectedFormItem {
            case .custom(let customValue):
                selectionClosure?(customValue,formController,path)
            default:
                break
            }
        }
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
        cell.tableView = formController.tableView
        cell.formValue = self
    }
    
}





extension CustomValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: CustomValue, rhs: CustomValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


//: MARK: CustomValueCell
public final class CustomValueCell: UITableViewCell {
    
    static let ReuseID = "com.jmade.FormKit.CustomValueCell.identifier"
    
    var formValue : CustomValue? {
        didSet {
            guard let customValue = formValue else { return }
            customValue.cellConfigurationClosure?(customValue,self)
            if let attributedText = customValue.attributedText {
                contentHeightContraint.isActive = false
                attributedLabel.attributedText = attributedText
            }
            attributedLabel.isHidden = customValue.attributedText == nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
                self?.handleHeightUpdates()
            }
        }
    }
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    var indexPath:IndexPath?
    var tableView: UITableView?
    
    private let attributedLabel = UILabel()
    
    private var contentHeightContraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        attributedLabel.numberOfLines = 0
        attributedLabel.lineBreakMode = .byWordWrapping
        attributedLabel.translatesAutoresizingMaskIntoConstraints = false
        attributedLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        contentView.addSubview(attributedLabel)

        NSLayoutConstraint.activate([
            attributedLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            attributedLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: attributedLabel.trailingAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: attributedLabel.bottomAnchor),
        ])
        attributedLabel.isHidden = true
        
        contentHeightContraint = contentView.heightAnchor.constraint(equalToConstant: 44)
        contentHeightContraint.isActive = true
        
        
        
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        for subView in contentView.subviews {
            subView.removeFromSuperview()
        }
        formValue = nil
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard let customValue = formValue else { return }
        
        if selected {
            if let closure = customValue.cellDidTapClosure {
                if closure(customValue,self) {
                    handleHeightUpdates()
                }
            }
        }
        
    }
    
    
    private func handleHeightUpdates() {
        
        guard let customValue = formValue else { return }
        
        
        guard let attributedText = customValue.attributedText else {
            
            UIView.setAnimationsEnabled(false)
            self.tableView?.beginUpdates()
            for subView in contentView.subviews {
                subView.sizeToFit()
            }
            self.tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            return
        }
        
        
        UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.76) { [weak self] in
            self?.contentView.layoutIfNeeded()
        }.startAnimation()
        
    }
    
}





