//
//  ListSelectionValue.swift
//  AudioPlayground
//
//  Created by Justin Madewell on 12/29/19.
//  Copyright © 2019 MadewellTech. All rights reserved.
//

import UIKit

public typealias ListSelectLoadingClosure = (ListSelectViewController) -> Void

public typealias ListItem = ListSelectViewController.ListItem
public typealias JSONGenerationClosure = ([String:Any],ListSelectionValue.Loading) -> ([ListItem])
public typealias ListItemSelectionClosure = (ListItem,UINavigationController?) -> Void
public typealias ListSelectValueChangeClosure = ( (ListSelectionValue,FormController,IndexPath) -> Void )

 


// MARK: - ListSelectionValue -
public struct ListSelectionValue {
    
    
    public struct Loading {
       public var itemKey: String
       public var loadingClosure: ListSelectLoadingClosure? = nil
       public var matchingIntegerValues: [Int]? = nil
       public var matchingStringValues: [String]? = nil
        
        public init(_ matchingValues:[Int]?,itemKey:String?,loadingClosure: @escaping ListSelectLoadingClosure) {
            if let _itemKey = itemKey {
                self.itemKey = _itemKey
            } else {
                self.itemKey = ""
            }
            
            self.loadingClosure = loadingClosure
            self.matchingIntegerValues = matchingValues
        }
        
        public init(_ matchingValues:[String]?,itemKey:String?,loadingClosure: @escaping ListSelectLoadingClosure) {
            if let _itemKey = itemKey {
                self.itemKey = _itemKey
            } else {
                self.itemKey = ""
            }
            
            self.loadingClosure = loadingClosure
            self.matchingStringValues = matchingValues
            
        }
        
        
        public init(itemKey:String?,loadingClosure: @escaping ListSelectLoadingClosure) {
            if let _itemKey = itemKey {
                self.itemKey = _itemKey
            } else {
                self.itemKey = ""
            }
            
            self.loadingClosure = loadingClosure
        }
        
        
        public init(loadingClosure: @escaping ListSelectLoadingClosure) {
            self.itemKey = ""
            self.loadingClosure = loadingClosure
        }
        
        public var matchingOnString: Bool {
            return matchingIntegerValues == nil
        }
        
    }
    
    
    
    public enum SelectionType { case single, multiple }
    public var selectionType: SelectionType
    
    public var values:[String]
    public var selectedIndicies: [Int]
    
    public var title:String
    var selectionMessage:String = "Select a Value"
    var color:UIColor? = nil
    var valueIdentifiers:[String]? = nil
    
    public var loading:Loading? = nil
    
    public var loadingClosure: ListSelectLoadingClosure? = nil
    public var generationClosure: JSONGenerationClosure? = nil
    
    public var customKey: String? = nil
    var uuid:String = UUID().uuidString
    
    public var listItems:[ListItem] = []
    public var underlyingObjects:[Any] = []
    public var listItemSelection: ListItemSelectionClosure?
    public var valueChangeClosure: ListSelectValueChangeClosure?
    public var storageValue:Codable?
    
    
    public struct WriteInConfiguration {
        
        public enum Placement {
            case topSection, topRow, bottomSection
        }
        
        public let allowsWriteIn:Bool = true
        public var preventValueUpdate:Bool = false
        public var textValue:TextValue?
        public var placement: Placement = .topRow
        
    }
    public var writeInConfiguration: WriteInConfiguration?
    
    //public var allowsWriteIn:Bool = false
    //public var preventValueUpdate:Bool = false // if true, the selected value wont appear. rare use case.
    
}


extension ListSelectionValue {
    
    public var allowsWriteIn:Bool {
        if let _ = writeInConfiguration {
            return true
        }
        return false
    }
    
    public var preventValueUpdate:Bool {
        if let config = writeInConfiguration {
            return config.preventValueUpdate
        }
        return false
    }
    
}


extension ListSelectionValue.WriteInConfiguration {
    
    
    public init(_ textValue:TextValue,_ preventValueUpdate:Bool = false) {
        self.preventValueUpdate = preventValueUpdate
        self.textValue = textValue
    }
    
    
    public init(_ placeholder:String?,_ preventValueUpdate:Bool = false) {
        self.preventValueUpdate = preventValueUpdate
        if let p = placeholder {
            self.textValue = TextValue("", nil, p)
        }
    }
    
    public init(_ placeholder:String?,_ placement: Placement) {
        self.placement = placement
        if let p = placeholder {
            self.textValue = TextValue("", nil, p)
        }
    }
    
    public init(_ textValue:TextValue? = nil,_ placement: Placement) {
        self.textValue = textValue
        self.placement = placement
    }
    
    public init(_ textValue:TextValue) {
        self.textValue = textValue
        self.placement = .topRow
    }
    
    
    
}



extension ListSelectionValue: CustomStringConvertible {
    public var description: String {
        """
        Title: \(title)
        Selected: \(selectedValue ?? "None")
        Underlying Object Count: \(underlyingObjects.count)
        Underlying Type: \( (underlyingObjects.count > 0) ? type(of: underlyingObjects[0]) : type(of: underlyingObjects.first) )
        """
    }
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
    
