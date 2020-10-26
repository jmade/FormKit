

import UIKit

class SearchTextField: UITextField {
    
    var textPadding = UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0)
    
    init() {
        super.init(frame: .zero)
        self.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 12.0
        
        clearButtonMode = .always
        autocapitalizationType = .none
        autocorrectionType = .no
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
            leftView = UIImageView(image: UIImage(systemName: "magnifyingglass.circle"))
        }
        placeholder = "Search"
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    
    // Padding for text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
       return rect.inset(by: textPadding)
    }
    // Padding for text in editting mode
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
       let rect = super.editingRect(forBounds: bounds)
       return rect.inset(by: textPadding)
    }
    
}
