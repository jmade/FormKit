//
//  TextFieldCell.swift
//  ResizingTokenField
//
//  Created by Tadej Razborsek on 19/06/2019.
//  Copyright © 2019 Tadej Razborsek. All rights reserved.
//

import UIKit

private class DeleteDetectingTextField: UITextField {
    var onDeleteBackwardWhenEmpty: (() -> ())?
    
    override public func deleteBackward() {
        let isEmpty: Bool = text?.isEmpty ?? false
        super.deleteBackward()
        
        if isEmpty {
            onDeleteBackwardWhenEmpty?()
        }
    }
}

class TextFieldCell: UICollectionViewCell {
    
    /// Implement to handle text field changes.
    var onTextFieldEditingChanged: ((String?) -> Void)?
    
    /// Implement to handle delete backward when empty.
    var onDeleteBackwardWhenEmpty: (() -> ())?
    
    let textField: UITextField = DeleteDetectingTextField(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    private func setUp() {
        addSubview(textField)
        
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        (textField as? DeleteDetectingTextField)?.onDeleteBackwardWhenEmpty = { [weak self] in
            self?.onDeleteBackwardWhenEmpty?()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }
    
    // MARK: - Handling text field changes
    
    @objc func textFieldEditingChanged(textField: UITextField) {
        if textField == self.textField {
            onTextFieldEditingChanged?(textField.text)
        }
    }
    
}
