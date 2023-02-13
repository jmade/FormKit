
import UIKit


// MARK: - SliderValue -
public struct SliderValue {
    
    public var title:String = "Slider"
    public var value:Double = 22.0

    // MARK: - ValueType -
    public enum ValueType {
        case int,float
    }
    public var valueType:ValueType = .float
    public var decimalNumbers: Int = 2
    public var sliderConfig: (UISlider) -> Void = { slider in slider.minimumValue = 0.0; slider.maximumValue = 100.0 }
    
    public var customKey:String? = nil
    public var validators: [Validator] = []
    
    public var valueChangedClosure: ( (FormController,IndexPath,SliderValue) -> Void )?
    
    public var valueTransportClosure: ( (Double) -> String? )?
    
    public var enableAlertInput: Bool = false
    
    public var incrementAmount: Double = 1.0
    
    private var isHueSlider: Bool = false
}


extension SliderValue: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public var hash: Int {
        return "\(title)+\(value)+\(valueType)+\(decimalNumbers)+\(incrementAmount)".hashValue
    }
    
}

extension SliderValue: Equatable {
    public static func == (lhs: SliderValue, rhs: SliderValue) -> Bool {
        lhs.title == rhs.title && lhs.valueType == rhs.valueType && lhs.decimalNumbers == rhs.decimalNumbers && lhs.value == rhs.value && lhs.customKey == rhs.customKey && lhs.incrementAmount == rhs.incrementAmount && lhs.enableAlertInput == rhs.enableAlertInput
    }
    
    
}


extension SliderValue {
    
    var hueValue: Bool {
        isHueSlider
    }
    
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
    
    public init(title:String,hue:Int,_ customKey:String?) {
        self.isHueSlider = true
        self.title = title
        self.value = Double(hue)
        self.valueType = .int
        self.decimalNumbers = 0
        self.sliderConfig = {
            $0.minimumValue = 0
            $0.maximumValue = 359
        }
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
    
    
   public func newWith(_ value:Float) -> SliderValue {
        switch self.valueType {
        case .int:
            return SliderValue(title: self.title,
                               value: Double(value),
                               valueType: .int,
                               decimalNumbers: self.decimalNumbers,
                               sliderConfig: self.sliderConfig,
                               customKey: self.customKey,
                               valueChangedClosure: self.valueChangedClosure,
                               valueTransportClosure: self.valueTransportClosure,
                               incrementAmount: self.incrementAmount
            )
        case .float:
            return SliderValue(title: self.title,
                               value: Double(value),
                               valueType: .float,
                               decimalNumbers: self.decimalNumbers,
                               sliderConfig: self.sliderConfig,
                               customKey: self.customKey,
                               valueChangedClosure: self.valueChangedClosure,
                               valueTransportClosure: self.valueTransportClosure,
                               incrementAmount: self.incrementAmount
            )
        }
    }
    
    
    public func newWith(_ value:Double) -> SliderValue {
         switch self.valueType {
         case .int:
             return SliderValue(title: self.title,
                                value: value,
                                valueType: .int,
                                decimalNumbers: self.decimalNumbers,
                                sliderConfig: self.sliderConfig,
                                customKey: self.customKey,
                                valueChangedClosure: self.valueChangedClosure,
                                valueTransportClosure: self.valueTransportClosure,
                                enableAlertInput: self.enableAlertInput,
                                incrementAmount: self.incrementAmount
             )
         case .float:
             return SliderValue(title: self.title,
                                value: value,
                                valueType: .float,
                                decimalNumbers: self.decimalNumbers,
                                sliderConfig: self.sliderConfig,
                                customKey: self.customKey,
                                valueChangedClosure: self.valueChangedClosure,
                                valueTransportClosure: self.valueTransportClosure,
                                enableAlertInput: self.enableAlertInput,
                                incrementAmount: self.incrementAmount
             )
         }
         
     }
    
    
    var interpretedValue: String {
        guard
            let closure = valueTransportClosure,
            let transportValue = closure(value)
        else {
            switch self.valueType {
            case .int:
                return "\(Int(value))"
            case .float:
                return String(format: valueFormatString, value)
            }
        }
        
        return transportValue
    }
    
    
    public func displayValue(_ newValue:Float) -> String {
        switch self.valueType {
        case .int:
            return "\(Int(value))" //String(format: valueFormatString, Int(newValue))
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
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        }
        label.text = "-"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
        
        self.contentView.addSubview(label)
        return label
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(handleSlider(_:)), for: .valueChanged)
        //slider.addTarget(self, action: #selector(handleSliderTap(_:)), for: .touchUpInside)
        slider.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleSliderTap(_:)))
        )
        slider.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(slider)
        return slider
    }()
    

    var formValue : SliderValue? {
        didSet {
            guard let sliderValue = formValue else { return }
            if sliderValue.isSelectable == false {
                self.selectionStyle = .none
            }
            
            if sliderValue.hueValue {
                slider.isHidden = true
                gradientSlider.isHidden = false
                
                let hueValue = CGFloat(sliderValue.value/255.0)
                gradientSlider.thumbColor = UIColor(hue: hueValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                gradientSlider.setValue(hueValue)
                valueLabel.text = "\(Int(sliderValue.value))"
                lastValue = Float(hueValue)
            } else {
                slider.isHidden = false
                gradientSlider.isHidden = true
                
                sliderValue.sliderConfig(slider)
                slider.setValue(sliderValue.sliderValue, animated: true)
                valueLabel.text = sliderValue.displayValue(slider.value)
                lastValue = sliderValue.sliderValue
            }
            titleLabel.text = sliderValue.title
        }
    }
    
    private lazy var gradientSlider: GradientSlider = {
       let slider = GradientSlider()
        slider.minColor = .blue
        slider.hasRainbow = true
        slider.actionBlock = { slider, value, finished in
            //First disable animations so we get instantaneous updates
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            //Update hueSlider's thumb color to match our new value
            slider.thumbColor = UIColor(hue: value, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            // (Note: We use the slider variable passed instead of 'hueSlide' to avoid retain cycles)
            CATransaction.commit()
            
        }
        slider.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(slider)
        slider.addTarget(self, action: #selector(handleHueSlider(_:)), for: .valueChanged)
        //slider.addTarget(self, action: #selector(handleHueSliderTap(_:)), for: .touchUpInside)
        slider.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleHueSliderTap(_:)))
        )
        return slider
    }()
    
    
    private var lastValue:Float = .zero
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 2.0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            gradientSlider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.0),
            gradientSlider.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            gradientSlider.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            gradientSlider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
            
            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.0),
            slider.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
        ])
    }

    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.valueLabel.text = nil
    }
    
}



