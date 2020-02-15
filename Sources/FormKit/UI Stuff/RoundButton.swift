import UIKit

// MARK: - RoundButton -
public final class RoundButton: UIButton {
    
    public enum Style {
        case bar,cell,none
    }
    
    var style:Style = .none
    
    var customBGColor:UIColor = .systemBlue {
        didSet {
            refreshColor(color: customBGColor)
        }
    }
    
    var cornerRadius: CGFloat = 12 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    var backgroundImageColor: UIColor = UIColor.init(red: 0, green: 122/255.0, blue: 255/255.0, alpha: 1) {
        didSet {
            refreshColor(color: customBGColor)
        }
    }
    
    var useAttatchment:Bool = false
    
    var buttonTextStyle: UIFont.TextStyle = .body
    
    var buttonFont: UIFont {
        get {
            return UIFont(descriptor: UIFont.preferredFont(forTextStyle: buttonTextStyle).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(frame: CGRect) { super.init(frame: frame) }
    public convenience init(
        titleText:String,
        target:Any?,
        action:Selector?,
        color:UIColor = .blue,
        style:Style = .none,
        _ withChevron:Bool = false
        ) {
        self.init(type: .custom)
        self.style = style
        self.useAttatchment = withChevron
        setTitleText(titleText,color: .white,withChevron)
        customBGColor = color
        if let target = target, let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
        translatesAutoresizingMaskIntoConstraints = false
        sharedInit()
    }
    
    func sharedInit() {
        switch style {
        case .bar:
            contentEdgeInsets = .init(top: 2.0, left: 12.0, bottom: 2.0, right: 12.0)
        case .cell:
            contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        case .none:
            break
        }
        refreshCorners(value: cornerRadius)
        refreshColor(color: customBGColor)
    }
    
    
    func setTitleText(_ text:String,color:UIColor = .white,_ withChevron:Bool = false) {
        setAttributedTitle(
            createTitleAttributedString(text,.white,withChevron),
            for: UIControl.State()
        )
    }
    
    func createTitleAttributedString(_ text:String,_ color:UIColor = .white,_ withChevron:Bool = false) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: withChevron ? "\(text) " : text,
            attributes: [
                NSAttributedString.Key.font: buttonFont,
                NSAttributedString.Key.foregroundColor : color,
                ]
        )
        
        if withChevron {
            attributedString.append(makeAttatchmentAttributedString())
        }
        
        return attributedString
    }
    
    func makeAttatchmentAttributedString() -> NSAttributedString {
        return NSAttributedString(attachment: NSTextAttachment.getCenteredImageAttachment(font: buttonFont))
    }
    
    func createImage(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0.0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }
    
    func refreshColor(color: UIColor) {
        let image = createImage(color: color)
        setBackgroundImage(image, for: UIControl.State.normal)
        clipsToBounds = true
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
    
    
    
    func updateWith(_ buttonValue:ButtonValue) {
        useAttatchment = buttonValue.useAttatchment
        let attribString = createTitleAttributedString(
            buttonValue.title,
            .white,
            useAttatchment
        )
        
        setAttributedTitle(
            attribString,
            for: UIControl.State()
        )
        refreshCorners(value: cornerRadius)
        customBGColor = buttonValue.color
    }
    
    
    func animateTitleAndColor(_ newTitle:String,_ newColor:UIColor) {
        
        let attribString = createTitleAttributedString(newTitle,.white,useAttatchment)
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.setAttributedTitle(
                attribString,
                for: UIControl.State()
            )
            self?.customBGColor = newColor
            self?.layoutSubviews()
        }
        
    }
    
}


extension NSTextAttachment {
    static func getCenteredImageAttachment(font: UIFont) -> NSTextAttachment {
        let imageAttachment = NSTextAttachment()
        let image = Image.Chevron.attatchment
        imageAttachment.bounds = CGRect(x: 0, y: (font.capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        imageAttachment.image = image
        return imageAttachment
    }
}

