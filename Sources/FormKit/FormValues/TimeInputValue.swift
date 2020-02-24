import UIKit


// MARK: - TimeValue -
public struct TimeInputValue: Equatable, Hashable {
    let title:String
    let time:String
    public var useDirectionButtons:Bool = true
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
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    public lazy var indexPath: IndexPath? = nil
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var textField: TimeInputTextField = {
        let textField = TimeInputTextField()
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.font = UIFont.preferredFont(forTextStyle: .headline)
        textField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        
        let inputView = TimeInputKeyboard()
        textField.inputView = inputView
        inputView.observer = textField
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        return textField
    }()
   
    
    var formValue:TimeInputValue? {
        didSet {
            if let timeValue = formValue {
                evaluateButtonBar()
                titleLabel.text = timeValue.title
                textField.text = timeValue.time
                
                //inputKeyboard.timeValue = timeValue
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activateDefaultHeightAnchorConstraint()
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            textField.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            ])
        accessoryType = .disclosureIndicator
        evaluateButtonBar()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textField.becomeFirstResponder()
        }
    }
    
    
    func evaluateButtonBar(){
        guard let timeInputValue = formValue else { return }
        if timeInputValue.useDirectionButtons {

            let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: 44.0)))
            let previous = UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction))
            let next = UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction))
            let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
            bar.items = [previous,next,.Flexible(),done]
            
            bar.sizeToFit()
            print("Assinging bar ")
            textField.inputAccessoryView = bar
        }
    }

    
    @objc
    func doneAction(){
        endTextEditing()
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
        textField.becomeFirstResponder()
    }
    
    @objc
    func textFieldTextChanged() {
        if let text = textField.text {
            print("Text: \(text)")
            /*
            guard let textValue = formValue else { return }
            updateFormValueDelegate?.updatedFormValue(
                textValue.newWith(text),
                indexPath
            )
            */
            
        }
    }
    
    private func endTextEditing(){
        textField.resignFirstResponder()
    }
    
    
    
    
}






protocol TimeInputKeyboardObserver: class {
    func add(_ string: String)
}


class TimeInputTextField: UITextField, TimeInputKeyboardObserver {
    func add(_ string: String) {
        self.text?.append(string)
    }
}



// MARK: - UIInputView -
class TimeInputKeyboard: UIInputView {
    
    /// Observers telling when keys were hit
    weak var observer: TimeInputKeyboardObserver?
    
    /// Time Setup?
    public var timeValue:TimeInputValue? {
        didSet {
            if let timeValue = timeValue {
                startingTime = timeValue.time
            }
        }
    }
    
    var startingTime:String? = nil
    var minIncrement: Int = 5
    
    private lazy var picker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        pickerView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        return pickerView
    }()
    
    private var dataSource: [[String]] = [
        ["1","2","3","4","5","6","7","8","9","10","11","12"],
        ["00","05","10","15","20","25","30","35","40","45","50","55"],
        ["AM","PM"]
    ]
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        let f = UIImpactFeedbackGenerator()
        f.prepare()
        return f
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 300), inputViewStyle: .keyboard)
        dataSource = generateDataSource()
        setTime()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        print("[FormKit](TimeInputKeyboard) `willMove(toSuperView)`  \(String(describing: newSuperview)) ")
    }
    
}


extension TimeInputKeyboard {
    
    
     private func generateDataSource() -> [[String]] {
         return [
             ["1","2","3","4","5","6","7","8","9","10","11","12"],
             stride(from: 0, to: 60, by: minIncrement).map({String(format: "%02d", $0)}),
             ["AM","PM"]
         ]
     }
     
     
     private func setTime() {
         
         if let startingTime = startingTime {
             let hourSplit = startingTime.split(":")
             if let hour = hourSplit.first {
                 if let index = dataSource[0].indexOf(hour) {
                     picker.selectRow(index, inComponent: 0, animated: true)
                 }
             }
             if let nextSplit = hourSplit.last {
                 let minSplit = nextSplit.split(" ")
                 if let mins = minSplit.first {
                     if let index = dataSource[1].indexOf(mins) {
                         picker.selectRow(index, inComponent: 1, animated: true)
                     }
                 }
                 if let meridan = minSplit.last {
                     if let index = dataSource[2].indexOf(meridan) {
                         picker.selectRow(index, inComponent: 2, animated: true)
                     }
                 }
             }
         } else {
             setToCurrentTime()
         }
             
        
         feedbackGenerator.impactOccurred()
     }
     
     
     
     private func setToCurrentTime() {
         
         func findIndexOf(_ value:String,in strings:[String]) -> Int {
             for (i, str) in strings.enumerated() {
                 if value == str {
                     return i
                 }
             }
             return 0
         }
         
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "h:mm a"
         let dateString = dateFormatter.string(from: Date())
         
         let dateTimeString = dateString.split(separator: " ").first!
         let hourString = String(dateTimeString.split(separator: ":").first!)
         let minString = String(dateTimeString.split(separator: ":").last!)
         let periodString = String(dateString.split(separator: " ").last!)
         
         let hourColumnIndex = findIndexOf(hourString, in: dataSource[0])
         let minColumnIndex = findIndexOf(minString, in: dataSource[1])
         let periodColumnIndex = findIndexOf(periodString, in: dataSource[2])
         
         picker.selectRow(hourColumnIndex, inComponent: 0, animated: true)
         picker.selectRow(minColumnIndex, inComponent: 1, animated: true)
         picker.selectRow(periodColumnIndex, inComponent: 2, animated: true)
     }
   
    
}


extension TimeInputKeyboard: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSource.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[component].count
    }
}


extension TimeInputKeyboard: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return dataSource[component][row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        /* do something cool here ??... */
    }
    
    func resolvePicker() {
        let selectedHour = dataSource[0][picker.selectedRow(inComponent: 0)]
        let selectedMins = dataSource[1][picker.selectedRow(inComponent: 1)]
        let period = dataSource[2][picker.selectedRow(inComponent: 2)]
        let resolvedTime = "\(selectedHour):\(selectedMins) \(period)"
        observer?.add(resolvedTime)
        
        /*
        updateFormValueDelegate?.updatedFormValue(
            TimeValue(title: title ?? "", time: "\(selectedHour):\(selectedMins) \(period)"),
            indexPath
        )
        */
 
    }
    
}




extension TimeInputKeyboard: UIInputViewAudioFeedback {
    /// Required for playing system click sound
    var enableInputClicksWhenVisible: Bool { return true }
}