extension SliderCell {
    
    @objc private func handleTap() {
        guard let sliderValue = formValue else { return }
        
        guard sliderValue.enableAlertInput else {
            return
        }
        
        
        let gen = UIImpactFeedbackGenerator()
        gen.prepare()
        
        let slider = self.slider
        
        let alert = UIAlertController(title: sliderValue.title, message: "New Value", preferredStyle: .alert)
        
        alert.addTextField( configurationHandler: {
            $0.keyboardType = .decimalPad
            $0.placeholder = "\(Int(slider.value))"
        })
        
        let submitAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let tf = alert.textFields?.first else {
                return
            }
            
            if let text = tf.text {
                if let convertedValue = Float(text) {
                    slider.setValue(convertedValue, animated: true)
                    self?.lastValue = convertedValue
                    self?.handleValueChange(convertedValue)
                }
            }
            
        }
        
        alert.addAction(submitAction)
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        if #available(iOS 13.0, *) {
            gen.impactOccurred(intensity: 1.0)
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.show(alert, sender: nil)
        
    }
    
    
    
    
    @objc private func handleSliderTap(_ tap:UITapGestureRecognizer) {
        let tapLoc = tap.location(in: slider)
        let tapPercentage = tapLoc.x/slider.bounds.width
        let sliderRange = CGFloat(slider.maximumValue) - CGFloat(slider.minimumValue)
        let newValue = sliderRange * tapPercentage
        
        slider.setValue(Float(newValue), animated: true)
        interperateValue(Float(newValue))
    }
    
    @objc private func handleSlider(_ slider:UISlider) {
        interperateValue(slider.value)
    }
    
    @objc private func handleHueSliderTap(_ tap:UITapGestureRecognizer) {
        let tapLoc = tap.location(in: gradientSlider)
        let tapPercentage = tapLoc.x/gradientSlider.bounds.width
        let sliderRange = gradientSlider.maximumValue - gradientSlider.minimumValue
        let newValue = sliderRange * tapPercentage

        gradientSlider.setValue(newValue, animated: true)
        interperateValue(
            Float(
                newValue * 255.0
            )
        )
        gradientSlider.thumbColor = UIColor(hue: newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    
    @objc private func handleHueSlider(_ slider:GradientSlider) {
        interperateValue(
            Float(
                slider.value * 255.0
            )
        )
    }
    
    
    private func interperateValue(_ value:Float) {
        var diff: Float = 0.0
        if value > lastValue {
            diff = value - lastValue
        }
        if lastValue > value {
            diff = lastValue - value
        }
        if diff > 0.99 {
            handleValueChange(value)
            lastValue = value
        }
    }
    
    private func handleValueChange(_ value:Float) {
        guard let sliderValue = formValue else { return }
        if !sliderValue.matches(value) {
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


fileprivate extension CGFloat {
    func map(fromStart: CGFloat, fromEnd: CGFloat, toStart: CGFloat, toEnd: CGFloat) -> CGFloat {
        let result = ((self - fromStart) / (fromEnd - fromStart)) * (toEnd - toStart) + toStart
        return result
    }
}
