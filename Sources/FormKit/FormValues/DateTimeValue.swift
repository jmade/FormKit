//
//  File.swift
//  
//
//  Created by Justin Madewell on 4/8/21.
//


import UIKit




extension FormItem {
    
    public func isDateTimeValue(_ dateTimeValue:DateTimeValue? = nil) -> Bool {
           var isDateTimeValue:Bool = false
           switch self {
           case .dateTime(let dtv):
               if let inquiring = dateTimeValue {
                   isDateTimeValue = inquiring.dataMatches(dtv)
               } else {
                   isDateTimeValue = true
               }
               break
           default:
               break
           }
           return isDateTimeValue
       }
    
    
}



// MARK: - DateTimeValue -
public struct DateTimeValue {
    let identifier: UUID = UUID()
    
    public var title:String
    
    public var timeValue:TimeInputValue?
    public var dateValue:DatePickerValue?
    public var displayFormat:String = "MMM dd, y hh:mm a"
    public var value:String
    
    /// TableSelectable
    public var isSelectable: Bool = true
    public var customKey:String?
    public var useDirectionButtons:Bool = true
    
    public var isValid = true
    public var highlightWhenSelected = false /// this is reffering to the value label.
}




extension DateTimeValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: DateTimeValue, rhs: DateTimeValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


extension DateTimeValue {
    
    public var minDate:Date? {
        dateValue?.minDate
    }
    
    public var maxDate:Date? {
        dateValue?.maxDate
    }
    
    
    public var exportValue: String {
        "\(dateValue?.exportValue ?? "") \(timeValue?.exportValue ?? "")"
    }
    
    public var isInvalid:Bool {
        !isValid
    }
    
    public var encodedTitle:String {
        customKey ?? title
    }
    
    
    public func newWith(_ dateTimeString:String) -> DateTimeValue {
        DateTimeValue(title: self.title,
                      timeValue: self.timeValue,
                      dateValue: self.dateValue,
                      displayFormat: self.displayFormat,
                      value: dateTimeString,
                      isSelectable: self.isSelectable,
                      customKey: self.customKey,
                      useDirectionButtons: self.useDirectionButtons,
                      isValid: self.isValid,
                      highlightWhenSelected: self.highlightWhenSelected
        )
    }
    
}



// MARK: - FormValue -
extension DateTimeValue: FormValue {
   
    
    public var formItem:FormItem {
        .dateTime(self)
    }
    
    
    public func encodedValue() -> [String : String] {
        return [customKey ?? title : exportValue ]
    }
    
}



// MARK: - FormValueDisplayable -
extension DateTimeValue: FormValueDisplayable {
    
    public typealias Cell = DateTimeCell
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



/// Validation

extension DateTimeValue {
    
    public func dataMatches(_ dtv:DateTimeValue) -> Bool {
        customKey == dtv.customKey && title == dtv.title
    }
    
    public func invalidated() -> DateTimeValue {
        DateTimeValue(title: self.title,
                      timeValue: self.timeValue,
                      dateValue: self.dateValue,
                      displayFormat: self.displayFormat,
                      value: self.value,
                      isSelectable: self.isSelectable,
                      customKey: self.customKey,
                      useDirectionButtons: self.useDirectionButtons,
                      isValid: false,
                      highlightWhenSelected: self.highlightWhenSelected
        )
    }
    
    
    public func validated() -> DateTimeValue {
        DateTimeValue(title: self.title,
                      timeValue: self.timeValue,
                      dateValue: self.dateValue,
                      displayFormat: self.displayFormat,
                      value: self.value,
                      isSelectable: self.isSelectable,
                      customKey: self.customKey,
                      useDirectionButtons: self.useDirectionButtons,
                      isValid: true,
                      highlightWhenSelected: self.highlightWhenSelected
        )
    }
    
    
}







//: MARK: DateTimeCell
public final class DateTimeCell: UITableViewCell, Activatable {
    static let identifier = "com.jmade.FormKit.DateTimeCell"
    
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
    
