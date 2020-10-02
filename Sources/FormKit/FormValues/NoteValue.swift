import UIKit

extension UIBarButtonItem {
    
    static func Flexible() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
}




// MARK: - NoteValue -
public struct NoteValue: FormValue, TextNumericalInput, Equatable, Hashable {
    var identifier: UUID = UUID()
    public var value:String?
    public var placeholderValue:String?
    public var customKey: String?
    public var useDirectionButtons:Bool
}


extension NoteValue {
    
    public init(value: String,placeholderValue:String = "Type Note here...",_ useDirectionButtons:Bool = true) {
        self.value = value
        self.placeholderValue = placeholderValue
        self.useDirectionButtons = useDirectionButtons
        self.customKey = nil
    }
    
    public init(placeholderValue:String,_ customKey:String?) {
        self.value = ""
        self.placeholderValue = placeholderValue
        self.useDirectionButtons = true
        self.customKey = customKey
    }
    
}


extension NoteValue {
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
        if let key = customKey {
            return [key:value ?? ""]
        } else {
            return ["Note":value ?? ""]
        }
    }
    
}



extension NoteValue {
    public static func Random() -> NoteValue {
        return NoteValue(value: "", placeholderValue: "Text here...", true)
    }
    
    
    public func newWith(_ text:String) -> NoteValue {
      return  NoteValue(identifier: UUID(), value: text, placeholderValue: self.placeholderValue, customKey: self.customKey, useDirectionButtons: self.useDirectionButtons)
    }
}


//: MARK: - NoteCell -
public final class NoteCell: UITableViewCell, Activatable {
    static let identifier = "FormKit.noteCell"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.keyboardType = .alphabet
        textView.returnKeyType = .default
        textView.textAlignment = .left
        textView.font = UIFont.preferredFont(forTextStyle: .headline)
        return textView
    }()
    
    var formValue : NoteValue? {
        didSet {
            if let _ = formValue {
                
                let mode = derivedMode()
                switchToMode(mode)
               
                evaluateButtonsBar()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activateDefaultHeightAnchorConstraint(92)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        
        textView.delegate = self
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
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
                    NoteValue(value: newText, existingNoteValue.useDirectionButtons),
                    indexPath
                )
            }
        }
    }
    
    
    
    public func activate(){
        
        textView.becomeFirstResponder()
        let mode = derivedMode()
        
        print(" mode -> \(mode) ")
        
        
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
        print("Incoming Text: \(text)")
        
        
        return true
        
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
