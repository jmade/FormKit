

import UIKit


extension UITextField {
  
  func setCursorLocation(_ location: Int) {
    if let cursorLocation = position(from: beginningOfDocument, offset: location) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.selectedTextRange = self.textRange(from: cursorLocation, to: cursorLocation)
      }
    }
  }
}