    private lazy var textField: DateTimeInputTextField = {
        let textField = DateTimeInputTextField()
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

    
    var formValue:DateTimeValue? = nil {
        didSet {
            if let timeValue = formValue {
                if oldValue == nil {
                    evaluateButtonBar()
                    let inputView = DateTimeInputKeyboard(timeValue)
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
        guard let dateTimeValue = formValue else { return }
        
        if selected {
            if let input = textField.inputView as? DateTimeInputKeyboard {
                input.dateTimeValue = dateTimeValue
            } else {
                let inputView = DateTimeInputKeyboard(dateTimeValue)
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
        
        guard let dateTimeValue = formValue else { return }
        if dateTimeValue.useDirectionButtons {
            let inputBarHeight: CGFloat = 22.0
            
            let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: inputBarHeight)))
            
            let inputLabel = UILabel(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width * 0.60, height: inputBarHeight)))
            inputLabel.text =  dateTimeValue.title
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
            bar.items = [previous,next,.flexible,exp,.flexible,done]
            
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
        if let input = textField.inputView as? DateTimeInputKeyboard {
           input.dateTimeValue = formValue
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
    
    public func setDateTimeValue(_ newValue:DateTimeValue) {
        self.formValue = newValue
    }
    
}


extension DateTimeCell: UITextFieldDelegate {
    
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





extension DateTimeCell {
    
    private func attributedStringAdapter(_ dateTime:DateTimeValue,_ sel:Bool = false) -> NSAttributedString {
        
        let selected = dateTime.highlightWhenSelected ? sel : false
        
        if dateTime.isValid {
            return NSAttributedString(string: dateTime.value, attributes: [
                .font : UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor : selected ? UIColor.FormKit.inputSelected : UIColor.FormKit.valueText,
                .strikethroughStyle : NSNumber(integerLiteral: 0),
                .strikethroughColor : UIColor.clear
            ])
        } else {
            return NSAttributedString(string: dateTime.value, attributes: [
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











// MARK: - DateTimeInputKeyboardObserver -
protocol DateTimeInputKeyboardObserver: AnyObject {
    func add(_ string: String)
}


// MARK: - TimeInputTextField -
class DateTimeInputTextField: UITextField, DateTimeInputKeyboardObserver {
    
    public var newTimeStringClosure: ((String) -> Void)? = nil
    
  
    func add(_ string: String) {
        self.text? = string
        self.newTimeStringClosure?(string)
    }
}



// MARK: - UIInputView -
class DateTimeInputKeyboard: UIInputView {
    
    /// Observers telling when keys were hit
    weak var observer: DateTimeInputKeyboardObserver?
    
    
    private let dateFromatter = DateFormatter()
    
    public var dateTimeValue:DateTimeValue? {
        didSet {
            if let _ = dateTimeValue {
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
    
    init(_ dateTimeValue:DateTimeValue) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 230), inputViewStyle: .keyboard)
        self.dateTimeValue = dateTimeValue
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


extension DateTimeInputKeyboard {
    
    private func generateDateStrings(_ startingAt:Date,_ rangeAmount:Int = 30) -> [String] {
        
        dateFromatter.dateFormat = "MMM dd, y"
        var data:[String?] = []
        
        var date = startingAt.previousDay()
        
        Array(0...rangeAmount).forEach({ _ in
            data.append(
                dateFromatter.string(from: date)
            )
           date = date.previousDay()
        })
        
        data = data.reversed()
 
        data.append(dateFromatter.string(from: startingAt))
        
        date = startingAt.nextDay()
        
        Array(0...rangeAmount).forEach({ _ in
            data.append(
                dateFromatter.string(from: date)
            )
           date = date.nextDay()
        })
        
        return data.compactMap({ $0 })
    }
    
    
    
}


extension DateTimeInputKeyboard {
    
    private func generateDataSource() -> [[String]] {
        generateDateDataSource() + generateTimeDataSource()
    }
    
    
    private func generateDateDataSource() -> [[String]] {
        guard let startDate = dateTimeValue?.dateValue?.date else { return [] }
        return [generateDateStrings(startDate)]
    }
    
    
    private func generateTimeDataSource() -> [[String]] {
        
        guard let timeValue = dateTimeValue?.timeValue else { return [] }
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
extension DateTimeInputKeyboard: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSource.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[component].count
    }
}


// MARK: - UIPickerViewDelegate -
extension DateTimeInputKeyboard: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return dataSource[component][row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        resolvePicker()
    }
    
    
    
    
    
    func resolvePicker() {
        
        guard let timeValue = dateTimeValue?.timeValue else { return }
        
        var time = ""
        
        var data = dataSource
        
//        var timeData: [[String]] = []
//        var dateData: [[String]] = []
//        
//        for (i,dataSet) in dataSource.enumerated() {
//            if i == 0 {
//                
//            } else {
//                timeData.append(dataSet)
//            }
//        }
       
        
        
        let dates = data[0]
        
        time = dates[picker.selectedRow(inComponent: 0)]
        time += " "
        
        
        data = Array(data.dropFirst())
        
        for (i,_) in data.enumerated() {
            
            if !timeValue.includesSeconds && timeValue.isTwelveHourFormatted {
                if i == 2 {
                    time += " "
                }
            }
            
            time += dataSource[i][picker.selectedRow(inComponent: i+1)]
            
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




extension DateTimeInputKeyboard: UIInputViewAudioFeedback {
    /// Required for playing system click sound
    var enableInputClicksWhenVisible: Bool { return true }
}



// MARK: - Setting Pickers -
extension DateTimeInputKeyboard {
    
    private func loadPickers() {
        guard let timeValue = dateTimeValue?.timeValue, !dataSource.isEmpty else { return }
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



