
import UIKit


extension NSAttributedString {
    
    
    static func icon(_ imageName:String,textStyle:UIFont.TextStyle,tintColor:UIColor?) -> NSAttributedString {
        
        let completeText = NSMutableAttributedString(string: "")
       
        
        let imageAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            let symbolConfig = UIImage.SymbolConfiguration(textStyle: textStyle)
            if let image = UIImage(systemName: imageName, withConfiguration: symbolConfig) {
                imageAttachment.image = image.withTintColor(
                    tintColor ?? .label,
                    renderingMode: .alwaysTemplate
                )
                
                let attachmentString = NSAttributedString(attachment: imageAttachment)
                completeText.append(attachmentString)
                completeText.append(NSAttributedString(string: "\u{205F}"))
            }
        }
        
        return completeText
        
    }
    
    
    static func addIconTo(_ attribedString:NSAttributedString?,_ imageName:String) -> NSAttributedString {

        
        let completeText = NSMutableAttributedString(string: "")
       
        
        let imageAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            let symbolConfig = UIImage.SymbolConfiguration(textStyle: .subheadline)
            if let image = UIImage(systemName: imageName, withConfiguration: symbolConfig) {
                imageAttachment.image = image.withTintColor(
                    .label,
                    renderingMode: .alwaysTemplate
                )
                
                let attachmentString = NSAttributedString(attachment: imageAttachment)
                completeText.append(attachmentString)
                completeText.append(NSAttributedString(string: "\u{205F}"))
            }
        }
        if let attribedString {
            completeText.append(attribedString)
        }
        
        
        return completeText
    }
    
}



extension UIBarButtonItem {
    
    static func selectAll(_ target: Any?,_ selector:Selector) -> UIBarButtonItem {
        UIBarButtonItem(title: .selectAll, style: .plain, target: target, action: selector)
    }
    
    
    static func paste(_ target: Any?,_ selector:Selector) -> UIBarButtonItem {
        if #available(iOS 13.0, *) {
            return UIBarButtonItem(image: UIImage(systemName: "doc.on.clipboard"), style: .plain, target: target, action: selector)
        } else {
            return UIBarButtonItem(title: "Paste", style: .plain, target: target, action: selector)
        }
    }
    
    static var flex:UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
}


extension String {
    
    static var selectAll:String {
        "Select All"
    }
    
    static var deselectAll:String {
        "Deselect All"
    }
    
}




// MARK: - ValidationConfiguration -
public struct ValidationConfiguration {
    public var messageColor: UIColor?
    public var imageName: String?
    public var textStyle: UIFont.TextStyle?
    public var fontWeight: UIFont.Weight?
}

public extension ValidationConfiguration {
    
    /* warning is appropriate for Warnings.
     *
     */
    
    static var `default`: ValidationConfiguration {
        ValidationConfiguration(
            messageColor: .FormKit.valueText,
            imageName: nil,
            textStyle: .caption1,
            fontWeight: .regular
        )
    }
    
    
    
    
    static var warning: ValidationConfiguration {
        ValidationConfiguration(
            messageColor: .warning,
            imageName: "exclamationmark.triangle",
            textStyle: .caption1,
            fontWeight: .bold
        )
    }
    
    /* quaternarySystemFillColor is appropriate for filling large areas containing complex content.
     * Example: Expanded table cells.
     */
    static var error: ValidationConfiguration {
        ValidationConfiguration(
            messageColor: .red,
            imageName: "xmark.octagon",
            textStyle: .caption1,
            fontWeight: .bold
        )
    }
    
    /* quaternarySystemFillColor is appropriate for filling large areas containing complex content.
     * Example: Expanded table cells.
     */
    static var info: ValidationConfiguration {
        ValidationConfiguration(
            messageColor: .FormKit.valueText,
            imageName: "info.circle",
            textStyle: .caption1,
            fontWeight: .bold
        )
    }
    
}






// MARK: - PhoneNumberFormatter -
struct PhoneNumberFormatter {
    
