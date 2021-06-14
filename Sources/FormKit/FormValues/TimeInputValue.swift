import UIKit


extension FormItem {
    
    public func isTimeInputValue(_ timeInputValue:TimeInputValue? = nil) -> Bool {
           var isTimeInputValue:Bool = false
           switch self {
           case .timeInput(let tiv):
               if let inquiring = timeInputValue {
                   isTimeInputValue = inquiring.dataMatches(tiv)
               } else {
                   isTimeInputValue = true
               }
               break
           default:
               break
           }
           return isTimeInputValue
       }
       
       
       public func asTimeInputValue() -> TimeInputValue? {
           switch self {
           case .timeInput(let tiv):
               return tiv
           default:
               break
           }
           return nil
       }
    
}






// MARK: - TimeValue -
public struct TimeInputValue {
    
    public enum TimeFormat: String {
        case simple = "h:mm a"
        case simplehh = "hh:mm a"
        case simpleSS = "h:mm:ss a"
        case simplehhSS = "hh:mm:ss a"
        case military = "HH:mm"
        case militarySS = "HH:mm:ss"
    }
    
    var identifier: UUID = UUID()
    public let title:String
    public let time:String
    public var useDirectionButtons:Bool = true
    public var customKey:String?
    
    public var displayTimeFormat:TimeFormat = .simple
    public var exportTimeFormat:TimeFormat = .military
    
    public var isValid = true
    public var highlightWhenSelected = true
    
}


extension TimeInputValue {
    
    var isTwelveHourFormatted:Bool {
        time.contains("m") || time.contains("M")
    }
    
    var upperMeridian:Bool {
        time.contains("M")
    }
    
    var isMilitary:Bool {
        !isTwelveHourFormatted
    }
    
    var includesSeconds:Bool {
        time.filter({ $0 == ":" }).count > 1
    }
    
    var hourFormatString:String {
        time.first == "0" ? "%02d" : "%d"
    }
        
    public func log() {
        print(
        """
        --
        TimeValue: '\(title)': \(time)
        [ isTwelveHourFormatted: \(isTwelveHourFormatted) | isMilitary: \(isMilitary) | includesSeconds: \(includesSeconds) ]
        \(components)
        --
        \(durationLog)
        """
        )
    }
    
    
    var durationLog:String {
        """
        Duration ⏱:
        Total Hours: \(String(format: "%.2f", decodedDuration.converted(to: .hours).value))
        Total Mins: \(String(format: "%.2f", decodedDuration.converted(to:  .minutes).value))
        Total Seconds: \(Int(decodedDuration.converted(to: .seconds).value))
        Days: \(  String(format: "%.6f",decodedDuration.converted(to: .hours).value/Measurement(value: 24.0, unit: UnitDuration.hours).value ) )
        """
    }
    
    var seconds:Int {
        Int(decodedDuration.converted(to: .seconds).value)
    }
    
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
    
    
    public init(_ title:String,_ customKey:String,_ displayTimeFormat:TimeFormat,_ exportTimeFormat:TimeFormat,_ time:String) {
        self.title = title
        self.time = time
        self.customKey = customKey
        self.displayTimeFormat = displayTimeFormat
        self.exportTimeFormat = exportTimeFormat
    }

    
}



extension TimeInputValue {
    
    public func isBefore(_ tiv:TimeInputValue) -> Bool {
        seconds < tiv.seconds
    }
    
    public func isEarlierThan(_ tiv:TimeInputValue) -> Bool {
        seconds < tiv.seconds
    }
    
    
    
    public func isAfter(_ tiv:TimeInputValue) -> Bool {
        seconds > tiv.seconds
    }
    
    public func isLaterThan(_ tiv:TimeInputValue) -> Bool {
        seconds > tiv.seconds
    }
    
}



extension TimeInputValue {
    
