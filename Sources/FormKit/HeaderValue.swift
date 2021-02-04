

import UIKit



// MARK: - HeaderValue -
public struct HeaderValue {
    
    // MARK: - State -
    public enum State {
        case expanded, collapsed
    }
    
    public var state:State = .expanded
    
    // MARK: - IconStyle -
    public enum IconStyle {
        case leading, trailing, none
    }
    public var iconStyle:IconStyle = .trailing
    
    public enum ImageType {
        case none, custom(String), plusMinus, plus,expand, chevron, addPhone, addPerson
    }
    
    public var imageType:ImageType = .none
    
    public var section:Int
    public var title:String
    public var subtitle:String?
    public var isInteractable:Bool = false
    public var lastSectionHeight:Double? = nil
}


extension HeaderValue {
    
    public init() {
        self.title = ""
        self.section = -1
    }
    
    
    public init(title:String,section:Int) {
        self.title = title
        self.section = section
    }
    
    public init(title:String, section:Int, imageType:ImageType, iconStyle:IconStyle, isInteractable:Bool, state:State = .expanded) {
        self.title = title
        self.section = section
        self.imageType = imageType
        self.iconStyle = iconStyle
        self.isInteractable = isInteractable
        self.state = state
    }
    
}


extension HeaderValue {
    
    public init(expandedTitle:String) {
        self.title = expandedTitle
        self.section = -1
        self.imageType = .expand
        self.iconStyle = .leading
        self.isInteractable = true
        self.state = .expanded
    }
    
    public init(collapsedTitle:String) {
        self.title = collapsedTitle
        self.section = -1
        self.imageType = .expand
        self.iconStyle = .leading
        self.isInteractable = true
        self.state = .collapsed
    }
    
}





extension HeaderValue {

    mutating func toggleMode(_ sectionHeight:Double){
        guard isInteractable else { return }
        self.lastSectionHeight = sectionHeight
        switch self.state {
        case .expanded:
            self.state = .collapsed
        case .collapsed:
            self.state = .expanded
        }
    }
    
    mutating func updateSection(_ newSection:Int,_ newTitle:String? = nil) {
        self.section = newSection
        if let newTitle = newTitle {
            self.title = newTitle
        }
    }

    var indexSet:IndexSet {
        IndexSet(arrayLiteral: section)
    }
    
}




extension HeaderValue {
    
   
        struct Image {
            
            static let chevronCollapsed:UIImage = {
                if #available(iOS 13.0, *) {
                    guard let img = UIImage(systemName:"chevron.right.circle.fill" ) else {
                        return UIImage()
                    }
                    return img
                } else {
                    return UIImage()
                }
            }()
            
            
            static let chevronExpanded: UIImage = {
                if #available(iOS 13.0, *) {
                    guard let img = UIImage(systemName:"chevron.down.circle.fill" ) else {
                        return UIImage()
                    }
                   
                    return img
                } else {
                    return UIImage()
                }
            }()
            
            
            static let plus: UIImage = {
                if #available(iOS 13.0, *) {
                    guard let img = UIImage(systemName:"plus.circle" ) else {
                        return UIImage()
                    }
                    return img
                } else {
                    return UIImage()
                }
            }()
            
            
            static let plusFilled: UIImage = {
                if #available(iOS 13.0, *) {
                    guard let img = UIImage(systemName:"plus.circle.fill" ) else {
                        return UIImage()
                    }
                    return img
                } else {
                    return UIImage()
                }
            }()
            
            
            static let minus: UIImage = {
                if #available(iOS 13.0, *) {
                    guard let img = UIImage(systemName:"minus.circle" ) else {
                        return UIImage()
                    }
                    return img
                } else {
                    return UIImage()
                }
            }()
            
            
            static let minusFilled: UIImage = {
                if #available(iOS 13.0, *) {
                    guard let img = UIImage(systemName:"minus.circle.fill" ) else {
                        return UIImage()
                    }
                    return img
                } else {
                    return UIImage()
                }
            }()
            
            
        }
        

    
}
