//
//  File.swift
//  
//
//  Created by Justin Madewell on 6/13/22.
//

import UIKit

fileprivate extension UILabel {
    
    static func validationError(_ text:String) -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .caption2).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }
    
}


fileprivate extension UIImageView {
    
    static func validationIconView(_ image:UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.FormKit.text
        if #available(iOS 13.0, *) {
            imageView.preferredSymbolConfiguration = .init(textStyle: .caption2, scale: .medium)
        } else {
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: UIFont.preferredFont(forTextStyle: .caption2).lineHeight).isActive = true
        }
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.image = image
        return imageView
    }
    
}

fileprivate extension UIStackView {
    
    static var validationContainer: UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.alignment = .center
        return stack
    }
    
    static func validationEntry() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 8.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
}




final class ValidationErrorCellView: UIView {
    
    private let container = UIStackView.validationContainer
    
    private var iconImage:UIImage?
    private var errorMessages:[String] = [] {
        didSet {
            load()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(_ errors:[String] = [],_ image:UIImage? = nil) {
        super.init(frame: .zero)
        self.iconImage = image
        self.errorMessages = errors
        
        self.backgroundColor = .green
        self.layer.cornerRadius = 8.0
        self.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.yellow.cgColor
        
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
                
        container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2.0).isActive = true
        container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2.0).isActive = true
        container.topAnchor.constraint(equalTo: topAnchor, constant: 2.0).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2.0).isActive = true

        load()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func set(_ errors:[String],_ image:UIImage? = nil) {
        if let image = image {
            iconImage = image
        }
        errorMessages = errors
    }
    
    
    private func load() {
        container.subviews.forEach({ $0.removeFromSuperview() })
        
        for message in errorMessages {
            container.addArrangedSubview(
                makeEntryStack(iconImage, message)
            )
        }
        
        layoutIfNeeded()
    }
    
    
    private func makeEntryStack(_ image:UIImage?,_ message:String) -> UIStackView {
        let stack = UIStackView.validationEntry()
        
        if let image = image {
            let imageView = UIImageView.validationIconView(image)
            stack.addArrangedSubview(
                imageView
            )
        }
        
        let label = UILabel.validationError(message)
        stack.addArrangedSubview(
            label
        )
        
        return stack
    }
    
}






