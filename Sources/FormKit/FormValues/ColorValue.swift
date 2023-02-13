
import UIKit


fileprivate extension UIColor {
    
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
    
    func encoded() -> String {
        "\(Int(self.redValue * CGFloat(255.0))),\(Int(self.greenValue * CGFloat(255.0))),\(Int(self.blueValue * CGFloat(255.0)))"
    }
    
}

// MARK: - ColorValue -
public struct ColorValue {
    
    public var title:String
    public var customKey:String?
    public var color:UIColor
    
    public var validators: [Validator] = []
    
    public typealias ColorValueFormClosure = ( (ColorValue,FormController,IndexPath) -> Void )
    public var formClosure: ColorValueFormClosure? = nil
    
    public typealias ColorValueClosure = ( (ColorValue) -> Void )
    public var valueClosure: ColorValueClosure? = nil
    
}


public extension ColorValue {
    
    init(_ title:String,_ customKey:String?,_ color:UIColor) {
        self.title = title
        self.customKey = customKey
        self.color = color
    }
    
    init(_ title:String,_ customKey:String?,_ color:UIColor, formClosure: @escaping ColorValueFormClosure) {
        self.title = title
        self.customKey = customKey
        self.color = color
        self.formClosure = formClosure
    }
    
    init(_ title:String,_ customKey:String?,_ color:UIColor, valueClosure: @escaping ColorValueClosure) {
        self.title = title
        self.customKey = customKey
        self.color = color
        self.valueClosure = valueClosure
    }
    
}



extension ColorValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(customKey)
        hasher.combine(color)
        hasher.combine(title)
    }
    
    public static func == (lhs: ColorValue, rhs: ColorValue) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}


// MARK: - FormValue -
extension ColorValue: FormValue, TableViewSelectable {
    
    public var isSelectable: Bool {
        true
    }
    
    public var formItem: FormItem {
        .color(self)
    }
    
    private var encodedColor: String {
        color.encoded()
    }
    
    public func encodedValue() -> [String : String] {
        return [ (customKey ?? title) : encodedColor ]
    }
    
}



//: MARK: - FormValueDisplayable -
extension ColorValue: FormValueDisplayable {
    
    public typealias Cell = ColorValueCell
    public typealias Controller = FormController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        if let cell = formController.tableView.cellForRow(at: path) as? Cell {
            cell.activate()
        }
        
        let valueClosure = self.valueClosure
        
        formController.presentColorPicker(self.color) { [weak formController] newColor in
            var newValue = self
            if let newColor = newColor {
                newValue.color = newColor
                valueClosure?(newValue)
            }
            formController?.updatedFormValue(newValue, path)
        }
        
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
    }
    
    
}





fileprivate extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? .init()
    }
}


fileprivate class RoundImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 13.0, *) {
            layer.borderColor = UIColor.separator.cgColor
        }
        layer.borderWidth = 1.0
        layer.cornerRadius = bounds.width/2
        layer.masksToBounds = true
    }
    
}





// MARK: ColorValueCell
public final class ColorValueCell: UITableViewCell {
    static let identifier = "FormKit.ColorValueCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var colorView: UIImageView = {
        let imageView = RoundImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0).isActive = true
        contentView.addSubview(imageView)
        return imageView
    }()
    
    var formValue : ColorValue? {
        didSet {
            guard let colorValue = formValue else { return }
            titleLabel.text = colorValue.title
            colorView.image = UIImage.imageWithColor(color: colorValue.color, size: CGSize(width: 128, height: 128))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activateDefaultHeightAnchorConstraint()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.leadingAnchor),

            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: (titleLabel.font.pointSize * 1.25)),
        ])
    }

    public func activate() { }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.colorView.image = nil
    }
    
}
