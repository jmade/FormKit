// Thanks to Mike Sprague

import UIKit

protocol PasswordToggleVisibilityDelegate: class {
    func viewWasToggled(_ passwordToggleVisibilityView: PasswordToggleVisibilityView, isSelected selected: Bool)
}

class PasswordToggleVisibilityView: UIView {
    
    fileprivate let eyeOpenedImage: UIImage = {
        if #available(iOS 13.0, *) {
            if let image = UIImage(systemName: "eye") {
                return image
            }
            return UIImage()
        } else {
            return UIImage()
        }
    }()
    
    
    fileprivate let eyeClosedImage: UIImage = {
           if #available(iOS 13.0, *) {
            if let image = UIImage(systemName: "eye.slash") {
                           return image
                       }
                       return UIImage()
           } else {
               return UIImage()
           }
       }()
    
    fileprivate let checkmarkImage: UIImage  = {
           if #available(iOS 13.0, *) {
            if let image = UIImage(systemName: "checkmark") {
                           return image
                       }
                       return UIImage()
           } else {
               return UIImage()
           }
       }()
    
    
    fileprivate let eyeButton: UIButton
    fileprivate let checkmarkImageView: UIImageView
    weak var delegate: PasswordToggleVisibilityDelegate?
    
    enum EyeState {
        case open
        case closed
    }
    
    var eyeState: EyeState {
        set {
            eyeButton.isSelected = newValue == .open
        }
        get {
            return eyeButton.isSelected ? .open : .closed
        }
    }
    
    
    var checkmarkVisible: Bool {
        set {
            let isHidden = !newValue
            guard checkmarkImageView.isHidden != isHidden else {
                return
            }
            checkmarkImageView.isHidden = isHidden
        }
        get {
            return !checkmarkImageView.isHidden
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            eyeButton.tintColor = tintColor
            checkmarkImageView.tintColor = tintColor
        }
    }
    
    override init(frame: CGRect) {
        
      
        
//        self.eyeOpenedImage = UIImage(named: "eye_open")!.withRenderingMode(.alwaysTemplate)
//        self.eyeClosedImage = UIImage(named: "eye_closed")!.withRenderingMode(.alwaysTemplate)
//        self.checkmarkImage = UIImage(named: "checkmark")!.withRenderingMode(.alwaysTemplate)
        self.eyeButton = UIButton(type: .custom)
        self.checkmarkImageView = UIImageView(image: self.checkmarkImage)
        super.init(frame: frame)
        setupViews()
    }
    
    init() {
//        self.eyeOpenedImage = UIImage(named: "eye_open")!.withRenderingMode(.alwaysTemplate)
//        self.eyeClosedImage = UIImage(named: "eye_closed")!.withRenderingMode(.alwaysTemplate)
//        self.checkmarkImage = UIImage(named: "checkmark")!.withRenderingMode(.alwaysTemplate)
        self.eyeButton = UIButton(type: .custom)
        self.checkmarkImageView = UIImageView(image: self.checkmarkImage)
        super.init(frame: .zero)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use init with coder.")
    }
    
    fileprivate func setupViews() {
        eyeButton.backgroundColor = UIColor.clear
        eyeButton.adjustsImageWhenHighlighted = false
        eyeButton.setImage(self.eyeClosedImage, for: UIControl.State())
        eyeButton.setImage(self.eyeOpenedImage.withRenderingMode(.alwaysTemplate), for: .selected)
        eyeButton.addTarget(self, action: #selector(PasswordToggleVisibilityView.eyeButtonPressed(_:)), for: .touchUpInside)
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.tintColor = self.tintColor
        self.addSubview(eyeButton)
        
        eyeButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        eyeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.0).isActive = true
        eyeButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        eyeButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        let checkmarkImageWidth = (frame.width / 2) - 10
        let checkmarkFrame = CGRect(x: 10, y: 0, width: checkmarkImageWidth, height: frame.height)
        checkmarkImageView.frame = checkmarkFrame
        checkmarkImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        checkmarkImageView.contentMode = .center
        checkmarkImageView.backgroundColor = UIColor.clear
        checkmarkImageView.tintColor = self.tintColor
        self.addSubview(checkmarkImageView)
        self.checkmarkImageView.isHidden = true
    }
    
    
    @objc func eyeButtonPressed(_ sender: AnyObject) {
        eyeButton.isSelected = !eyeButton.isSelected
        delegate?.viewWasToggled(self, isSelected: eyeButton.isSelected)
    }
}

