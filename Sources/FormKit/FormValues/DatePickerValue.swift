
import Foundation



// MARK: - DatePickerValue -
public struct DatePickerValue {
    let identifier: UUID = UUID()
    public var title:String?
    public var date:Date
    public var dateFormat = "yyyy-MM-dd"
    public var exportDateFormat:String?
    public var displayDateFormat:String?
    /// TableSelectable
    public var isSelectable: Bool = true
    public var customKey:String? = "Date"
    public var useDirectionButtons:Bool = true
    
    public var minDate:Date?
    public var maxDate:Date?
    public var isValid = true
    public var highlightWhenSelected = false
    
    public var validators: [Validator] = []
    
}


// MARK: - Initilization -
extension DatePickerValue {
    
    public init(_ date:Date = Date()) {
        self.title =  nil
        self.customKey = nil
        self.date = date
    }
    
    public init(title:String,date:Date) {
        self.title = title
        self.customKey = nil
        self.date = date
    }
    
    public init(_ title:String,_ date:Date) {
        self.title = title
        self.customKey = nil
        self.date = date
    }
    
    
    public init(_ title:String?,_ customKey:String,_ dateFormat:String,_ date:Date) {
        self.title = title
        self.customKey = customKey
        self.dateFormat = dateFormat
        self.date = date
    }
    
    public init(_ title:String,_ customKey:String) {
        self.title = title
        self.customKey = customKey
        self.date = Date()
    }
    
    public init(_ title:String,_ customKey:String,_ date:Date?) {
        self.title = title
        self.customKey = customKey
        self.date = date ?? Date()
    }
    
    public init(_ title:String,_ customKey:String,_ date:Date?,_ minDate:Date?,_ maxDate:Date?) {
        self.title = title
        self.customKey = customKey
        self.date = date ?? Date()
        self.minDate = minDate
        self.maxDate = maxDate
    }
    
    public init(_ title:String,_ customKey:String,_ displayFormat:String,_ exportFormat:String, _ date:Date?,_ minDate:Date?,_ maxDate:Date?,_ highlightWhenSelected:Bool = false) {
        self.title = title
        self.customKey = customKey
        self.date = date ?? Date()
        self.minDate = minDate
        self.maxDate = maxDate
        self.displayDateFormat = displayFormat
        self.exportDateFormat = exportFormat
        self.highlightWhenSelected = highlightWhenSelected
    }
    
    
    /**
    Initializes a new DatePickerValue.

    - Parameters:
       - title: The title of the value
       - customKey: the json key to use for export
       - dateString: the date formatted string (`"yyyy-MM-dd"`).

    - Returns: A beautiful, brand-new `DatePickerValue`,
               custom-built just for you.
     
    - Attention: thanks for your attention :)
     
    - Note: if the Date Conversion fails, the current `Date` will be used.
    */
    
    public init(_ title:String,_ customKey:String,_ dateString:String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateString) ?? Date()
        
        self.title = title
        self.customKey = customKey
        self.date = date
        self.minDate = .distantPast
        self.maxDate = Date()
        self.displayDateFormat = "MMM dd, yyyy"
        self.exportDateFormat = "yyyy-MM-dd"
        self.highlightWhenSelected = true
    }
    
    
   
}


extension DatePickerValue {
    
   
    public func newWith(_ date:Date) -> DatePickerValue {
        DatePickerValue(
            title: self.title,
            date: date,
            dateFormat: self.dateFormat,
            exportDateFormat: self.exportDateFormat,
            displayDateFormat: self.displayDateFormat,
            isSelectable: self.isSelectable,
            customKey: self.customKey,
            useDirectionButtons: self.useDirectionButtons,
            minDate: self.minDate,
            maxDate: self.maxDate,
            isValid: self.isValid,
            highlightWhenSelected:  self.highlightWhenSelected
        )
    }
    
    
    public func invalidated() -> DatePickerValue {
        DatePickerValue(
            title: self.title,
            date: self.date,
            dateFormat: self.dateFormat,
            exportDateFormat: self.exportDateFormat,
            displayDateFormat: self.displayDateFormat,
            isSelectable: self.isSelectable,
            customKey: self.customKey,
            useDirectionButtons: self.useDirectionButtons,
            minDate: self.minDate,
            maxDate: self.maxDate,
            isValid: false,
            highlightWhenSelected:  self.highlightWhenSelected
        )
    }
    
    
    public func validated() -> DatePickerValue {
        DatePickerValue(
            title: self.title,
            date: self.date,
            dateFormat: self.dateFormat,
            exportDateFormat: self.exportDateFormat,
            displayDateFormat: self.displayDateFormat,
            isSelectable: self.isSelectable,
            customKey: self.customKey,
            useDirectionButtons: self.useDirectionButtons,
            minDate: self.minDate,
            maxDate: self.maxDate,
            isValid: true,
            highlightWhenSelected: self.highlightWhenSelected
        )
    }
    
    
}



