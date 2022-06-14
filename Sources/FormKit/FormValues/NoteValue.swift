import UIKit

extension UIBarButtonItem {
    
    public static var flexible: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
}


extension CharacterSet {
    
    static var noteValue:CharacterSet {
        let sets:[CharacterSet] = [
            .alphanumerics,
            .letters,
            .capitalizedLetters,
            .lowercaseLetters,
            .uppercaseLetters,
            .decimalDigits,
            .whitespacesAndNewlines,
            CharacterSet(charactersIn: ".?!,()[]$*%#-=/:;")
        ]
        
        var megaSet = CharacterSet()
        
        for set in sets {
            megaSet.formUnion(set)
        }
        return megaSet
    }
    
    
    static func formKit(_ allowedChars:String) -> CharacterSet {
        
        let sets:[CharacterSet] = [
            .alphanumerics,
            .letters,
            .capitalizedLetters,
            .lowercaseLetters,
            .uppercaseLetters,
            .decimalDigits,
            .whitespacesAndNewlines,
            CharacterSet(charactersIn: allowedChars)
        ]
        
        var megaSet = CharacterSet()
        
        for set in sets {
            megaSet.formUnion(set)
        }
        return megaSet

    }
    
}




// MARK: - NoteValue -
public struct NoteValue: TextNumericalInput {
    
   public enum NoteStyle {
        case standard
        case long
        case custom(CGFloat)
        case auto
    }
    
    var identifier: UUID = UUID()
    public var value:String?
    public var placeholderValue:String?
    public var customKey: String?
    public var useDirectionButtons:Bool
    
    public var style:NoteStyle = .standard
    public var title:String?
    
    public var emptyValuePlaceholder:String?
    public var characterCount:Int?
    public var allowedChars:String?
    public var validators: [Validator] = []
    
}


extension NoteValue {
    
    
    public init(placeholderValue:String,_ customKey:String?) {
        self.value = ""
        self.placeholderValue = placeholderValue
        self.useDirectionButtons = true
        self.customKey = customKey
    }
    
    
    public init(value: String,placeholderValue:String = "Type Note here...",_ useDirectionButtons:Bool = true) {
        self.value = value
        self.placeholderValue = placeholderValue
        self.useDirectionButtons = useDirectionButtons
        self.customKey = nil
    }
    
    
    public init(style:NoteStyle,_ useDirectionButtons:Bool = true,_ customKey:String?) {
        self.value = ""
        self.useDirectionButtons = useDirectionButtons
        self.customKey = customKey
    }
    
    
}



extension NoteValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: NoteValue, rhs: NoteValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


public extension NoteValue {
    
    static var FeedBack: NoteValue {
        NoteValue(style: .long, false, "message")
    }
    
}



extension NoteValue: FormValue {
    public var formItem: FormItem {
        .note(self)
    }
}


extension NoteValue: FormValueDisplayable {
    
    public typealias Cell = NewNoteCell
    public typealias Controller = FormController
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
        cell.tableView = formController.tableView
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let cell = formController.tableView.cellForRow(at: path) as? NewNoteCell {
            cell.activate()
        }
    }
    
    public var cellDescriptor: FormCellDescriptor {
        FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}


extension NoteValue {
    
    var derivedValue:String {
        if let v = value {
            if v.isEmpty || v == "" || v == " " {
                if let value = emptyValuePlaceholder {
                    return value
                } else {
                    return v
                }
            } else {
                return v
            }
        } else {
            return String()
        }
    }
    
    
    public func encodedValue() -> [String : String] {
        return [ customKey ?? "Note" : derivedValue ]
    }
    
}



extension NoteValue {
    public static func Random() -> NoteValue {
        return NoteValue(value: "", placeholderValue: "Text here...", true)
    }
    
    
    public func newWith(_ text:String) -> NoteValue {
      return  NoteValue(identifier: UUID(),
                        value: text,
                        placeholderValue: self.placeholderValue,
                        customKey: self.customKey,
                        useDirectionButtons: self.useDirectionButtons,
                        style: self.style,
                        title: self.title,
                        emptyValuePlaceholder: self.emptyValuePlaceholder,
                        characterCount: self.characterCount,
                        allowedChars: self.allowedChars
        )
    }
}



// MARK: - CharacterCountDisplayable -
public protocol CharacterCountDisplayable: AnyObject {
    var maxCharacterCount:Int { get }
    var characterCountLabel: UILabel { get }
    var characterCountBarItem: UIBarButtonItem { get }
    func updateCharacterCount(_ count:Int)
}



//: MARK: - NewNoteCell -
public final class NewNoteCell: UITableViewCell, Activatable, CharacterCountDisplayable {
    static let identifier = "com.jmade.FormKit.NewNoteCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    public var heightDidChangeClosure: ((CGFloat) -> Void)?
    
    var indexPath: IndexPath?
    var tableView: UITableView?
    