    public func newWith(_ timeString:String) -> TimeInputValue {
        TimeInputValue(identifier: UUID(),
                       title: self.title,
                       time: timeString,
                       useDirectionButtons: self.useDirectionButtons,
                       customKey: self.customKey,
                       displayTimeFormat: self.displayTimeFormat,
                       exportTimeFormat: self.exportTimeFormat,
                       isValid: self.isValid,
                       highlightWhenSelected: self.highlightWhenSelected
        )
    }
    
    
    public func newByAdding(mins:Int) -> TimeInputValue {
        TimeInputValue(identifier: UUID(),
                       title: self.title,
                       time: self.timeIncrementBy(mins: mins),
                       useDirectionButtons: self.useDirectionButtons,
                       customKey: self.customKey,
                       displayTimeFormat: self.displayTimeFormat,
                       exportTimeFormat: self.exportTimeFormat,
                       isValid: self.isValid,
                       highlightWhenSelected: self.highlightWhenSelected
        )
    }
    
    
    public func invalidated() -> TimeInputValue {
        TimeInputValue(identifier: UUID(),
                       title: self.title,
                       time: self.time,
                       useDirectionButtons: self.useDirectionButtons,
                       customKey: self.customKey,
                       displayTimeFormat: self.displayTimeFormat,
                       exportTimeFormat: self.exportTimeFormat,
                       isValid: false,
                       highlightWhenSelected: self.highlightWhenSelected
        )
    }
    
    
    public func validated() -> TimeInputValue {
        TimeInputValue(identifier: UUID(),
                       title: self.title,
                       time: self.time,
                       useDirectionButtons: self.useDirectionButtons,
                       customKey: self.customKey,
                       displayTimeFormat: self.displayTimeFormat,
                       exportTimeFormat: self.exportTimeFormat,
                       isValid: true,
                       highlightWhenSelected: self.highlightWhenSelected
        )
    }
    
    
    public func dataMatches(_ tiv:TimeInputValue) -> Bool {
        customKey == tiv.customKey && time == tiv.time && title == tiv.title
    }
    
    
}


extension TimeInputValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: TimeInputValue, rhs: TimeInputValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


extension TimeInputValue {
    
    struct Components: CustomStringConvertible {
        let hours:Int
        let minutes:Int
        let seconds:Int
        enum Format {
            case am, pm, none
        }
        var format:Format = .none
        
        init(_ hours:Int,_ minutes:Int,_ seconds:Int? = nil,_ format:Format? = nil) {
            self.hours = hours
            self.minutes = minutes
            self.seconds = seconds ?? 0
            self.format = format ?? .none
        }
        
        
        var description: String {
            "Hours: \(hours) | Minutes: \(minutes) | Seconds: \(seconds) | Format: \(format)"
        }
        
        
        public func adding(_ comp:Components) -> Components {
            let newSeconds = self.seconds + comp.seconds
            let additionalMins = newSeconds/60
            
            let newMins = self.minutes + comp.minutes + additionalMins
            let additionalHours = newMins/60
            
            let newHours = self.hours + comp.hours + additionalHours
            
            return Components(newHours, newMins, newSeconds)
        }
    }
    
    
    var componentFormat:Components.Format {
        if time.contains("m") || time.contains("M") {
            if time.contains("a") || time.contains("A") {
                return .am
            } else {
                return .pm
            }
        } else {
            return .none
        }
    }
    
    
    var components:Components {
        
        var numericPortion = time
        if time.contains("m") || time.contains("M") {
            if let value = time.split(" ").first {
                numericPortion = value
            }
        }
        
        var h:Int = 0, m:Int = 0, s:Int = 0
        
        let decodedTimes = numericPortion.split(separator: ":").compactMap({ Int($0) })
        switch decodedTimes.count {
        case 3:
            for (i,v) in decodedTimes.enumerated() {
                switch i {
                case 0:
                    h = v
                case 1:
                    m = v
                default:
                    s = v
                }
            }
        case 2:
            for (i,v) in decodedTimes.enumerated() {
                switch i {
                case 0:
                    h = v
                default:
                    m = v
                }
            }
        default:
            break
        }
        
        return Components(h, m, s, componentFormat)
    }
    
    
    
    
    
}



