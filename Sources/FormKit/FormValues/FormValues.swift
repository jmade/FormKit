import UIKit


public protocol Activatable {
    func activate()
}

public protocol TableViewSelectable {
    var isSelectable: Bool { get }
}

public protocol CustomKeyProvidable {
    var customKey: String? { get set }
}



// MARK: - ValueEncodable -
public protocol ValueEncodable {
    func encodedValue() -> [String:String]
}

extension ValueEncodable {
    public func encodedValue() -> [String:String] {
        return [:]
    }
}


// MARK: - FormEncodable -
public typealias FormEncodable = CustomKeyProvidable & ValueEncodable


// MARK: - FormItemizable -
public protocol FormItemizable {
    var formItem: FormItem { get }
}

// MARK: - FormValue -
public typealias FormValue = FormItemizable & FormEncodable


public protocol TextNumericalInput {}

// MARK: - Direction -
public enum Direction {
    case previous, next
}

// MARK: - UpdateFormValueDelegate -
public protocol UpdateFormValueDelegate: AnyObject {
    func updatedFormValue(_ formValue:FormValue,_ indexPath:IndexPath?)
    func toggleTo(_ direction:Direction,_ from:IndexPath)
}

// MARK: - UpdatedTextDelegate
public protocol UpdatedTextDelegate: AnyObject {
    func updatedTextForIndexPath(_ newText:String,_ indexPath:IndexPath)
    func toggleTo(_ direction:Direction,_ from:IndexPath)
    func textEditingFinished(_ text:String,_ from:IndexPath)
}


extension UITableViewCell {

    func activateDefaultHeightAnchorConstraint(_ constant:CGFloat = 44.0) {
        let heightAnchorConstraint = self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: constant)
        heightAnchorConstraint.priority = UILayoutPriority(rawValue: 499)
        heightAnchorConstraint.isActive = true
    }
    
}


extension Array where Element == [String:String] {

    func merged() -> [String:String] {
        return reduce(into: [String:String]()) {
            $0.merge($1) { (_, new) in new }
        }
    }

}
