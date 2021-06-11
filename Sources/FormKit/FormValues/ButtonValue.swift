import UIKit

//: MARK: - ButtonValue -
public struct ButtonValue: FormValue, Equatable, Hashable {
    
    public var formItem: FormItem {
        return FormItem.button(self)
    }
    
     public var customKey:String? = "ButtonValue"
   
    var style:RoundButton.Style = .none
    var useAttatchment:Bool = false
    
    var title:String = ""
    var color:UIColor = .blue
    
    public init(title: String,_ color:UIColor = .blue,_ style:RoundButton.Style = .cell,_ withAttachment:Bool = false ) {
        self.title = title
        self.color = color
        self.style = style
        self.useAttatchment = withAttachment
    }
}


extension ButtonValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = ButtonCell
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.buttonActionDelegate = formController
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if #available(iOS 13.0, *) {
            formController.navigationController?.pushViewController(FormController(formData: .Random()), animated: true)
        } else {
            formController.navigationController?.pushViewController(FormController(formData: .Random()), animated: true)
        }
    }
    
}


extension UIColor {
    public class var random:UIColor {
        return UIColor(
            red: .random(in: 0...1.0),
            green: .random(in: 0...1.0),
            blue: .random(in: 0...1.0),
            alpha: 1.0
        )
    }
}



extension ButtonValue {
    
    public static func Random() -> ButtonValue {
        let randomTitle = "\(UUID().uuidString.split(separator: "-")[1])"
        let randomStyle = [RoundButton.Style.bar,RoundButton.Style.cell,RoundButton.Style.none][Int.random(in: 0...2)]
        return ButtonValue(title: randomTitle, .random, randomStyle, .random())
    }
    
    
    public static func DemoCell() -> ButtonValue {
        return ButtonValue(title: "Cell Style", .systemPink, .cell, true)
    }
    
    public static func DemoBar() -> ButtonValue {
        return ButtonValue(title: "Bar Style", .systemBlue, .bar, true)
    }
    
}



//: MARK: ButtonActionDelegate
public protocol ButtonActionDelegate: AnyObject {
    func performAction(_ action:String)
}


//: MARK: ButtonCell
public final class ButtonCell: UITableViewCell {
    static let identifier = "buttonCell"
    
    var button = RoundButton(titleText: "", target: nil, action: nil)
    weak var buttonActionDelegate: ButtonActionDelegate?
    
    var formValue : ButtonValue! {
        didSet {
            button.updateWith(formValue)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        
        activateDefaultHeightAnchorConstraint()
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2.0),
            contentView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 2.0)
            ])
    }
    
    @objc
    func buttonPressed(_ sender:UIButton) {
        FormConstant.makeSelectionFeedback()
        buttonActionDelegate?.performAction(formValue.title)
    }
    
}