extension TimeInputValue {
    
    public var decodedDuration:Measurement<UnitDuration> {
        var duration = Measurement(value: 0.0, unit: UnitDuration.hours)
        
        var numericPortion = time
        
        var hourModifer = 0
        
        switch componentFormat {
        case .am:
            if let val = time.split(" ").first {
                numericPortion = val
            }
        case .pm:
            if let val = time.split(" ").first {
                numericPortion = val
            }
            hourModifer = 12
        case .none:
            break
        }
        
        
        let decodedTimes = numericPortion.split(separator: ":").compactMap({ Double($0) })
        switch decodedTimes.count {
        case 3:
            for (i,v) in decodedTimes.enumerated() {
                switch i {
                case 0:
                    let measuredHours = Int(Measurement(value: v, unit: UnitDuration.hours).value)
                    if componentFormat == .am {
                        if measuredHours == 12 {
                            hourModifer = -12
                        }
                    }
                    
                    if componentFormat == .pm {
                        if measuredHours == 12 {
                            hourModifer = 0
                        }
                    }
                    
                    duration = duration + Measurement(value: v, unit: UnitDuration.hours) + Measurement(value: Double(hourModifer), unit: UnitDuration.hours)
                case 1:
                    duration = duration + Measurement(value: v, unit: UnitDuration.minutes)
                default:
                    duration = duration + Measurement(value: v, unit: UnitDuration.seconds)
                }
            }
        case 2:
            for (i,v) in decodedTimes.enumerated() {
                switch i {
                case 0:
                    let measuredHours = Int(Measurement(value: v, unit: UnitDuration.hours).value)
                    if componentFormat == .am {
                        if measuredHours == 12 {
                            hourModifer = -12
                        }
                    }
                    
                    if componentFormat == .pm {
                        if measuredHours == 12 {
                            hourModifer = 0
                        }
                    }
                    duration = duration + Measurement(value: v, unit: UnitDuration.hours) + Measurement(value: Double(hourModifer), unit: UnitDuration.hours)
                default:
                    duration = duration + Measurement(value: v, unit: UnitDuration.minutes)
                }
            }
        default:
            break
        }
        
        return duration
    }
    
    
}





extension TimeInputValue {
   
    var exportValue:String {
        
        switch exportTimeFormat {
        case .military:
            var hrs = 0
            var modifier = 0
            if componentFormat == .pm && components.hours != 12 {
                modifier = 12
            }
            
            hrs = (components.hours + modifier)
            
            if hrs == 24 || (componentFormat == .am && components.hours == 12) {
                hrs = 0
            }
            
            return "\(String(format: "%02d", hrs )):\(String(format: "%02d", components.minutes))"
        case .militarySS:
            var hrs = 0
            var modifier = 0
            if componentFormat == .pm && components.hours != 12 {
                modifier = 12
            }
            
            hrs = (components.hours + modifier)
            
            if hrs == 24 || (componentFormat == .am && components.hours == 12) {
                hrs = 0
            }
            return "\(String(format: "%02d", hrs)):\(String(format: "%02d", components.minutes)):\(String(format: "%02d", components.seconds))"
        case .simple:
            return "\(components.hours):\(String(format: "%02d", components.minutes)) \((componentFormat == .pm) ? "PM" : "AM")"
        case .simplehh:
            return "\(String(format: "%02d", components.hours)):\(String(format: "%02d", components.minutes)) \((componentFormat == .pm) ? "PM" : "AM")"
        case .simplehhSS:
            return "\(String(format: "%02d", components.hours)):\(String(format: "%02d", components.minutes)):\(String(format: "%02d", components.seconds)) \((componentFormat == .pm) ? "PM" : "AM")"
        case .simpleSS:
            return "\(components.hours):\(String(format: "%02d", components.minutes)):\(String(format: "%02d", components.seconds)) \((componentFormat == .pm) ? "PM" : "AM")"
            
        }
        
        
    }
   
    
    
    public var encodedTitle:String {
        customKey ?? title
    }
    
