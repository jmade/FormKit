
import UIKit


// MARK: - SliderValue -
public struct SliderValue {

    // MARK: - ValueType -
    public enum ValueType {
        case int,float
    }
    public var valueType:ValueType = .float
    public var decimalNumbers: Int = 2
    public var sliderConfig: (UISlider) -> Void = { slider in slider.minimumValue = 0.0; slider.maximumValue = 100.0 }
    public var title:String = "Slider"
    public var value:Double = 22.0
    public var customKey:String? = nil
}


extension SliderValue: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public var hash: Int {
        return "\(title)+\(value)+\(valueType)+\(decimalNumbers)".hashValue
    }
    
}

extension SliderValue: Equatable {
    public static func == (lhs: SliderValue, rhs: SliderValue) -> Bool {
        lhs.title == rhs.title && lhs.valueType == rhs.valueType && lhs.decimalNumbers == rhs.decimalNumbers && lhs.value == rhs.value && lhs.customKey == rhs.customKey
    }
    
    
}


extension SliderValue {
    
    public init(_ title:String,value:Double) {
        self.title = title
        self.value = value
    }
    
    /// `Float`
    public init(floatValue title:String, value:Double,_ decimalNumbers: Int = 2) {
        self.title = title
        self.value = value
        self.valueType = .float
        self.decimalNumbers = decimalNumbers
    }
    
    public init(floatValue title:String, value:Double,_ sliderConfig: @escaping (UISlider) -> Void) {
        self.title = title
        self.value = value
        self.valueType = .float
        self.sliderConfig = sliderConfig
    }
    
    public init(floatValue title:String, value:Double, decimalNumbers: Int = 2,sliderConfig: @escaping (UISlider) -> Void) {
        self.title = title
        self.value = value
        self.valueType = .float
        self.decimalNumbers = decimalNumbers
        self.sliderConfig = sliderConfig
    }
    
    public init(floatValue title:String, value:Double,_ decimalNumbers: Int = 2,_ sliderConfig: @escaping (UISlider) -> Void) {
        self.title = title
        self.value = value
        self.valueType = .float
        self.decimalNumbers = decimalNumbers
        self.sliderConfig = sliderConfig
    }
    
    
    /// `Int`
    public init(intValue title:String, value:Int) {
        self.title = title
        self.value = Double(value)
        self.valueType = .int
    }
    
    public init(intValue title:String, value:Int, sliderConfig: @escaping (UISlider) -> Void) {
        self.title = title
        self.value = Double(value)
        self.valueType = .int
        self.sliderConfig = sliderConfig
    }
    
    public init(intValue title:String, value:Int,_ sliderConfig: @escaping (UISlider) -> Void) {
        self.title = title
        self.value = Double(value)
        self.valueType = .int
        self.sliderConfig = sliderConfig
    }
    
    public init(title:String, value:Double, valueType:ValueType, decimalNumbers:Int, sliderConfig: @escaping (UISlider) -> Void, customKey:String?) {
        self.title = title
        self.value = value
        self.valueType = valueType
        self.decimalNumbers = decimalNumbers
        self.sliderConfig = sliderConfig
        self.customKey = customKey
    }

    
}


extension SliderValue {
    
    var sliderValue:Float {
        Float(value)
    }
    
    
    public var valueFormatString: String {
        switch valueType {
        case .int:
            return "%02d"
        case .float:
            return "%.\(decimalNumbers)f"
        }
    }
    
    
    func newWith(_ value:Float) -> SliderValue {
        switch self.valueType {
        case .int:
            return SliderValue(title: self.title,
                               value: Double(value),
                               valueType: .int,
                               decimalNumbers: self.decimalNumbers,
                               sliderConfig: self.sliderConfig,
                               customKey: self.customKey
            )
        case .float:
            return SliderValue(title: self.title,
                               value: Double(value),
                               valueType: .float,
                               decimalNumbers: self.decimalNumbers,
                               sliderConfig: self.sliderConfig,
                               customKey: self.customKey
            )
        }
    }
    
    
    var interpretedValue: String {
        switch self.valueType {
        case .int:
            return "\(Int(value))"
        case .float:
            return String(format: valueFormatString, value)
        }
    }
    
    
    
    public func displayValue(_ newValue:Float) -> String {
        switch self.valueType {
        case .int:
            return "\(Int(newValue))"
        case .float:
            return String(format: valueFormatString, newValue)
        }
    }
    
    
    public func matches(_ value:Float) -> Bool {
        switch self.valueType {
        case .int:
            return Int(self.value) == Int(value)
        case .float:
            return String(format: valueFormatString, value) == interpretedValue
        }
    }
    
}








// MARK: - FormValue -

extension SliderValue: FormValue, TableViewSelectable {
    public func encodedValue() -> [String : String] {
           return [ (customKey ?? title) : "\(interpretedValue)" ]
       }
       
       public var isSelectable: Bool {
           return false
       }
       
       public var formItem: FormItem {
           return FormItem.slider(self)
       }
}


extension SliderValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = SliderCell
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}


extension SliderValue {
    public static func Random() -> SliderValue {
        SliderValue(intValue: "Slider", value: 22, sliderConfig: { (slider:UISlider) in
            slider.minimumValue = 1.0
            slider.maximumValue = 100.0
            slider.thumbTintColor = .systemTeal
        })
    }
}




// MARK: SliderCell
public final class SliderCell: UITableViewCell {
    static let identifier = "FormKit.SliderCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    public lazy var indexPath: IndexPath? = nil
    
    private lazy var feedbackGenerator: UISelectionFeedbackGenerator = {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        return generator
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "-"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        return label
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(handleSlider(_:)), for: .valueChanged)
        self.contentView.addSubview(slider)
        return slider
    }()
    
    var formValue : SliderValue? {
        didSet {
            guard let sliderValue = formValue else { return }
            if sliderValue.isSelectable == false {
                self.selectionStyle = .none
            }
            
            if oldValue == nil {
                sliderValue.sliderConfig(slider)
                titleLabel.text = sliderValue.title
                slider.setValue(sliderValue.sliderValue, animated: true)
                valueLabel.text = String(format: sliderValue.valueFormatString, slider.value )
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 2.0),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.0),
            slider.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0),
        ])
    }

    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.valueLabel.text = nil
    }
    
}


extension SliderCell {
    
    @objc private func handleSlider(_ slider:UISlider) {
        interperateValue(slider.value)
    }

    
    private func interperateValue(_ value:Float) {
        guard let sliderValue = formValue else { return }
        if sliderValue.matches(value) == false {
            let newSliderValue = sliderValue.newWith(value)
            valueLabel.text = newSliderValue.displayValue(value)
            feedbackGenerator.selectionChanged()
            updateFormValueDelegate?.updatedFormValue(
                newSliderValue,
                indexPath
            )
        }
    }
    
    
}
