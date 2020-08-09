//
//  ListSelectionValue.swift
//  AudioPlayground
//
//  Created by Justin Madewell on 12/29/19.
//  Copyright © 2019 MadewellTech. All rights reserved.
//

import UIKit

public typealias ListSelectLoadingClosure = (ListSelectViewController) -> Void

// JSON -> ListSelectionValue transform closure

//public typealias JSONGenerationClosure = ([String:Any]) -> ListSelectionValue?

public typealias JSONGenerationClosure = ([String:Any],ListSelectionValue.Loading) -> ListSelectionValue?

 


// MARK: - ListSelectionValue -
public struct ListSelectionValue {
    
    
    public struct Loading {
       public var itemKey: String
       public var loadingClosure: ListSelectLoadingClosure? = nil
       public var matchingIntegerValues: [Int]? = nil
       public var matchingStringValues: [String]? = nil
        
        public init(_ matchingValues:[Int],itemKey:String,loadingClosure: @escaping ListSelectLoadingClosure) {
            self.itemKey = itemKey
            self.loadingClosure = loadingClosure
            self.matchingIntegerValues = matchingValues
        }
        
        public init(_ matchingValues:[String],itemKey:String,loadingClosure: @escaping ListSelectLoadingClosure) {
            self.itemKey = itemKey
            self.loadingClosure = loadingClosure
            self.matchingStringValues = matchingValues
            
        }
        
        public var matchingOnString: Bool {
            return matchingIntegerValues == nil
        }
        
    }
    
    
    
    public enum SelectionType { case single, multiple }
    public var selectionType: SelectionType
    
    public var values:[String]
    public var selectedIndicies: [Int]
    
    var title:String
    var selectionMessage:String = "Select a Value"
    var color:UIColor? = nil
    var valueIdentifiers:[String]? = nil
    
    public var loading:Loading? = nil
    
    public var loadingClosure: ListSelectLoadingClosure? = nil
    public var generationClosure: JSONGenerationClosure? = nil
    
    public var customKey: String? = nil
    var uuid:String = UUID().uuidString
    
}


extension ListSelectionValue: Equatable, Hashable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(uuid)
    }
    
    public static func == (lhs: ListSelectionValue, rhs: ListSelectionValue) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}


/// Rules here would be, if `values.isEmpty == true`
/// then the valueIdentifiers would serve as the loading matching index....


extension ListSelectionValue {

    public var listItems:[ListSelectViewController.ListItem] {
        var items:[ListSelectViewController.ListItem] = []
        
        for (i,value) in values.enumerated() {
            var id:String? = nil
            
            if let identifiers = valueIdentifiers {
                if i <= (identifiers.count - 1) {
                    id = identifiers[i]
                }
            }
            
            items.append(
                ListSelectViewController.ListItem(
                    value,
                    id,
                    selectedIndicies.contains(i)
                )
            )
        }
        
        return items
        
    }

}



extension ListSelectionValue {
    
    public init(title:String,values:[String],_ color:UIColor = .black,_ selectedIndex:Int = 0,_ selectionMessage:String = "Select a Value"){
        self.values = values
        self.selectedIndicies = [selectedIndex]
        self.title = title
        self.selectionType = .single
        self.selectionMessage = selectionMessage
        
        if color == UIColor.black {
            if #available(iOS 13.0, *) {
                self.color = .label
            } else {
                self.color = color
            }
        }
        
        
    }
    
    /// Single Selection
    public init(title:String, values:[String], selectedIndex:Int) {
        self.values = values
        self.selectedIndicies = [selectedIndex]
        self.title = title
        self.selectionMessage = "Select a Value"
        self.selectionType = .single
        self.color = nil
    }
    
    /// Multi Selection
    public init(title:String, values:[String], selected:[Int]) {
        self.values = values
        self.selectedIndicies = selected
        self.title = title
        self.selectionMessage = "Select Values"
        self.selectionType = .multiple
        self.color = nil
    }
    
    
    public init(_ title:String,_ values:[String],_ loadingClosure: ListSelectLoadingClosure? = nil) {
        self.values = values
        self.selectedIndicies = []
        self.title = title
        self.selectionMessage = "Select a Value"
        self.selectionType = .single
        self.loadingClosure = loadingClosure
        self.color = nil
    }
    
    // pass in matchedvalues...
    public init(_ title:String,loading:Loading,_ loadingClosure: @escaping ListSelectLoadingClosure) {
        self.values = []
        self.selectedIndicies = []
        self.title = title
        self.selectionMessage = "Select a Value"
        self.selectionType = .multiple
        self.loadingClosure = loadingClosure
        self.color = nil
        self.loading = loading
    }
    
    
}