    public var isInvalid:Bool {
        !isValid
    }
    
    
    public func setTimeToDate(_ date:Date) -> Date? {
        let comp = self.components
        if let newDate = Calendar.current.date(bySettingHour: comp.hours, minute: comp.minutes, second: comp.seconds, of: date) {
            return newDate
        }
        return nil
    }

   
    
    /// Converts to Military Time/24 hour time from
    
    private func convertTimeValue(_ newTime:String) -> String {
           if newTime.contains("PM") {
               let timeVal = newTime.split(" ").first!
               let hourVal = timeVal.split(":").first!
               let mins = timeVal.split(":").last!
               var hrInt = Int(hourVal)!
               if hrInt == 12 {
                   hrInt = 0
               }
               if hrInt < 12 {
                   hrInt = hrInt + 12
               }
               let newTimeValue = "\(String(format: "%02d", hrInt)):\(mins)"
               return newTimeValue
           } else {
               let timeVal = newTime.split(" ").first!
               let hourVal = timeVal.split(":").first!
               let mins = timeVal.split(":").last!
               var hrInt = Int(hourVal)!
               if hrInt == 12 {
                   hrInt = 0
               }
               let newTimeValue = "\(String(format: "%02d", hrInt)):\(mins)"
               return newTimeValue
           }
       }
    
    
}



// MARK: - FormValue -
extension TimeInputValue: FormValue {
    
    public var formItem:FormItem {
            .timeInput(self)
    }
    
    
    public func encodedValue() -> [String : String] {
        return [customKey ?? title : exportValue /*convertTimeValue(time)*/ ]
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
        cell.updateFormValueDelegate = formController
        cell.indexPath = path
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
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
public final class TimeInputCell: UITableViewCell, Activatable {
    static let identifier = "com.jmade.FormKit.TimeInputCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    public lazy var indexPath: IndexPath? = nil
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var textField: TimeInputTextField = {
        let textField = TimeInputTextField()
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.tintColor = .clear
        textField.delegate = self
        textField.isUserInteractionEnabled = true
        if #available(iOS 13.0, *) {
            textField.textColor = .secondaryLabel
        } else {
            textField.textColor = .lightText
        }
        textField.newTimeStringClosure = { [weak self] (timeString) in
            self?.newTimeString(timeString)
        }
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        return textField
    }()

    
    var formValue:TimeInputValue? = nil {
        didSet {
            if let timeValue = formValue {
                if oldValue == nil {
                    evaluateButtonBar()
                    let inputView = TimeInputKeyboard(timeValue)
                    textField.inputView = inputView
                    inputView.observer = textField
                }
                textField.attributedText = attributedStringAdapter(timeValue,textField.isFirstResponder)
                titleLabel.text = timeValue.title
            } else {
                titleLabel.text = nil
                textField.text = nil
                textField.attributedText = nil
            }
        }
    }
    

    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activateDefaultHeightAnchorConstraint()
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            textField.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            ])
        accessoryType = .disclosureIndicator
        evaluateButtonBar()
    }
    
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        guard let timeValue = formValue else { return }
        
        if selected {
            if let input = textField.inputView as? TimeInputKeyboard {
                input.timeValue = timeValue
            } else {
                let inputView = TimeInputKeyboard(timeValue)
                textField.inputView = inputView
                inputView.observer = textField
            }
            textField.becomeFirstResponder()
        }
        
        super.setSelected(selected, animated: animated)
    }
    
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
    }
    
    
    func evaluateButtonBar(){
        
        guard let timeInputValue = formValue else { return }
        if timeInputValue.useDirectionButtons {
            let inputBarHeight: CGFloat = 22.0
            
            let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: inputBarHeight)))
            
            let inputLabel = UILabel(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width * 0.60, height: inputBarHeight)))
            inputLabel.text =  timeInputValue.title
            inputLabel.font = .preferredFont(forTextStyle: .body)
            inputLabel.textAlignment = .center
            if #available(iOS 13.0, *) {
                inputLabel.textColor = .secondaryLabel
            } else {
                inputLabel.textColor = .gray
            }
            let exp = UIBarButtonItem(customView: inputLabel)
            
            let previous = UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction))
            let next = UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction))
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
            bar.items = [previous,next,.Flexible(),exp,.Flexible(),done]
            
            bar.sizeToFit()
            textField.inputAccessoryView = bar
        }
    }

    
    @objc
    func doneAction(){
        textField.resignFirstResponder()
    }
    
    @objc
    func previousAction(){
        if let path = indexPath {
            updateFormValueDelegate?.toggleTo(.previous, path)
        }
    }
    
    @objc
    func nextAction(){
        if let path = indexPath {
            updateFormValueDelegate?.toggleTo(.next, path)
        }
    }
    
    public func activate(){
        FormConstant.makeSelectionFeedback()
        if let input = textField.inputView as? TimeInputKeyboard {
           input.timeValue = formValue
        }
        textField.becomeFirstResponder()
    }
    
  
    private func newTimeString(_ timeString:String) {
        if let timeInputValue = formValue {
            let newTimeInputValue = timeInputValue.newWith(timeString)
            self.formValue = newTimeInputValue
            updateFormValueDelegate?.updatedFormValue(newTimeInputValue, indexPath)
            
        }
    }
    
    public func setTimeInputValue(_ newValue:TimeInputValue) {
        self.formValue = newValue
    }
    
}


