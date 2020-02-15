import UIKit


// MARK: - TimeValue -
public struct TimeInputValue: Equatable, Hashable {
    let title:String
    let time:String
    public var customKey:String? = nil
  
}


// MARK: - Initilization -
extension TimeInputValue {
    
    public init(_ title: String,_ time:String) {
        self.title = title
        self.time = time
    }
    
    public init(_ title: String,_ time:String,_ customKey:String?) {
        self.title = title
        self.time = time
        self.customKey = customKey
    }
    
}



// MARK: - FormValue -
extension TimeInputValue: FormValue {
    
    public var formItem:FormItem {
        get {
            return FormItem.timeInput(self)
        }
    }
    
    public func encodedValue() -> [String : String] {
        return [customKey ?? title : time ]
    }
    
}



extension TimeInputValue {
    internal func timeIncrementBy(mins:Int) -> String {
        var hour = 0
        var minute = 0
        
        if let hourString = time.split(separator: ":").first {
            if let hourInt = Int(hourString) {
                hour = hourInt
            }
        }
        
        if let afterHourString = time.split(separator: ":").last {
            if let minsString = afterHourString.split(separator: " ").first {
                if let minInt = Int(minsString) {
                    minute = minInt
                }
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        
        if let incrementedDate = Calendar.current.date(byAdding: Calendar.Component.minute, value: mins, to: date, wrappingComponents: false) {
            let newtimeString = formatter.string(from: incrementedDate)
            return newtimeString
        } else {
            return "-:--"
        }
        
    }
}



// MARK: - FormValueDisplayable -
extension TimeInputValue: FormValueDisplayable {
    
    public typealias Cell = TimeInputCell
    public typealias Controller = FormController
    
    
    public var cellDescriptor: FormCellDescriptor {
        return .init(Cell.identifier, configureCell, didSelect)
    }

    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
//        formController.customTransitioningDelegate.descriptor = PresentationDescriptors.lowerThird()
//
//        let controller = TimeSelectionController(self)
//        controller.updateFormValueDelegate = formController
//        controller.indexPath = path
//        controller.minIncrement = 1
//
//
//        let navController = UINavigationController(rootViewController: controller)
//        if #available(iOS 11.0, *) {
//            navController.navigationBar.prefersLargeTitles = false
//        }
//
//        navController.transitioningDelegate = formController.customTransitioningDelegate
//        navController.modalPresentationStyle = .custom
//        formController.present(navController, animated: true, completion: nil)
    }
    
}


extension TimeInputValue {
    
    public static func Random() -> TimeInputValue {
        let randomHr = ["1","2","3","4","5","6","7","8","9","10","11","12"].randomElement()!
        let randomMin = Array(stride(from: 0, to: 60, by: 1)).map({String(format: "%02d", $0)}).randomElement()!
        let randomPeriod = ["AM","PM"].randomElement()!
        let randomTime = "\(randomHr):\(randomMin) \(randomPeriod)"
        return TimeInputValue(title: "Time", time: randomTime)
    }
    
    public static func Demo() -> TimeInputValue {
        return TimeInputValue(title: "Demo Time", time: "12:34 PM")
    }
    
}



//: MARK: TimeCell
public final class TimeInputCell: UITableViewCell {
    static let identifier = "FormKit.TimeInputCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
    
   private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.font = UIFont.preferredFont(forTextStyle: .headline)
        return textField
    }()
    
    var indexPath:IndexPath?
    
    var formValue:TimeInputValue? {
        didSet {
            if let timeValue = formValue {
                titleLabel.text = timeValue.title
                textField.text = timeValue.time
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [titleLabel,textField].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        textField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        
        let timeSelectionController = TimeSelectionController(TimeValue(formValue?.title ?? "-", formValue?.time ?? "12:34 PM"))
        //timeSelectionController.view.frame = CGRect(.zero, CGSize(UIScreen.main.bounds.width, 300))
        textField.inputView = timeSelectionController.view
        
        activateDefaultHeightAnchorConstraint()
        
        let margin = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            textField.centerYAnchor.constraint(equalTo: margin.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            ])
        
        accessoryType = .disclosureIndicator
        
        
        
        
    }
    
    @objc func textFieldTextChanged() {
        print("TimeInput textFieldTextChanged")
    }
    
}





class TimeInputKeyboard: UIInputView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 300), inputViewStyle: .keyboard)
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