    static func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var fullString = textField.text ?? ""
        fullString.append(string)
        if range.length == 1 {
            textField.text = fullString.phoneNumberFormat(shouldRemoveLastDigit: true)
        } else {
            textField.text = fullString.phoneNumberFormat()
        }
        return false
    }
    
}



extension String {
    
    func phoneNumberFormat(shouldRemoveLastDigit: Bool = false) -> String {
        let phoneNumber = self
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")

        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }

        return number
    }
    
}



extension NSAttributedString {
    
    static var spacer: NSAttributedString {
        NSAttributedString(string: "\u{205F}")
    }
    
    @available(iOS 13.0, *)
    static func validationAS(_ text:String, config: ValidationConfiguration) -> NSAttributedString {
        
        let completeText = NSMutableAttributedString(string: "")
        
        if let imageName = config.imageName {
            let imageAttachment = NSTextAttachment()
            if let textStyle = config.textStyle {
                let symbolConfig = UIImage.SymbolConfiguration(textStyle: textStyle)
                let image = UIImage(systemName: imageName, withConfiguration: symbolConfig)
                imageAttachment.image = image?.withTintColor(
                    config.messageColor ?? UIColor.FormKit.text,
                    renderingMode: .alwaysTemplate
                )
            } else {
                let image = UIImage(systemName: imageName)
                imageAttachment.image = image?.withTintColor(
                    config.messageColor ?? UIColor.FormKit.text,
                    renderingMode: .alwaysTemplate
                )
            }
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            completeText.append(attachmentString)
            
            completeText.append(.spacer)
        }
        
        var font = UIFont.preferredFont(forTextStyle: config.textStyle ?? .caption1)
        if let fontWeight = config.fontWeight {
            
            if fontWeight == .bold {
                font = font.with(.traitBold)
            }
        }
  
        // Add your text to mutable string
        let textAfterIcon = NSAttributedString(
            string: text,
            attributes: [ .font : font, .foregroundColor : config.messageColor ?? UIColor.FormKit.text ])
        completeText.append(textAfterIcon)
        return completeText
    }
    
    
    
    @available(iOS 13.0, *)
    static func errorIcon(_ iconName:String,_ text:String) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        
        let symbolConfig = UIImage.SymbolConfiguration(textStyle: .caption1)
        let image = UIImage(systemName: iconName, withConfiguration: symbolConfig)
        imageAttachment.image = image?.withTintColor(.warning, renderingMode: .alwaysTemplate)
        
        // Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        // Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        // Add image to mutable string
        completeText.append(attachmentString)
        
        let spacer = NSAttributedString(string: "\u{2007}")
        completeText.append(spacer)
        
        let descriptor = UIFont.preferredFont(forTextStyle: .caption1).fontDescriptor.withSymbolicTraits(.traitBold)!
        let font = UIFont(descriptor: descriptor, size: 0)
        
        // Add your text to mutable string
        let textAfterIcon = NSAttributedString(
            string: text,
            attributes: [.font : font ])
        completeText.append(textAfterIcon)
        return completeText
    }
    
}


@available(iOS 13.0, *)
extension Array where Element == String {
    
    
    func generateErrorsAttributedString() -> NSAttributedString {
        let completeText = NSMutableAttributedString(string: "")
        
        var a = self
        let last = a.popLast()
        
        a.map({ NSAttributedString.errorIcon("exclamationmark.triangle.fill", "\($0)\n") })
            .forEach({
                completeText.append($0)
            })
        

        if let last = last {
            completeText.append(
                NSAttributedString.errorIcon("exclamationmark.triangle.fill", "\(last)")
            )
        }
        
        return completeText
    }
    
    
    
    func renderValidationAttributedStringWith(_ config: ValidationConfiguration) -> NSAttributedString {
        let completeText = NSMutableAttributedString(string: "")
        
        var a = self
        let last = a.popLast()
        
        a.map({ NSAttributedString.validationAS("\($0)\n", config: config) })
            .forEach({
                completeText.append($0)
            })
        

        if let last = last {
            completeText.append(
                NSAttributedString.validationAS(last, config: config)
            )
        }
        
        return completeText
    }
    
    
    
    

    
    
    
}










