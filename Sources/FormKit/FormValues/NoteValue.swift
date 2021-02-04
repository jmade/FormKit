import UIKit

extension UIBarButtonItem {
    
    static func Flexible() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
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
    
}




// MARK: - NoteValue -
public struct NoteValue: TextNumericalInput {
    
   public enum NoteStyle {
        case standard
        case long
        case custom(CGFloat)
    }
    
    var identifier: UUID = UUID()
    public var value:String?
    public var placeholderValue:String?
    public var customKey: String?
    public var useDirectionButtons:Bool
    
    public var style:NoteStyle = .standard
    public var title:String?
    
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
    
    public typealias Cell = NoteCell
    public typealias Controller = FormController
    
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


extension NoteValue {
    
    public func encodedValue() -> [String : String] {
        return [ customKey ?? "Note" : value ?? "" ]
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
                        title: self.title
        )
    }
}


//: MARK: - NoteCell -
public final class NoteCell: UITableViewCell, Activatable {
    static let identifier = "com.jmade.FormKit.NoteCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    private let gen = UIImpactFeedbackGenerator()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(textView)
        return textView
    }()
    
    
    var standardHeightConstraint = NSLayoutConstraint()
    var noteValueConstraint = NSLayoutConstraint()
    
    
    var formValue : NoteValue? {
        didSet {
            if let val = formValue {
                
               
                
                titleLabel.text = val.title
                
                let mode = derivedMode()
                switchToMode(mode)
               
                if val.useDirectionButtons {
                    evaluateButtonsBar()
                }
                
            }     
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        

        activateDefaultHeightAnchorConstraint(92)
        
        
        
        
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.0),
            textView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            ])
    }
    
    
    func evaluateButtonsBar() {
        guard let formValue = formValue else { return }
        let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: 44.0)))
        if formValue.useDirectionButtons {
            bar.items = [
                UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction)),
                UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction)),
                .Flexible(),
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
            ]
        } else {
            bar.items = [
                .Flexible(), .Flexible(), .Flexible(),
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
            ]
        }
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
    
    
    private func sendTextToDelegate() {
        let mode = derivedMode()
        if mode != .input {
            switchToMode(.input)
        }
        
        
        if let newText = textView.text {
            if let existingNoteValue = formValue {
                updateFormValueDelegate?.updatedFormValue(
                    existingNoteValue.newWith(newText),
                    indexPath
                )
            }
        }
    }

    public func activate(){
        
        textView.becomeFirstResponder()
        let mode = derivedMode()
        
        
        if mode == .placeholder {
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        } else {
            let newPosition = textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
        
        
        
    }
}

extension NoteCell: UITextViewDelegate {
    
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
        
        if CharacterSet.noteValue.isSuperset(of: CharacterSet(charactersIn: text)) {
            return (textView.text + text).count < 4000
        } else {
            var newText = ""
            text.forEach { (char) in
                if CharacterSet.noteValue.isSuperset(of: CharacterSet(charactersIn: String(char))) {
                    newText.append(char)
                }
            }
            
            if (textView.text + text).count < 4000 {
                textView.text = textView.text + newText
                textView.setCursorLocation(textView.text.count)
            }
            return false
        }
        
    }
    
}


extension NoteCell {
    
    private enum NoteMode {
        case empty, placeholder, input
    }
    
    
    private func derivedMode() -> NoteMode {
        guard let noteValue = formValue else {
            return .empty
        }
        
        
        if let _ = noteValue.placeholderValue {
            if let _ = noteValue.value {
                return .input
            } else {
                return .placeholder
            }
        }
        
        return .input
        
    }
    
    
    private func switchToMode(_ mode:NoteMode) {
        guard let note = formValue else {
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: nil)
        
        switch mode {
        case .input:
            animator.addAnimations {
                self.textView.text = note.value
                self.textView.font = UIFont.preferredFont(forTextStyle: .body)
                if #available(iOS 13.0, *) {
                    self.textView.textColor = .label
                }
            }
        case .placeholder:
            animator.addAnimations {
                self.textView.text = note.placeholderValue
                self.textView.font = UIFont.preferredFont(forTextStyle: .body)
                if #available(iOS 13.0, *) {
                    self.textView.textColor = .placeholderText
                }
            }
        case .empty:
            animator.addAnimations {
                self.textView.text = nil
                if #available(iOS 13.0, *) {
                    self.textView.textColor = .label
                }
            }
        }
        
        animator.startAnimation()
        
    }
    
}
