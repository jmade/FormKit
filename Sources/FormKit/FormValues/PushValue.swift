
import UIKit

// MARK: - PushValue -
public struct PushValue {
    var identifier: UUID = UUID()
    
    public var customKey:String? = "PushValue"
    
    public var primary:String? = nil
    public var secondary: String? = nil
    
    public typealias PushValueSelectionClosure = ( (PushValue,FormController,IndexPath) -> Void )
    public typealias PushValueActionClosure = ( (PushValue) -> Void )
    
    public var selectionClosure: PushValueSelectionClosure? = nil
    public var actionClosure: PushValueActionClosure? = nil
    public var model:Any? = nil
    public var params:[String:String]? = nil
    
    public enum State {
        case selected, notSelected
    }
    public var state:State = .notSelected
    
    public enum Style {
        case standard, selectable
    }
    public var style:Style = .standard
    public var cellAccessoryType: UITableViewCell.AccessoryType = .disclosureIndicator
    private var isLoading = false
    public var validators: [Validator] = []
}


extension PushValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: PushValue, rhs: PushValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}



public extension PushValue {
    
    init(_ primary:String? = nil,_ secondary: String? = nil,_ model:Any? = nil,selectionClosure: @escaping PushValueSelectionClosure) {
        self.primary = primary
        self.secondary = secondary
        self.model = model
        self.selectionClosure = selectionClosure
    }
    
    init(_ primary:String? = nil,_ secondary: String? = nil,_ params:[String:String]? = nil,selectionClosure: @escaping PushValueSelectionClosure) {
        self.primary = primary
        self.secondary = secondary
        self.params = params
        self.selectionClosure = selectionClosure
    }
    
    
    init(_ primary:String, actionClosure: @escaping PushValueActionClosure) {
        self.primary = primary
        self.actionClosure = actionClosure
        self.cellAccessoryType = .none
    }
    
    
    init(_ primary:String,_ secondary: String? = nil,_ cellAccessoryType: UITableViewCell.AccessoryType,actionClosure: @escaping PushValueActionClosure) {
        self.primary = primary
        self.secondary = secondary
        self.actionClosure = actionClosure
        self.cellAccessoryType = cellAccessoryType
    }
    
    
    init(_ primary:String,_ model:Any,_ cellAccessoryType: UITableViewCell.AccessoryType ,actionClosure: @escaping PushValueActionClosure) {
        self.primary = primary
        self.model = model
        self.actionClosure = actionClosure
        self.cellAccessoryType = cellAccessoryType
    }
    
    /// Selectable
    init(_ primary:String,_ secondary:String,_ state:State,actionClosure: @escaping PushValueActionClosure) {
        self.primary = primary
        self.secondary = secondary
        self.state = state
        self.actionClosure = actionClosure
        self.cellAccessoryType = .none
        self.style = .selectable
    }
    
    init(_ primary:String,_ state:State,actionClosure: @escaping PushValueActionClosure) {
        self.primary = primary
        self.secondary = nil
        self.state = state
        self.actionClosure = actionClosure
        self.cellAccessoryType = .none
        self.style = .selectable
    }
    
    init(_ title:String,_ isSelected:Bool,_ subTitle:String? = nil,_ model:Any? = nil) {
        self.primary = title
        self.secondary = subTitle
        self.state = isSelected ? .selected : .notSelected
        self.model = model
        self.cellAccessoryType = .none
        self.style = .selectable
    }
    
}

extension PushValue {
    
    public var shouldShowIndicator:Bool {
        isLoading
    }
    
    public func loading() -> PushValue {
        var copy = self
        copy.isLoading = true
        return copy
    }
    
    public func notLoading() -> PushValue {
        var copy = self
        copy.isLoading = false
        return copy
    }
    
}



// MARK: - FormValue -
extension PushValue: FormValue {
    
    var idKey: String {
        return "\(identifier.uuidString.split(separator: "-")[1])"
    }
    
    public var formItem: FormItem {
        .push(self)
    }
    
    public func encodedValue() -> [String : String] {
        switch self.style {
        case .selectable:
            switch self.state {
            case .notSelected:
                return [primary ?? "PushValue_\(idKey)" : "notSelected" ]
            case .selected:
                return [primary ?? "PushValue_\(idKey)" : "selected" ]
            }
        case .standard:
            return params ?? [:]
        }
    }
    
}