extension TimeInputCell: UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        animateTitleForSelection(isSelected: false)
        return true
    }
    
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        animateTitleForSelection(isSelected: true)
        return true
    }
}





extension TimeInputCell {
    
    private func attributedStringAdapter(_ timeValue:TimeInputValue,_ sel:Bool = false) -> NSAttributedString {
        
        let selected = timeValue.highlightWhenSelected ? sel : false
        
        if timeValue.isValid {
            return NSAttributedString(string: timeValue.time, attributes: [
                .font : UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor : selected ? UIColor.FormKit.inputSelected : UIColor.FormKit.valueText,
                .strikethroughStyle : NSNumber(integerLiteral: 0),
                .strikethroughColor : UIColor.clear
            ])
        } else {
            return NSAttributedString(string: timeValue.time, attributes: [
                .font : UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor : selected ? UIColor.FormKit.inputSelected : UIColor.FormKit.valueText,
                .strikethroughStyle : NSUnderlineStyle.single.rawValue,
                .strikethroughColor : UIColor.FormKit.delete
            ])
        }
    }
    
    
    func animateTitleForSelection(isSelected:Bool) {
        guard let time = formValue else { return }
        let newAttributedString = attributedStringAdapter(time,isSelected)
        UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.21) { [weak self] in
            guard let self = self else { return }
            self.textField.attributedText = newAttributedString
        }.startAnimation()
    }
    
}





// MARK: - TimeInputKeyboardObserver -
protocol TimeInputKeyboardObserver: AnyObject {
    func add(_ string: String)
}


// MARK: - TimeInputTextField -
class TimeInputTextField: UITextField, TimeInputKeyboardObserver {
    
    public var newTimeStringClosure: ((String) -> Void)? = nil
    
  
    func add(_ string: String) {
        self.text? = string
        self.newTimeStringClosure?(string)
    }
}



// MARK: - UIInputView -
class TimeInputKeyboard: UIInputView {
    
    /// Observers telling when keys were hit
    weak var observer: TimeInputKeyboardObserver?
    
    /// Time Setup?
    public var timeValue:TimeInputValue? {
        didSet {
            if let _ = timeValue {
                if dataSource.isEmpty {
                    dataSource = generateDataSource()
                }
            }
        }
    }
    
    var minIncrement: Int = 1
    var secondIncrement: Int = 1
    