    private let gen = UIImpactFeedbackGenerator()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.keyboardType = .alphabet
        textView.returnKeyType = .default
        textView.textAlignment = .left
        textView.font = UIFont.preferredFont(forTextStyle: .headline)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        contentView.addSubview(textView)
        return textView
    }()
    
    /// CharacterCountDisplayable
    public var maxCharacterCount = 100
    public lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.text  = "0/0"
        return label
    }()
    
    private var lastHeight: CGFloat = 0
    
    public lazy var characterCountBarItem: UIBarButtonItem  = {
        UIBarButtonItem(customView: characterCountLabel)
    }()
    
    
    var formValue : NoteValue? {
        didSet {
            if let noteValue = formValue {
                
                if let titleText = titleLabel.text {
                    if titleText != noteValue.title {
                        titleLabel.text = noteValue.title
                    }
                } else {
                    titleLabel.text = noteValue.title
                }
                
                if let textViewText = textView.text {
                    if textViewText != noteValue.value {
                        textView.text = noteValue.value
                    }
                } else {
                    textView.text = noteValue.value
                }
                
                
                if let max = noteValue.characterCount {
                    maxCharacterCount = max
                    updateCharacterCount(0)
                }
                
                
                if noteValue.useDirectionButtons {
                    evaluateButtonBar()
                }
                
                
            }
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
        ])
    }
    
    
    
    func evaluateButtonBar() {
        
        guard let textValue = formValue else { return }
        
        var barItems:[UIBarButtonItem] = []
        
        if textValue.useDirectionButtons {
            
            let previousImg: UIImage = {
                if #available(iOS 13.0, *) {
                    if let img = UIImage(systemName: "chevron.left") {
                        return img
                    } else {
                        return Image.Chevron.previousChevron
                    }
                } else {
                    return Image.Chevron.previousChevron
                }
            }()
            
            let nextImg: UIImage = {
                if #available(iOS 13.0, *) {
                    if let img = UIImage(systemName: "chevron.right") {
                        return img
                    } else {
                        return Image.Chevron.nextChevron
                    }
                } else {
                    return Image.Chevron.nextChevron
                }
            }()
            
            barItems.append(
                UIBarButtonItem(image: previousImg, style: .plain, target: self, action: #selector(previousAction))
            )
            
            barItems.append(
                UIBarButtonItem(image: nextImg, style: .plain, target: self, action: #selector(nextAction))
            )
        }
        
        barItems.append(.flexible)
        
        if textValue.characterCount != nil {
            barItems.append(characterCountBarItem)
            barItems.append(.flexible)
        }
        
        barItems.append(
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
        )
        
        let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: 44.0)))
        bar.items = barItems
        bar.sizeToFit()
        textView.inputAccessoryView = bar
    }
    
    
    
    @objc
    func doneAction(){
        textView.resignFirstResponder()
        sendTextToDelegate()
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
    
    
    public func updateCharacterCount(_ count:Int) {
        characterCountLabel.text = "\(count)/\(maxCharacterCount)"
        if #available(iOS 13.0, *) {
            characterCountLabel.textColor = (count == maxCharacterCount) ? .error : .label
        }
        characterCountLabel.sizeToFit()
    }
    
    
    
    
    
    private func sendTextToDelegate() {
        
        guard
            let newText = textView.text,
            let existingNoteValue = formValue
        else {
            return
        }
        
        if existingNoteValue.characterCount != nil {
            updateCharacterCount(newText.count)
        }
        
        let newValue = existingNoteValue.newWith(newText)
        
        
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: .greatestFiniteMagnitude))
        
        if lastHeight != newSize.height {
            UIView.setAnimationsEnabled(false)
            self.tableView?.beginUpdates()
            textView.sizeToFit()
            self.formValue = newValue
            self.tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            lastHeight = newSize.height
        }
        
        updateFormValueDelegate?.updatedFormValue(
            newValue,
            indexPath
        )
    }

    
    public func activate() {
        textView.becomeFirstResponder()
    }

    
}


extension NewNoteCell: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        gen.prepare()
        if #available(iOS 13.0, *) {
            gen.impactOccurred(intensity: 0.80)
        }
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    
    public func textViewDidChange(_ textView: UITextView) {
        sendTextToDelegate()
    }
    
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        guard let note = formValue else {
            return false
        }
        
        let maxChars = note.characterCount ?? Int.max
        
        let charSet = CharacterSet.formKit(note.allowedChars ?? FormConstant.ALLOWED_CHARS)
        
        if charSet.isSuperset(of: CharacterSet(charactersIn: text)) {
            if (textView.text + text).count <= maxChars {
                return true
            } else {
                var newText = ""
                text.forEach { (char) in
                   if (textView.text + newText).count+1 <= maxChars {
                        newText.append(char)
                    }
                }
                
                if (textView.text + newText).count <= maxChars {
                    textView.text = textView.text + newText
                    textView.setCursorLocation(textView.text.count)
                    updateCharacterCount(textView.text.count)
                }
                
                
                
                let gen = UIImpactFeedbackGenerator()
                gen.prepare()
                if #available(iOS 13.0, *) {
                    gen.impactOccurred(intensity: 0.5)
                }
                return false
            }
        } else {
            var newText = ""
            text.forEach { (char) in
                if charSet.isSuperset(of: CharacterSet(charactersIn: String(char))) {
                    if (textView.text + newText).count+1 <= maxChars {
                        newText.append(char)
                    }
                }
            }
            
            if (textView.text + newText).count <= maxChars {
                textView.text = textView.text + newText
                textView.setCursorLocation(textView.text.count)
                updateCharacterCount(textView.text.count)
            }
            
            return false
        }
        
    }
    
}