extension ListSelectionValue {
    
    var idKey: String {
        return "\(uuid.split(separator: "-")[1])"
    }
    
    var selectionTitle: String {
       
        switch selectionType {
        case .single:
            
            if let idx = selectedIndicies.first {
                if values.count > idx {
                    return values[idx]
                } else {
                    return "-"
                }
            } else {
                return ""
            }
        case .multiple:
            return "\(selectedIndicies.count) Selected"
        }
    }
    
    var selectedValues: [String] {
        return selectedIndicies.map({ values[$0] })
    }
    
}





// MARK: - FormValue -
extension ListSelectionValue: FormValue {
    
    public var formItem: FormItem {
        FormItem.listSelection(self)
    }
    
    
    
    public func encodedValue() -> [String : String] {
        return [ (customKey ?? "\(title)_\(idKey)") : "\(selectedValues)" ]
        
        /*
        if customKey == nil {
            switch selectionType {
            case .single:
                return ["\(title)_\(idKey)" : "\(selectedValues)" ]
            case .multiple:
                return ["\(title)_\(idKey)" : "\(selectedValues)" ]
            }
        } else {
            return [(customKey ?? "-"):"\(selectedValues)"]
        }
        */
    }
}

extension ListSelectionValue {
    
    func makeDescriptor(_ changeClosure: @escaping ListSelectionChangeClosure = DefaultChangeClosure) -> ListSelectionControllerDescriptor {
        return
            .init(
                title: self.title,
                values: self.values,
                selected: self.selectedIndicies,
                allowsMultipleSelection: (selectionType == .multiple),
                message: self.selectionMessage,
                changeClosure: changeClosure
        )
    }
    
