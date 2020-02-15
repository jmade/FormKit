
import UIKit

public extension UIColor {
    
   static var edit:UIColor {
       if #available(iOS 13.0, *) {
           return .systemYellow
       } else {
           return .yellow
       }
   }
   
   static var delete:UIColor {
       if #available(iOS 13.0, *) {
           return .systemRed
       } else {
           return .red
       }
   }
   
   
   static var create:UIColor {
       if #available(iOS 13.0, *) {
           return .systemTeal
       } else {
           return .blue
       }
   }
   
   
   static var success:UIColor {
       if #available(iOS 13.0, *) {
           return .systemGreen
       } else {
           return .green
       }
   }
   
   static var error:UIColor {
       if #available(iOS 13.0, *) {
           return .systemRed
       } else {
           return .red
       }
   }
   
   static var warning:UIColor {
       if #available(iOS 13.0, *) {
           return .systemYellow
       } else {
           return .yellow
       }
   }
    
   static var operating:UIColor {
       if #available(iOS 13.0, *) {
           return .systemIndigo
       } else {
           return .purple
       }
   }
    
}


public struct FormConstant {
    
    static public func makeSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    static public func tintColor() -> UIColor {
        return .systemBlue
    }
    
    static public func selectedTextBackground() -> UIColor {
        return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    }
    
    
    
    public struct Color {
        
        
        static var edit:UIColor {
            if #available(iOS 13.0, *) {
                return .systemYellow
            } else {
                return .yellow
            }
        }
        
        
        
        static var delete:UIColor {
            if #available(iOS 13.0, *) {
                return .systemRed
            } else {
                return .red
            }
        }
        
        
        static var create:UIColor {
            if #available(iOS 13.0, *) {
                return .systemTeal
            } else {
                return .blue
            }
        }
        
        
        static var success:UIColor {
            if #available(iOS 13.0, *) {
                return .systemGreen
            } else {
                return .green
            }
        }
        
        static var error:UIColor {
            if #available(iOS 13.0, *) {
                return .systemRed
            } else {
                return .red
            }
        }
        
        static var warning:UIColor {
            if #available(iOS 13.0, *) {
                return .systemYellow
            } else {
                return .yellow
            }
        }
        
        
        
        static var operating:UIColor {
            if #available(iOS 13.0, *) {
                return .systemIndigo
            } else {
                return .purple
            }
        }

        
        
    }
    
    
    
}




// MARK: - FormConfigurable Protocol -
public protocol FormConfigurable {
    associatedtype Cell
    associatedtype Controller
    func didSelect(_ formController:Controller,_ path:IndexPath)
    func configureCell(_ formController:Controller,_ cell:Cell,_ path:IndexPath)
}


// MARK: - FormCellDescriptor -
public struct FormCellDescriptor {
    let cellClass: UITableViewCell.Type
    let reuseIdentifier: String
    let configure: (UIViewController,UITableViewCell,IndexPath) -> ()
    let didSelect: (UIViewController,IndexPath) -> ()
    
    public init<Cell: UITableViewCell, Controller: UIViewController>(
        _ reuseIdentifier: String,
        _ configure: @escaping (Controller,Cell,IndexPath) -> (),
        _ didSelect: @escaping (Controller,IndexPath) -> ()
        ) {
        self.cellClass = Cell.self
        self.reuseIdentifier = reuseIdentifier
        self.configure = { controller,cell,path in configure( (controller as! Controller),(cell as! Cell),path) }
        self.didSelect = { controller,path in didSelect( (controller as! Controller), path) }
    }
}


// MARK: - FormCellDescriptable Protocol -
public protocol FormCellDescriptable {
    var cellDescriptor:FormCellDescriptor { get }
}

public typealias FormValueDisplayable = FormConfigurable & FormCellDescriptable







/// EXTENTIONS



// MARK: - IndexSet -
extension IndexSet {
    static var zero: IndexSet {
        IndexSet(arrayLiteral: 0)
    }
}


// MARK: - IndexPath -
extension IndexPath {
    static var zero: IndexPath {
        IndexPath(item: 0, section: 0)
    }
}


// MARK: - Array -
extension Array {
    
    func containsItem<U: Equatable>(_ object:U) -> Bool {
        return (self.indexOf(object) != nil);
    }

    func indexOf<U: Equatable>(_ object: U) -> Int? {
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    return idx
                }
            }
        }
        return nil
    }

    mutating func removeObject<U: Equatable>(_ object: U) {
        let index = self.indexOf(object)
        if(index != nil) {
            self.remove(at: index!)
        }
    }

    func forEach(_ doThis: (_ element: Element) -> Void) {
        for e in self {
            doThis(e)
        }
    }
}



/// For ListSelection with Search to work best ?? 
extension UISearchBar {

    var textField : UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            // Fallback on earlier versions
            for view : UIView in (self.subviews[0]).subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}



//: MARK: - UIDevice -
public extension UIDevice {
    
    func deviceDataUsing(_ userId:Int) -> DeviceData {
        DeviceData(userId: userId,
                   deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "-",
                   name: UIDevice.current.name,
                   systemVersion: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
                   model: UIDevice.current.modelName,
                   pushToken: nil
        )
    }

    
    var payload:[String:String] {
        [
        "systemVersion" : UIDevice.current.systemVersion,
        "systemName"    : UIDevice.current.systemName,
        "vendorId"      : UIDevice.current.identifierForVendor?.uuidString ?? "-",
        "deviceName"    : UIDevice.current.name,
        "identifier"    : UIDevice.current.modelName,
        ]
    }
    
    
    var identifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