public extension UIColor {
    
    static var inputSelected: UIColor {
        FormKit.inputSelected
    }
    
    
    struct FormKit {
        
        static var text:UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }
        
        static var titleText:UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }
        
        static var valueText:UIColor {
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .lightGray
            }
        }
        
        static var actionText:UIColor {
            if #available(iOS 13.0, *) {
                return .systemYellow
            } else {
                return .yellow
            }
        }
        
        
        static var edit:UIColor {
             if #available(iOS 13.0, *) {
                 return .systemYellow
             } else {
                 return .yellow
             }
         }
        
        
        static var save:UIColor {
            if #available(iOS 13.0, *) {
                return .systemGreen
            } else {
                return .green
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
        
        static var inputSelected:UIColor {
            if #available(iOS 13.0, *) {
                return .systemBlue
            } else {
                return .blue
            }
        }
        
        
    }
    
    
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
           return .systemBlue
       } else {
           return .purple
       }
   }
    

    static var disabled:UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return .darkGray
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
        return .clear
    }
    
    static let ALLOWED_CHARS = ".?!,()[]$*%#-=/:;"
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
        self.configure = { controller,cell,path in configure( (controller as! Controller), (cell as! Cell),path) }
        self.didSelect = { controller,path in didSelect( (controller as! Controller), path) }
    }
}


// MARK: - FormRepresentable -

// MARK: - FormItem -
public protocol FormItemRepresentable {
    var formItem:FormItem { get }
}


// MARK: - FormData-
protocol FormDataRepresentable {
    var dataSource:FormDataSource { get }
}


// MARK: - FormSection -
protocol FormSectionRepresentable {
    var fromSection:FormSection { get }
}




// MARK: - FormCellDescriptable Protocol -
public protocol FormCellDescriptable {
    var cellDescriptor:FormCellDescriptor { get }
}


// MARK: - FormValueDisplayable -
public typealias FormValueDisplayable = FormConfigurable & FormCellDescriptable





// MARK: - EXTENTIONS -
/// EXTENTIONS





public extension UIViewController {
    
    var presentedFormController:FormController? {
        if let parent = self.parent {
            if let parentPresenter = parent.presentingViewController {
                if let formController = parentPresenter.children.first as? FormController {
                    return formController
                }
            }
        }
        return nil
    }
    
}


// MARK: - UIFont -
public extension UIFont {
    
    var bold: UIFont {
        return with(.traitBold)
    }

    var italic: UIFont {
        return with(.traitItalic)
    }

    var boldItalic: UIFont {
        return with([.traitBold, .traitItalic])
    }
    
    var digit: UIFont {
        with(.traitMonoSpace)
    }
    
    var boldDigit: UIFont {
        with([.traitBold, .traitMonoSpace])
    }



    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(self.fontDescriptor.symbolicTraits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func without(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(self.fontDescriptor.symbolicTraits.subtracting(UIFontDescriptor.SymbolicTraits(traits))) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}





// MARK: - String -
extension String {
    public func split(_ s: String) -> [String]{
        return self.components(separatedBy: s)
    }
    
    
    public func safe(_ count:Int) -> String {
        guard self.count > count else {
            return self
        }
        let usableIndex = self.index(self.startIndex, offsetBy: count)
        return String(self.prefix(upTo: usableIndex))
    }
    
}



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
    
    /*
    func deviceDataUsing(_ userId:Int) -> DeviceData {
        DeviceData(userId: userId,
                   deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "-",
                   name: UIDevice.current.name,
                   systemVersion: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
                   model: UIDevice.current.modelName,
                   pushToken: nil
        )
    }
     */
    
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


//: MARK: - DATE -
extension Date{
    
    /*
    func ceiling() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute, .second], from: self)
        return (calendar as NSCalendar).date(bySettingHour: components.minute! > 0 ? components.hour! + 1 : components.hour!, minute: 0, second: 0, of: self, options: .matchFirst)!
    }
    
    func floor() -> Date {
        let calendar = Calendar.current
        let hour = (calendar as NSCalendar).components(.hour, from: self)
        return (calendar as NSCalendar).date(bySettingHour: hour.hour!, minute: 0, second: 0, of: self, options: .matchFirst)!
    }
    */
 
    func earliest() -> Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    func latest() -> Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    
    
    public func daysBefore(_ numberOfdays:Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -numberOfdays, to: self)!
    }
    
    public func daysAfter(_ numberOfdays:Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: numberOfdays, to: self)!
    }
    
