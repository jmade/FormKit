

import UIKit


public struct CustomConfiguration: DefaultTokenCellConfiguration {
    public func cornerRadius(forSelected isSelected: Bool) -> CGFloat {
        5
    }
    
    public func borderWidth(forSelected isSelected: Bool) -> CGFloat {
        0
    }
    
    public func borderColor(forSelected isSelected: Bool) -> CGColor {
        isSelected ? UIColor.red.cgColor : UIColor.white.cgColor
    }
    
    public func textColor(forSelected isSelected: Bool) -> UIColor {
        .white
    }
    
    public func backgroundColor(forSelected isSelected: Bool) -> UIColor {
        if #available(iOS 13.0, *) {
            return isSelected ? .systemBlue : .gray
        } else {
            return isSelected ? .blue : .gray
        }
    }
}


// MARK: - TokenValue -
public struct TokenValue {
    
    public struct Token: Equatable, ResizingTokenFieldToken {
        public var title:String
        public var id:String?
    }
    
    
    public var title:String = ""
    public var tokens:[Token] = []
    
    var identifier: UUID = UUID()
    public var customKey:String? = "TokenValue"
    public var useDirectionButtons:Bool = true
    /// TableSelectable
    public var isSelectable: Bool = true
    public var tokenCellConfiguration: DefaultTokenCellConfiguration?
    public var placeholderValue:String = "Type here…"
    
    public enum ExportStyle {
        case string, array
    }
    public var exportStyle:ExportStyle = .string
    
}



public extension TokenValue.Token {
    
    init(_ title:String) {
        self.title = title
    }
    
}



public extension TokenValue {
    
    init(_ title:String) {
        self.title = title
        self.tokenCellConfiguration = CustomConfiguration()
    }
    
    
    init(_ title:String,_ tokens:[String],_ cellConfig:DefaultTokenCellConfiguration? = nil) {
        self.title = title
        self.tokens = tokens.map({ Token(title: $0, id: $0) })
        self.tokenCellConfiguration = cellConfig ?? CustomConfiguration()
    }
    
    
    init(_ title:String,_ tokens:[Token],_ cellConfig:DefaultTokenCellConfiguration? = nil) {
        self.title = title
        self.tokens = tokens
        self.tokenCellConfiguration = cellConfig ?? CustomConfiguration()
    }
}


extension TokenValue {
    
    public var tokenStrings:[String] {
        tokens.map({ $0.title })
    }
    
    
    public func newWith(_ token:Token) -> TokenValue {
        newWithTokens(
            [ self.tokens,[token] ].reduce([],+)
        )
    }
    
    
    public func newRemoving(_ token:Token) -> TokenValue {
        newWithTokens(
            tokens.filter( {$0.title != token.title  } )
        )
    }
    
    
    public func newRemoving(_ tokenTitle:String) -> TokenValue {
        newWithTokens(
            tokens.filter( {$0.title != tokenTitle } )
        )
    }
    
    private func newWithTokens(_ tokens:[Token]) -> TokenValue {
        var new = TokenValue(self.title, tokens)
        new.customKey = self.customKey
        new.useDirectionButtons = self.useDirectionButtons
        new.tokenCellConfiguration = self.tokenCellConfiguration
        return new
    }
    
}


extension TokenValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: TokenValue, rhs: TokenValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


// MARK: - FormValue -
extension TokenValue: FormValue, TableViewSelectable {
    
    public var formItem: FormItem {
        .token(self)
    }
    
    var tokensEncoded: String {
        switch exportStyle {
        case .string:
            return tokens.map({ $0.title }).joined(separator: ",")
        case .array:
            return "\(tokens.map({ $0.title }))"
        }
    }
    
    public func encodedValue() -> [String : String] {
        return [ (customKey ?? title) : tokensEncoded ]
    }
    
}



//: MARK: - FormValueDisplayable -
extension TokenValue: FormValueDisplayable {
    
    public typealias Cell = TokenValueCell
    public typealias Controller = FormController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let cell = formController.tableView.cellForRow(at: path) as? Cell {
            cell.activate()
        }
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
        cell.heightDidChangeClosure = { [weak formController] _ in
            formController?.performLiveUpdates()
        }
    }
    
    
}


extension String {
    
    func width(withFont font: UIFont) -> CGFloat {
        return ceil(self.size(withAttributes: [.font: font]).width)
    }
    
}



// MARK: TokenValueCell
public final class TokenValueCell: UITableViewCell, Activatable {
    
    typealias Token = TokenValue.Token
    
    static let identifier = "com.jmade.FormKit.TokenValueCell.identifier"
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    public var heightDidChangeClosure: ((CGFloat) -> Void)?
    
    var indexPath: IndexPath?
    