extension DatePickerValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: DatePickerValue, rhs: DatePickerValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}



extension DatePickerValue {
    
    var formattedValue:String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
    
    var displayValue:String {
        let formatter = DateFormatter()
        formatter.dateFormat = displayDateFormat ?? dateFormat
        return formatter.string(from: date)
    }
    
    var exportValue:String {
        let formatter = DateFormatter()
        formatter.dateFormat = exportDateFormat ?? dateFormat
        return formatter.string(from: date)
    }
    
    public var isInvalid:Bool {
        !isValid
    }
    
}


extension DatePickerValue {
    
   public var encodedTitle:String {
        if let key = customKey {
            return key
        }
        if let title = title {
            return title
        }
        return "Date"
    }
    
}



// MARK: - FormValue -
extension DatePickerValue: FormValue {

    public var formItem:FormItem {
        .datePicker(self)
    }

    
    public func encodedValue() -> [String : String] {
        return [ encodedTitle : exportValue ]
    }

}



// MARK: - FormValueDisplayable -
extension DatePickerValue: FormValueDisplayable {
    
    public typealias Cell = DatePickerValueCell
    public typealias Controller = FormController
    
    
    public var cellDescriptor: FormCellDescriptor {
        return .init(Cell.identifier, configureCell, didSelect)
    }

    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        

    }
    
}



extension DatePickerValue {
    public static func Random() -> DatePickerValue {
        DatePickerValue("Date",
                  Date(
                    timeIntervalSince1970:
                    Double.random(in: 1...Date().timeIntervalSince1970)
            )
        )
    }
    
    
    public func dataMatches(_ dpv:DatePickerValue) -> Bool {
        customKey == dpv.customKey && date == dpv.date && title == dpv.title
    }
    
    
}




// MARK: - DateInputKeyboardObserver -
protocol DateInputKeyboardObserver: AnyObject {
    func newDate(date:Date)
}



// MARK: - DateInputKeyboard -
class DateInputKeyboard: UIInputView {
    
    weak var observer:DateInputKeyboardObserver?
    
    var date = Date() {
        didSet {
            self.datePicker.setDate(self.date, animated: true)
        }
    }
    
    
    var minDate:Date? {
        didSet {
            self.datePicker.minimumDate = minDate
        }
    }
    
    var maxDate:Date? {
        didSet {
            self.datePicker.maximumDate = maxDate
        }
    }
    
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        addSubview(picker)
        picker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: topAnchor).isActive = true
        layoutMarginsGuide.bottomAnchor.constraint(equalTo: picker.bottomAnchor).isActive = true
        
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        return picker
    }()
    
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    init(date: Date? = nil) {
        super.init(frame: CGRect(.zero, CGSize(width: 100, height: 230)) , inputViewStyle: .keyboard)
        self.date = date ?? Date()
    }
    
    init(date: Date? = nil,minDate:Date? = nil,maxDate:Date? = nil) {
        super.init(frame: CGRect(.zero, CGSize(width: 100, height: 230)) , inputViewStyle: .keyboard)
        self.date = date ?? Date()
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }
    
    
    override func didMoveToSuperview() {
        self.datePicker.setDate(self.date, animated: true)
        super.didMoveToSuperview()
    }
    
}

extension DateInputKeyboard: UIInputViewAudioFeedback {
    /// Required for playing system click sound
    var enableInputClicksWhenVisible: Bool { return true }
}


extension DateInputKeyboard {
    
    @objc private func dateChanged(sender:UIDatePicker) {
       observer?.newDate(date: sender.date)
    }
    
}





import UIKit
//: MARK: DatePickerValueCell
public final class DatePickerValueCell: UITableViewCell, Activatable {
    