public extension PushValue {
    
    func toggledState() -> PushValue {
        var copy = self
        switch self.state {
        case .notSelected:
            copy.state = .selected
        case .selected:
            copy.state = .notSelected
        }
        return copy
    }
    
}


extension PushValue: TableViewSelectable {
    
    public var isSelectable: Bool {
        style != .selectable
    }
    
}




// MARK: - FormValueDisplayable -
extension PushValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = PushValueCell
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor("\(Cell.identifier)-\(idKey)", configureCell, didSelect)
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
        if let selectedFormItem = formController.dataSource.itemAt(path) {
            switch selectedFormItem {
            case .push(let pushValue):
                
                guard pushValue.isLoading == false else {
                    return
                }
                
                selectionClosure?(pushValue,formController,path)
                actionClosure?(pushValue)
                
                if pushValue.style == .selectable {
                    formController.feedback(.lightImpact)
                    formController.dataSource.updateWith(formValue: self.toggledState(), at: path)
                    formController.tableView.reloadRows(at: [path], with: .none)
                    formController.dataSource.setNeedsUpdate()
                }
            default:
                break
            }
        }
        
    }
    
}




// MARK: PushValueCell
final public class PushValueCell: UITableViewCell {
    static let identifier = "com.jmade.FormKit.PushValueCell.identifier"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    var formValue: PushValue? {
        didSet {
            if let push = formValue {
                switch push.style {
                case .selectable:
                    switch push.state {
                    case .selected:
                        indicatorView.image = HeaderValue.Image.checkmarkFilled
                        indicatorView.tintColor = .success
                    case .notSelected:
                        indicatorView.image = HeaderValue.Image.checkmark
                        indicatorView.tintColor = UIColor.FormKit.valueText
                    }
                case .standard:
                    indicatorView.image = nil
                    indicatorView.tintColor = nil
                    accessoryType = push.cellAccessoryType
                }
                
                if push.shouldShowIndicator {
                    loadingView.startAnimating()
                } else {
                    loadingView.stopAnimating()
                }
            }
            primaryTextLabel.text = formValue?.primary
            secondaryTextLabel.text = formValue?.secondary
        }
    }
    
    
    lazy var loadingView: UIActivityIndicatorView = {
        let progressView = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            progressView.style = .medium
        } else {
            progressView.style = .gray
        }
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.hidesWhenStopped = true
        progressView.stopAnimating()
        contentView.addSubview(progressView)
        progressView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        return progressView
    }()
    
    
    lazy var primaryTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    
    lazy var secondaryTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle:  .caption2).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.textColor = UIColor.FormKit.valueText
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    
    private lazy var indicatorView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.FormKit.text
        if #available(iOS 13.0, *) {
            imageView.preferredSymbolConfiguration = .init(textStyle: .title2, scale: .medium)
        } else {
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 36.0).isActive = true
        }
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        contentView.addSubview(imageView)
        imageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        return imageView
    }()
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
       
       override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)
           
           let defaultTableViewCellHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
           defaultTableViewCellHeightConstraint.priority = UILayoutPriority(501)
           
           NSLayoutConstraint.activate([
            defaultTableViewCellHeightConstraint,
            primaryTextLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            primaryTextLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            primaryTextLabel.trailingAnchor.constraint(equalTo: indicatorView.leadingAnchor),
            secondaryTextLabel.topAnchor.constraint(equalTo: primaryTextLabel.bottomAnchor),
            secondaryTextLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            secondaryTextLabel.trailingAnchor.constraint(equalTo: indicatorView.leadingAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: secondaryTextLabel.bottomAnchor),
           ])
       }
    
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        guard let push = formValue, push.shouldShowIndicator else {
            super.setSelected(selected, animated: animated)
            return
        }
        super.setSelected(false, animated: false)
    }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        primaryTextLabel.text = nil
        secondaryTextLabel.text = nil
        indicatorView.image = nil
        loadingView.stopAnimating()
    }
    
    
    public func configureCell(_ pushValue:PushValue) {
        formValue = pushValue
    }
    
}