    private lazy var tokenField: ResizingTokenField = {
        let tokenField = ResizingTokenField(frame: .zero)
        
        tokenField.preferredTextFieldReturnKeyType = .go
        tokenField.delegate = self
        tokenField.textFieldDelegate = self
        tokenField.shouldTextInputRemoveTokensAnimated = true
        tokenField.shouldExpandTokensAnimated = true
        tokenField.shouldCollapseTokensAnimated = true

        
        tokenField.labelTextColor = UIColor.FormKit.text
        
        tokenField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tokenField)
        NSLayoutConstraint.activate([
            tokenField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
            tokenField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8.0),
            tokenField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: tokenField.bottomAnchor),
        ])
        
        return tokenField
    }()
    
    
    var formValue : TokenValue? {
        didSet {
            guard oldValue == nil else { return }
            
            if let tokenValue = formValue {
                evaluateButtonBar()
                
                let currentTokenStrings = tokenField.tokens.map({ $0.title })
                let neededTokens = tokenValue.tokenStrings.filter({ !currentTokenStrings.contains($0) })
                let addingTokens = neededTokens.map({ Token(title: $0, id: $0) })
                
                tokenField.placeholder = tokenValue.placeholderValue
                tokenField.textFieldMinWidth = tokenValue.placeholderValue.width(withFont: tokenField.font)
                tokenField.labelText = tokenValue.title
                tokenField.append(tokens: addingTokens)
                contentView.layoutIfNeeded()
            }
        }
    }
    
    
    private var lastHeight:CGFloat = 44.0
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
        indexPath = nil
        tokenField.removeAllTokens()
        tokenField.labelText = nil
    }

    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        if selected {
           let _ = tokenField.becomeFirstResponder()
        }
    }
    
    
    func evaluateButtonBar(){
        guard let tokenValue = formValue else { return }
        if tokenValue.useDirectionButtons {
            // Toolbar
            let bar = UIToolbar(frame: CGRect(.zero, CGSize(width: contentView.frame.size.width, height: 44.0)))
            let previous = UIBarButtonItem(image: Image.Chevron.previousChevron, style: .plain, target: self, action: #selector(previousAction))
            let next = UIBarButtonItem(image: Image.Chevron.nextChevron, style: .plain, target: self, action: #selector(nextAction))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
            bar.items = [previous,next,spacer,done]
            bar.sizeToFit()
            tokenField.textFieldInputAccessoryView = bar
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
        let _ = tokenField.becomeFirstResponder()
    }
    
    
    private func endTextEditing(){
        endEditing(true)
    }
    
}


extension TokenValueCell: ResizingTokenFieldDelegate, UITextFieldDelegate {
    
    // MARK: - ResizingTokenFieldDelegate
    
    func resizingTokenFieldShouldCollapseTokens(_ tokenField: ResizingTokenField) -> Bool {
        false
    }
    
    func resizingTokenFieldCollapsedTokensText(_ tokenField: ResizingTokenField) -> String? {
        nil
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, willChangeHeight newHeight: CGFloat) {
        contentView.layoutIfNeeded()
    }
    
    func resizingTokenField(_ tokenField: ResizingTokenField, didChangeHeight newHeight: CGFloat) {
        if newHeight != lastHeight {
            heightDidChangeClosure?(newHeight)
        }
        lastHeight = newHeight
    }
    
    
    func resizingTokenField(_ tokenField: ResizingTokenField, shouldRemoveToken token: ResizingTokenFieldToken) -> Bool {
        guard let tokenValue = formValue else { return false }
        let newTokenValue = tokenValue.newRemoving(token.title)
        self.formValue = newTokenValue
        updateFormValueDelegate?.updatedFormValue(
            newTokenValue,
            indexPath
        )
        tokenField.remove(tokens: [Token(title: token.title, id: token.title)])
        return true
    }
    
    
    func resizingTokenField(_ tokenField: ResizingTokenField, configurationForDefaultCellRepresenting token: ResizingTokenFieldToken) -> DefaultTokenCellConfiguration? {
        guard let tokenValue = formValue else { return nil }
        return tokenValue.tokenCellConfiguration
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let tokenValue = formValue, textField == tokenField.textField else { return true }
        guard let text = textField.text, !text.isEmpty else { return true }
        
        if CharacterSet.whitespacesAndNewlines.isSuperset(of: CharacterSet(charactersIn: text)) {
            return true
        } else {
            if !tokenField.tokens.map({ $0.title }).contains(text) {
                let token = Token(title: text, id: text)
                let newTokenValue = tokenValue.newWith(token)
                self.formValue = newTokenValue
                updateFormValueDelegate?.updatedFormValue(
                    newTokenValue,
                    indexPath
                )
                tokenField.append(tokens:[token], animated: true)
                tokenField.text = nil
                return false
            } else {
                return true
            }
        }
    }
    
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        CharacterSet.formKit(FormConstant.ALLOWED_CHARS).isSuperset(of: CharacterSet(charactersIn: string))
    }

}