    static let identifier = "FormKit.DatePickerValueCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        return label
    }()
    
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.tintColor = .clear
        if #available(iOS 13.0, *) {
            textField.textColor = .secondaryLabel
        } else {
            textField.textColor = .lightText
        }
        textField.delegate = self
        textField.inputView = dateInputView
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        return textField
    }()
    
    
    private var dateInputView = DateInputKeyboard(date: nil)
    
    var indexPath:IndexPath?
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    
    var formValue:DatePickerValue? {
        didSet {
            if oldValue == nil {
                evaluateButtonBar()
            }
            if let dateValue = formValue {
                dateInputView.date = dateValue.date
                dateInputView.minDate = dateValue.minDate
                dateInputView.maxDate = dateValue.maxDate
                titleLabel.text = dateValue.title
                textField.attributedText = attributedStringAdapter(dateValue,textField.isFirstResponder)
            } else {
                titleLabel.text = nil
                textField.text = nil
                textField.attributedText = nil
            }
        }
    }
    
    
    private func attributedStringAdapter(_ dateValue:DatePickerValue,_ sel:Bool = false) -> NSAttributedString {
        
        let selected = dateValue.highlightWhenSelected ? sel : false
        
        if dateValue.isValid {
            return NSAttributedString(string: dateValue.displayValue, attributes: [
                .font : UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor : selected ? UIColor.FormKit.inputSelected : UIColor.FormKit.valueText,
                .strikethroughStyle : NSNumber(integerLiteral: 0),
                .strikethroughColor : UIColor.clear
            ])
        } else {
            return NSAttributedString(string: dateValue.displayValue, attributes: [
                .font : UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor : selected ? UIColor.FormKit.inputSelected : UIColor.FormKit.valueText,
                .strikethroughStyle : NSUnderlineStyle.single.rawValue,
                .strikethroughColor : UIColor.FormKit.delete
            ])
        }
    }

    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        dateInputView.observer = self
        activateDefaultHeightAnchorConstraint()
        accessoryType = .disclosureIndicator
        evaluateButtonBar()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            guard let dateValue = formValue else { return }
            if let input = textField.inputView as? DateInputKeyboard {
                input.minDate = dateValue.minDate
                input.maxDate = dateValue.maxDate
                input.date = dateValue.date
            } else {
                textField.inputView = dateInputView
                dateInputView.minDate = dateValue.minDate
                dateInputView.maxDate = dateValue.maxDate
                dateInputView.date = dateValue.date
            }
            textField.becomeFirstResponder()
        }
        super.setSelected(selected, animated: animated)
    }
    
    
    public override  func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        textField.text = nil
        textField.attributedText = nil
    }
    
    
}


extension DatePickerValueCell: DateInputKeyboardObserver {
    
    func newDate(date: Date) {
        guard let dateValue = formValue else { return }
        let newValue = dateValue.newWith(date)
        self.formValue = newValue
        updateFormValueDelegate?.updatedFormValue(newValue, indexPath)
    }
    
    public func setNewDatePickerValue(_ newValue:DatePickerValue) {
        self.formValue = newValue
    }
    
}





extension DatePickerValueCell {

    
    func evaluateButtonBar(){
        
        guard let datePickerValue = formValue, datePickerValue.useDirectionButtons else { return }
        
        
        let inputBarHeight: CGFloat = 32.0
        let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: inputBarHeight)))
        let inputLabel = UILabel(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width * 0.60, height: inputBarHeight)))
        inputLabel.text =  datePickerValue.title ?? "Input Date"
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

      
    @objc
    func doneAction(){
        if let value = formValue {
            updateFormValueDelegate?.updatedFormValue(value, self.indexPath)
        }
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
        guard let dateValue = formValue else { return }
        FormConstant.makeSelectionFeedback()
        if let input = textField.inputView as? DateInputKeyboard {
            input.minDate = dateValue.minDate ?? .distantPast
            input.maxDate = dateValue.maxDate ?? .distantFuture
            input.date = dateValue.date
        }
        textField.becomeFirstResponder()
    }
    
}



extension UITextField {
    
    public func strikeContent() {
        guard let currentText = text else { return }
        self.attributedText = NSAttributedString(string: currentText, attributes: [
            .font : self.font ?? UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor : self.textColor ?? UIColor.FormKit.text,
            .strikethroughStyle : NSUnderlineStyle.single.rawValue,
            .strikethroughColor : UIColor.FormKit.delete
        ])
    }
    
    
    public func unstikeContent() {
        guard let attributedString = self.attributedText else { return }
        self.attributedText = nil
        self.text = attributedString.string
        self.font = UIFont.preferredFont(forTextStyle: .body)
        self.tintColor = .clear
        self.textColor = UIColor.FormKit.valueText

    }
    
}



extension DatePickerValueCell: UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let date = formValue {
            if date.highlightWhenSelected {
                animateTitleForSelection(isSelected: false)
            }
        }
        return true
    }
    
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let date = formValue {
            if date.highlightWhenSelected {
                animateTitleForSelection(isSelected: true)
            }
        }
        return true
    }
    
    
    func animateTitleForSelection(isSelected:Bool) {
        guard let date = formValue else { return }
        let newAttributedString = attributedStringAdapter(date,isSelected)
        UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.21) { [weak self] in
            guard let self = self else { return }
            self.textField.attributedText = newAttributedString
        }.startAnimation()
    }
}