    private lazy var picker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        pickerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        layoutMarginsGuide.bottomAnchor.constraint(equalTo: pickerView.bottomAnchor).isActive = true
        return pickerView
    }()
    
    
    private var dataSource: [[String]] = []
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        let f = UIImpactFeedbackGenerator()
        f.prepare()
        return f
    }()

    
    required init?(coder: NSCoder) { fatalError() }
    
    init(_ timeInputValue:TimeInputValue) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 230), inputViewStyle: .keyboard)
        self.timeValue = timeInputValue
        dataSource = generateDataSource()
    }

    
    override func willMove(toSuperview newSuperview: UIView?) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            picker.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        super.willMove(toSuperview: newSuperview)
        loadPickers()
    }
    
    
    
}


extension TimeInputKeyboard {
    
    private func generateDataSource() -> [[String]] {
        
        guard let timeValue = timeValue else { return [] }
        var data:[[String]] = []
        
        if timeValue.isMilitary {
            data = [
                stride(from: 0, to: 24, by: 1).map({String(format: "%02d", $0)}),
                stride(from: 0, to: 60, by: minIncrement).map({String(format: "%02d", $0)}),
            ]
            if timeValue.includesSeconds {
                data.append(
                    stride(from: 0, to: 60, by: secondIncrement).map({String(format: "%02d", $0)})
                )
            }
        } else {
            data = [
                stride(from: 1, to: 13, by: 1).map({String(format: timeValue.hourFormatString, $0)}),
                stride(from: 0, to: 60, by: minIncrement).map({String(format: "%02d", $0)}),
            ]
            if timeValue.includesSeconds {
                data.append(
                    stride(from: 0, to: 60, by: secondIncrement).map({String(format: "%02d", $0)})
                )
            }
            
            timeValue.upperMeridian ? data.append(["AM","PM"]) : data.append(["am","pm"])
        }
        
        return data
    }
}





// MARK: - UIPickerViewDataSource -
extension TimeInputKeyboard: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSource.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[component].count
    }
}


// MARK: - UIPickerViewDelegate -
extension TimeInputKeyboard: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return dataSource[component][row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        resolvePicker()
    }
    
    
    func resolvePicker() {
        guard let timeValue = timeValue else { return }
        
        var time = ""
        
        for (i,_) in dataSource.enumerated() {
            
            if !timeValue.includesSeconds && timeValue.isTwelveHourFormatted {
                if i == 2 {
                    time += " "
                }
            }
            
            time += dataSource[i][picker.selectedRow(inComponent: i)]
            
            if i == 0 {
                time += ":"
            }
            
            if timeValue.includesSeconds {
                if i == 1 {
                    time += ":"
                }
            }
            
            if timeValue.includesSeconds && timeValue.isTwelveHourFormatted {
                if i == 2 {
                    time += " "
                }
            }
            
        }
        
        observer?.add(time)

    }
    
}




extension TimeInputKeyboard: UIInputViewAudioFeedback {
    /// Required for playing system click sound
    var enableInputClicksWhenVisible: Bool { return true }
}



// MARK: - Setting Pickers -
extension TimeInputKeyboard {
    
    private func loadPickers() {
        guard let timeValue = timeValue, !dataSource.isEmpty else { return }
        let picker = self.picker
        let animated = false
        
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.76) {
            if timeValue.isMilitary {
                picker.selectRow(timeValue.components.hours, inComponent: 0, animated: animated)
                picker.selectRow(timeValue.components.minutes, inComponent: 1, animated: animated)
                if timeValue.includesSeconds {
                    picker.selectRow(timeValue.components.seconds, inComponent: 2, animated: animated)
                }
            } else {
                picker.selectRow(timeValue.components.hours-1, inComponent: 0, animated: animated)
                picker.selectRow(timeValue.components.minutes, inComponent: 1, animated: animated)
                
                if timeValue.includesSeconds {
                    picker.selectRow(timeValue.components.seconds, inComponent: 2, animated: animated)
                    
                    picker.selectRow(
                        (timeValue.componentFormat == .pm) ? 1 : 0,
                        inComponent: 3,
                        animated: animated
                    )
                } else {
                    picker.selectRow(
                        (timeValue.componentFormat == .pm) ? 1 : 0,
                        inComponent: 2,
                        animated: animated
                    )
                }
            }
        }.startAnimation()
    }
    
}