    func newWith(_ selectedValues:[String]) -> ListSelectionValue {
        
        var newSelectedIndicies: [Int] = []
        for selected in selectedValues {
            if let index = values.firstIndex(of: selected) {
                newSelectedIndicies.append(index)
            }
        }
        return
            ListSelectionValue(
                selectionType: self.selectionType,
                values: self.values,
                selectedIndicies: newSelectedIndicies,
                title: self.title,
                selectionMessage: self.selectionMessage,
                color: self.color,
                valueIdentifiers: self.valueIdentifiers,
                loadingClosure: self.loadingClosure,
                customKey: self.customKey,
                uuid: self.uuid
        )
    }
    
    
    public func newWith(selectedValues:[String],_ selectedValueIdentifiers:[String]? = nil) -> ListSelectionValue {
        var newSelectedIndicies: [Int] = []
        for selected in selectedValues {
            if let index = values.firstIndex(of: selected) {
                newSelectedIndicies.append(index)
            }
        }
        
        return
            ListSelectionValue(
                selectionType: self.selectionType,
                values: self.values,
                selectedIndicies: newSelectedIndicies,
                title: self.title,
                selectionMessage: self.selectionMessage,
                color: self.color,
                valueIdentifiers: selectedValueIdentifiers,
                loading: self.loading,
                loadingClosure: self.loadingClosure,
                generationClosure: self.generationClosure,
                customKey: self.customKey,
                uuid: self.uuid
        )
    }
    
    
    
    
    public func newWith(_ listItems:[ListSelectViewController.ListItem]) -> ListSelectionValue  {
        
        print("new with list items")
        
        var newSelectedIndicies: [Int] = []
        
        for (i,listItem) in listItems.enumerated() {
            if listItem.selected {
                newSelectedIndicies.append(i)
            }
        }
        
        let newValues = listItems.map({ $0.title })
        let newIdentifiers = listItems.compactMap({ $0.identifier })
        
        print(" newIdentifiers -> \(newIdentifiers) ")
        
        
        var newLoading:Loading? = nil
        if let currentLoading = self.loading {
            
           
            
            newLoading = currentLoading
            
            if currentLoading.matchingStringValues != nil {
                /// `[String]`
                print("NewLoading Matching String: \(currentLoading.matchingStringValues!)")
                newLoading?.matchingStringValues = newIdentifiers
            } else {
                /// `[Int]`
                print("NewLoading Matching Int: \(currentLoading.matchingIntegerValues!)")
                newLoading?.matchingIntegerValues = newIdentifiers.compactMap({ Int($0) })
            }
        }
        
        return
            ListSelectionValue(
                selectionType: self.selectionType,
                values: newValues,
                selectedIndicies: newSelectedIndicies,
                title: self.title,
                selectionMessage: self.selectionMessage,
                color: self.color,
                valueIdentifiers: newIdentifiers,
                loading: newLoading,
                loadingClosure: self.loadingClosure,
                generationClosure: self.generationClosure,
                customKey: self.customKey,
                uuid: self.uuid
        )
    }
    
}


// MARK: - FormValueDisplayable -
extension ListSelectionValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = ListSelectionCell
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor("\(Cell.identifier)_\(idKey)", configureCell, didSelect)
        /*
        switch selectionType {
        case .single:
            return FormCellDescriptor("\(Cell.identifier)_\(idKey)", configureCell, didSelect)
        case .multiple:
            return FormCellDescriptor("\(Cell.identifier)_\(idKey)", configureCell, didSelect)
        }
        */
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }

    public func didSelect(_ formController: Controller, _ path: IndexPath) {
       
        
        let listVC = ListSelectViewController(self, at: path)
        listVC.formDelegate = formController
        formController.navigationController?.pushViewController(
            listVC,
            animated: true
        )
        
    }
    
}


extension ListSelectionValue {
    
   public static func DemoSingle() -> ListSelectionValue {
        return
            ListSelectionValue(
                title: "Single-Demo",
                values: stride(from: 0, to: 32, by: 1).map({ "Item \($0)" }),
                selectedIndex: 1
        )
    }
    
    
   public static func DemoMulti() -> ListSelectionValue {
        return
            ListSelectionValue(
                title: "Multi-Demo",
                values: stride(from: 0, to: 32, by: 1).map({ "Multiple Item: \($0)" }),
                selected: [1,3,7]
        )
    }
    
}



// MARK: ListSelectionCell
final public class ListSelectionCell: UITableViewCell {
    static let identifier = "FormKit.ListSelectionCell"
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = .label
        }
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        return label
    }()
    
    lazy var selectionLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
             label.textColor = .gray
        }
        label.textAlignment = .right
        return label
    }()
    
    var formValue : ListSelectionValue? {
        didSet {
            if let listSelectValue = formValue {
                titleLabel.text = listSelectValue.title
                selectionLabel.text = listSelectValue.selectionTitle
                if let path = indexPath {
                    updateFormValueDelegate?.updatedFormValue(listSelectValue, path)
                }
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [titleLabel,selectionLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        })
        
        activateDefaultHeightAnchorConstraint()
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            selectionLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            selectionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            selectionLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8.0),
            ])
        
        accessoryType = .disclosureIndicator
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        selectionLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 499), for: .horizontal)
    }
    
    
    override public func prepareForReuse() {
        titleLabel.text = nil
        selectionLabel.text = nil
        formValue = nil
        super.prepareForReuse()
    }
    
}