    public func matchesContent(_ other:ListSelectionValue) -> Bool {
        return other.title == self.title && other.customKey == self.customKey
    }
    
    public var selectionRows:[ListSelectViewController.SelectionRow] {
        return listItems
    }
    
    public mutating func removeSelection() {
        self.selectedIndicies = []
        for (i,item) in self.listItems.enumerated() {
            self.listItems[i] = item.unselected()
        }
    }
    

}



extension ListSelectionValue {
    
    public init(title:String,values:[String],_ color:UIColor = .black,_ selectedIndex:Int?,_ selectionMessage:String = "Select a Value"){
        self.values = values
        self.selectedIndicies = (selectedIndex != nil) ? [selectedIndex!] : []
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
        
        self.listItems = items
        
    }
    
    /// Multi Selection
    public init(title:String, values:[String], selected:[Int]) {
        self.values = values
        self.selectedIndicies = selected
        self.title = title
        self.selectionMessage = "Select Values"
        self.selectionType = .multiple
        self.color = nil
        
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
        
        self.listItems = items
        
    }
    
    
    public init(_ title:String,_ values:[String],_ loadingClosure: ListSelectLoadingClosure? = nil) {
        self.values = values
        self.selectedIndicies = []
        self.title = title
        self.selectionMessage = "Select a Value"
        self.selectionType = .single
        self.loadingClosure = loadingClosure
        self.color = nil
        
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
        
        self.listItems = items
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
        
        self.listItems = items
        
    }
    
    
    public init(title:String,_ selectionType: SelectionType = .multiple,_ loadingClosure: @escaping ListSelectLoadingClosure) {
        self.values = []
        self.selectedIndicies = []
        self.title = title
        self.selectionMessage = "Select a Value"
        self.selectionType = selectionType
        self.loadingClosure = loadingClosure
        self.color = nil
        self.loading = nil
        
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
        
        self.listItems = items
    }
    
    
    
    public init(_ title:String,_ customKey:String? = nil,_ listItems:[ListSelectViewController.ListItem],_ selectionType: SelectionType = .single) {
        self.values = []
        self.selectedIndicies = []
        self.title = title
        self.selectionMessage = "Select a Value"
        self.selectionType = selectionType
        self.loadingClosure = nil
        self.color = nil
        self.loading = nil
        self.listItems = listItems
        self.customKey = customKey
        
    }
    
    
    public init(_ title:String,_ customKey:String? = nil,_ listItems:[ListSelectViewController.ListItem],_ underlyingObjects:[Any]) {
        self.values = []
        self.selectedIndicies = []
        self.title = title
        self.selectionMessage = "Select a Value"
        self.selectionType = .single
        self.loadingClosure = nil
        self.color = nil
        self.loading = nil
        self.listItems = listItems
        self.customKey = customKey
        self.underlyingObjects = underlyingObjects
    }
    
    public init(_ title:String,_ customKey:String,_ listItems:[ListSelectViewController.ListItem],_ writeInConfig:ListSelectionValue.WriteInConfiguration) {
        self.values = []
        self.selectedIndicies = []
        self.title = title
        self.selectionMessage = "Select a Value"
        self.selectionType = .single
        self.loadingClosure = nil
        self.color = nil
        self.loading = nil
        self.listItems = listItems
        self.customKey = customKey
        self.underlyingObjects = []
        self.writeInConfiguration = writeInConfig
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
                if let value = selectedValue {
                    return value
                }
                return ""
            }
        case .multiple:
            return "\(selectedIndicies.count) Selected"
        }
    }
    
    
    var selectedValues: [String] {
        var vals:[String] = []
        for sel in selectedIndicies {
            if values.count >= (sel+1) {
                vals.append(values[sel])
            }
        }
        
        return vals
    }
    
}





// MARK: - FormValue -
extension ListSelectionValue: FormValue {
    
    public var formItem: FormItem {
        .listSelection(self)
    }
    
    
    public var selectedValue:String? {
        listItems.filter({ $0.selected }).first?.title
    }
    
    private var selectedIdentifier:String? {
        listItems.filter({ $0.selected }).first?.identifier
    }
    