    public func oneHourBefore() -> Date {
        return Calendar.current.date(byAdding: Calendar.Component.hour, value: -1, to: self, wrappingComponents: false)!
    }
    
    public func oneHourAfter() -> Date {
        return Calendar.current.date(byAdding: Calendar.Component.hour, value: 1, to: self, wrappingComponents: false)!
    }
    
    public func getHour() -> Int {
        return Calendar.current.component(Calendar.Component.hour, from: self)
    }
    
    public func getMins() -> Int {
        return Calendar.current.component(Calendar.Component.minute, from: self)
    }
    
    public func addingMins(_ mins:Int) -> Date {
        if let additiveDate = Calendar.current.date(byAdding: Calendar.Component.minute, value: mins, to: self, wrappingComponents: false) {
            return additiveDate
        } else {
            return self
        }
        
    }
    
    public func addingHours(_ hours:Int) -> Date {
        if let additiveDate = Calendar.current.date(byAdding: Calendar.Component.hour, value: hours, to: self, wrappingComponents: true) {
            return additiveDate
        } else {
            return self
        }
    }
    
    public func nearestHour() -> Date? {
        var components = Calendar.current.dateComponents([.minute], from: self)
        let minute = components.minute ?? 0
        components.minute = minute >= 30 ? 60 - minute : -minute
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    public func topOfTheNextHour() -> Date {
        if let date = Calendar.current.date(bySettingHour: Calendar.current.component(Calendar.Component.hour, from: self) + 1, minute: 0, second: 0, of: self) {
            return date
        } else {
            return self
        }
        
    }
    
    public func topOfThePreviousHour() -> Date {
        if let date = Calendar.current.date(bySettingHour: Calendar.current.component(Calendar.Component.hour, from: self) - 1, minute: 0, second: 0, of: self) {
            return date
        } else {
            return self
        }
    }
    
    public func hourString(_ showTimePeriod:Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        if showTimePeriod {
             formatter.dateFormat = "h:mm a"
        } else {
             formatter.dateFormat = "h:mm"
        }
        return formatter.string(from: self)
    }
    
    public func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/y"
        return formatter.string(from: self)
    }
    
    public func nextDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    public func previousDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    
    public
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    public
    func isTomorrow() -> Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    public
    func isWeekend() -> Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    
    public
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    public static func StartOfTheDay() -> Date {
        var calendar = Calendar.current
        calendar.timeZone = .current
       return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    }
    
    public static func EndOfTheDay() -> Date {
        var calendar = Calendar.current
        calendar.timeZone = .current
        return calendar.date(bySettingHour: 12, minute: 59, second: 59, of: Date())!
    }
    
    public
    func isBeforeToday() -> Bool {
        return self < Date.StartOfTheDay()
    }
    
    public
    func isAfterToday() -> Bool {
        return self > Date.EndOfTheDay()
    }
    
    public
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        var calendar = Calendar.current
        calendar.timeZone = .current
        
        guard let start = calendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = calendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
    
    public func daysApart(_ date:Date) -> Int? {
        var calendar = Calendar.current
        calendar.timeZone = .current
        
        if let diffInDays = calendar.dateComponents([.day], from: date, to: self).day {
            return diffInDays
        }
        return nil
    }
    

    
}