    private var encodedSelectedValue:String? {
        if let id = selectedIdentifier {
            return id
        }
        
        if let val = selectedValue {
            return val
        }
        
        return nil
    }
    
    
    private var encodedSelectedValues:String? {
        let identifiers = listItems.filter({ $0.selected }).compactMap({ $0.identifier })
        if identifiers.isEmpty {
            let titles = listItems.filter({ $0.selected }).map({ $0.title })
            if titles.isEmpty {
                return nil
            } else {
                return titles.joined(separator: ",")
            }
        } else {
            return identifiers.joined(separator: ",")
        }
    }
    
    
    public func encodedValue() -> [String : String] {
        switch selectionType {
        case .single:
            return [ (customKey ?? title ) : ( encodedSelectedValue ?? "" ) ]
        case .multiple:
            return [ (customKey ?? title ) : ( encodedSelectedValues ?? "" ) ]
        }
    }
    
    
    public var selectedListItem:ListItem? {
        return listItems.filter({ $0.selected }).first
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
        
        var new = ListSelectionValue(
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
        new.listItems = listItems
        new.underlyingObjects = self.underlyingObjects
        new.listItemSelection = self.listItemSelection
        new.valueChangeClosure = self.valueChangeClosure
        new.writeInConfiguration = self.writeInConfiguration
        //new.allowsWriteIn = self.allowsWriteIn
        //new.preventValueUpdate = self.preventValueUpdate
        return new
    }

    
    
    
    
    public func newWith(_ listItems:[ListSelectViewController.ListItem],_ fromLoading:Bool = false) -> ListSelectionValue  {
        
        var newSelectedIndicies: [Int] = []
        var newMatchingStringValues:[String] = []
        
        
        for (i,listItem) in listItems.enumerated() {
            if listItem.selected {
                newSelectedIndicies.append(i)
                newMatchingStringValues.append(listItem.identifier ?? "!?")
            }
        }
               
        let newValues = listItems.map({ $0.title })
        let newIdentifiers = listItems.compactMap({ $0.identifier })
       
        var newLoading:Loading? = nil
        if let currentLoading = self.loading {
            newLoading = currentLoading
            if currentLoading.matchingStringValues != nil {
                /// `[String]`
                newLoading?.matchingStringValues = newMatchingStringValues
            } else {
                /// `[Int]`
                newLoading?.matchingIntegerValues = newMatchingStringValues.compactMap({ Int($0) })
            }
        }
        
        
        var newValue = ListSelectionValue(
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
                uuid: UUID().uuidString
        )
        
        newValue.listItems = listItems
        newValue.underlyingObjects = self.underlyingObjects
        newValue.listItemSelection = self.listItemSelection
        newValue.valueChangeClosure = self.valueChangeClosure
        newValue.writeInConfiguration = self.writeInConfiguration
        //newValue.allowsWriteIn = self.allowsWriteIn
        //newValue.preventValueUpdate = self.preventValueUpdate
        return newValue
            
    }
    
}



extension ListSelectionValue {
    
    
    public func newWith(_ listItems:[ListSelectViewController.ListItem],_ underlyingObjects:[Any]) -> ListSelectionValue  {
        
          var screenedListItems = listItems
          var newSelectedIndicies: [Int] = []
          var newMatchingStringValues:[String] = []
          
          if let existingSelectedValue = self.selectedValue {
              for (i,listItem) in listItems.enumerated() {
                  if listItem.title == existingSelectedValue {
                      newSelectedIndicies.append(i)
                      newMatchingStringValues.append(listItem.identifier ?? "!?")
                      screenedListItems[i].selected = true
                  }
              }
          } else {
              for (i,listItem) in listItems.enumerated() {
                  if listItem.selected {
                      newSelectedIndicies.append(i)
                      newMatchingStringValues.append(listItem.identifier ?? "!?")
                  }
              }
          }
                 
          let newValues = listItems.map({ $0.title })
          let newIdentifiers = listItems.compactMap({ $0.identifier })
         
          var newLoading:Loading? = nil
          if let currentLoading = self.loading {
              newLoading = currentLoading
              if currentLoading.matchingStringValues != nil {
                  /// `[String]`
                  newLoading?.matchingStringValues = newMatchingStringValues
              } else {
                  /// `[Int]`
                  newLoading?.matchingIntegerValues = newMatchingStringValues.compactMap({ Int($0) })
              }
          }
          
          
          var newValue = ListSelectionValue(
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
                  uuid: UUID().uuidString
          )
          
          newValue.listItems = screenedListItems
        newValue.underlyingObjects = underlyingObjects
        newValue.listItemSelection = self.listItemSelection
        newValue.valueChangeClosure = self.valueChangeClosure
        newValue.writeInConfiguration = self.writeInConfiguration
        //newValue.allowsWriteIn = self.allowsWriteIn
        //newValue.preventValueUpdate = self.preventValueUpdate
          return newValue
              
      }
    
}





// MARK: - FormValueDisplayable -
extension ListSelectionValue: FormValueDisplayable {
    
    public typealias Controller = FormController
    public typealias Cell = ListSelectionCell
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor("\(Cell.identifier)_\(idKey)", configureCell, didSelect)
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


public extension ListSelectionValue {
    
    static func DemoSingle() -> ListSelectionValue {
        let list = Array(stride(from: 0, to: 32, by: 1))
        return
            ListSelectionValue(
                title: "Single-Demo",
                values: list.map({ "Item \($0)" }),
                selectedIndex: list.randomElement()!
        )
    }
    
    
    static func DemoMulti() -> ListSelectionValue {
        let random = Array(stride(from: 0, to: 32, by: 1))
        return
            ListSelectionValue(
                title: "Multi-Demo",
                values: random.map({ "Multiple Item: \($0)" }),
                selected: [random.randomElement()!,random.randomElement()!,random.randomElement()!]
        )
    }
    
}



// MARK: ListSelectionCell
final public class ListSelectionCell: UITableViewCell {
    static let identifier = "com.jmade.FormKit.ListSelectionCell"
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

