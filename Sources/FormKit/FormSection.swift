//
//  FormSection.swift
//  
//
//  Created by Justin Madewell on 2/16/20.
//

import Foundation


 
// MARK: - SectionTapDelegate -
public protocol SectionTapDelegate: class  {
    func didSelectHeaderAt(_ section:Int)
}


// MARK: - FormSectionUpdateClosure -
public typealias FormSectionUpdateClosure = (FormSection) -> Void



// MARK: - FormSection -
public class FormSection: Equatable {
    
    public var title:String = ""
    
    public var subtitle:String?
    
    public var rows:[FormItem] = [] {
        didSet {
            if oldValue != rows {
                updateClosure(self)
            } else {
                /*
                print("same rows.. ")
                if oldValue.map({ $0.hashValue }) != rows.map({ $0.hashValue }) {
                    print("diff has vals")
                } else {
                    print("same vals...")
                }
                */
            }
        }
    }
    
    public var updateClosure:FormSectionUpdateClosure = { _ in }
    
    
    public var footer:FooterValue?
    
    public var headerValue:HeaderValue {
        return _headerValue
    }
    
    private var _headerValue = HeaderValue()
    
}


extension FormSection {
    
    public convenience init(header:HeaderValue,_ formValues:[FormValue]) {
        self.init()
        self.rows = formValues.map({ $0.formItem })
        self._headerValue = header
        self.title = header.title
        self.subtitle = header.subtitle
    }
    
}

extension FormSection {
    
    public func toggleState(_ sectionHeight:Double) {
        self._headerValue.toggleMode(sectionHeight)
    }
    
    public func setHeaderValue(_ headerValue:HeaderValue) {
        self._headerValue = headerValue
    }
    
}


extension FormSection {
    
    public convenience init(title:String,formItems:[FormItem]) {
        self.init()
        self.title = title
        self.rows = formItems
        var h = HeaderValue(title: title, section: -1)
        h.subtitle = subtitle
        self._headerValue = h
    }
    
    public convenience init(_ formItems:[FormItem]) {
        self.init()
        self.rows = formItems
    }
    
    public convenience init(_ title:String) {
        self.init()
        self.title = title
        self.rows = []
        var h = HeaderValue(title: title, section: -1)
        h.subtitle = subtitle
        self._headerValue = h
    }
   
    public convenience init(_ title:String,_ subtitle:String? = nil,_ formValues:[FormValue]) {
        self.init()
        self.rows = formValues.map({ $0.formItem })
        self.title = title
        self.subtitle = subtitle
        var h = HeaderValue(title: title, section: -1)
            h.subtitle = subtitle
        self._headerValue = h
    }
    
    
    public convenience init(_ title:String,_ formItems:[FormItem]) {
        self.init()
        self.title = title
        self.rows = formItems
        var h = HeaderValue(title: title, section: -1)
        h.subtitle = subtitle
        self._headerValue = h
    }
    
    
}






// MARK: - FormValue Init -
extension FormSection {
    
    public convenience init(_ title:String,_ formValues:[FormValue]) {
        self.init()
        self.title = title
        self.rows = formValues.map({ $0.formItem })
        self._headerValue = HeaderValue(title: title, section: -1)
    }
    
    public convenience init(_ title:String,_ formValue:FormValue) {
        self.init()
        self.title = title
        self.rows = [formValue.formItem]
        self._headerValue = HeaderValue(title: title, section: -1)
    }
    
    
    public convenience init(_ formValues:[FormValue]) {
        self.init()
        self.rows = formValues.map({ $0.formItem })
    }
    
    public convenience init(_ formValue:FormValue) {
        self.init()
        self.rows = [formValue.formItem]
    }
    
    
    
    
    public convenience init(_ formValues:[FormValue],_ footer:String) {
        self.init()
        self.rows = formValues.map({ $0.formItem })
        self.footer = FooterValue(footer)
    }

    
    
    
    
    /**
     Initializes a new FormSection with the optional subtitle and footer strings.

     - Parameters:
        - title: The title of the section
        - subtitle: The subtitle (this text is renderd in a smaller font and secondary color)
        - formValues: An array of `FormValues`
        - footer: The section footer (this text is capitalized and renderd on the bottom of the ssection in a smaller font and secondary color)

     - Returns: A beautiful, informative,
                well packed Section to be displayed by `FormController`.
     */
    
    public convenience init(_ title:String,_ subtitle:String,_ formValues:[FormValue],_ footer:String) {
        self.init()
        self.rows = formValues.map({ $0.formItem })
        self.title = title
        self.subtitle = subtitle
        var h = HeaderValue(title: title, section: -1)
        h.subtitle = subtitle
        self._headerValue = h
        self.footer = FooterValue(footer)
    }
    
}






extension FormSection {

    
    public func indexPaths(_ section:Int) -> [IndexPath] {
           return rowIndicies().map({ IndexPath(row: $0, section: section) })
       }
    
    
    public var inputRows:[Int] {
        var indicies:[Int] = []
        for (i,v) in rows.enumerated() {
            switch v {
            case .text(_),.note(_) ,.numerical(_),.timeInput(_), .input(_), .datePicker(_):
                indicies.append(i)
            default:
                break
            }
        }
        return indicies
    }
    
    
    public var firstInputRow:Int? {
        return inputRows.first
    }
    
    
    
    public func itemForRowAt(_ row:Int) -> FormItem? {
        guard !rows.isEmpty, (rows.startIndex...rows.index(before: rows.endIndex)).contains(row)
        else { return nil }
        return rows[row]
    }
    
    
    private func rowIndicies() -> [Int] {
        return Array(rows.indices)
    }
    
    
}



// MARK: - Hashable -
extension FormSection: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    
    public var hash: Int {
        "\(rows)".hashValue
    }
    
    public static func == (lhs: FormSection, rhs: FormSection) -> Bool {
        lhs.hash == rhs.hash
    }

}



extension FormSection {
    
   public func newAddingRows(_ newRows:[FormItem]) -> FormSection {
        let new = FormSection(
            self.title,
            [self.rows,newRows].reduce([],+)
        )
        new._headerValue = self._headerValue
        new.updateClosure = self.updateClosure
        new.footer = self.footer
        return new
    }
    
    
    public func newWithRows(_ newRows:[FormItem]) -> FormSection {
        let new =  FormSection(
            self.title,
            newRows
        )
        new._headerValue = self._headerValue
        new.updateClosure = self.updateClosure
        new.footer = self.footer
        return new
    }
    
}



extension FormSection {
    
    public class func Random() -> FormSection {
        
        let randomFormItems:[FormItem] = stride(from: 0, to: Int.random(in: 2...6), by: 1).map({ _ in return FormItem.Random() })
        let randomTitle = [
    "Sunrise","Planning","Additional","Northern","Southern","Dynamic","Properties","Information","Status","Results"
        ].randomElement()!
        return FormSection(randomTitle, randomFormItems)
    }
    
    
    public class func Demo() -> FormSection {
        
        let formValues: [FormValue] = [
            TimeValue.Random(),
            PickerSelectionValue.Demo(),
            StepperValue(title: "Demo Stepper", value: 4),
        ]
        
        return FormSection("Demo Form Section", formValues.map({ $0.formItem }) )
    }
    
    
    public class func OtherDemo() -> FormSection {
            let formValues: [FormValue] = [
                      TimeValue.Random(),
                      PickerSelectionValue.Demo(),
                      SegmentValue.Demo(),
                      StepperValue.Demo(),
                      ButtonValue.DemoBar(),
                      ActionValue.Demo(),
                      ListSelectionValue.DemoSingle(),
                      ListSelectionValue.DemoMulti()
                  ]
           return FormSection("Other", formValues.map({ $0.formItem }))
       }
    
    
    public class func TextDemo() -> FormSection {
           let textFormValues: [FormValue] = [
            TextValue(title: "Text HD", value: "value", .horizontalDiscrete, true),
            TextValue(title: "Text V", value: "value", .vertical, true),
            NoteValue(value: "Note Demo..."),
           ]
           return FormSection("Text", textFormValues.map({ $0.formItem }))
       }
    
    public class func NumericsDemo() -> FormSection {
        let numericFormValues: [FormValue] = [
            NumericalValue.DemoInt(),
            NumericalValue.DemoFloat()
        ]
        return FormSection("Numerics", numericFormValues.map({ $0.formItem }))
    }
    
    public class func TestingSection() -> FormSection {
        FormSection("Testing", [
            TimeInputValue.Demo().formItem,
            ActionValue.Demo().formItem,
            ActionValue.DemoForm().formItem,
        ])
    }
    
}


// MARK: - encodedValues -
extension FormSection {
    
   public var encodedValues:[String:String] {
        return rows.map({ $0.encodedValues }).merged()
    }
    
   public var encodedSection:[String:[String:String]] {
        return [
            title : encodedValues
        ]
    }
    
}



extension FormSection {
    
    public func row(for index: Int) -> FormItem? {
        guard index >= 0, index < rows.endIndex else {
            return nil
        }
        
        return rows[index]
    }
    
    
    
    public func actionValue(for index: Int) -> ActionValue? {
        guard index >= 0, index < rows.endIndex, let formItem = itemForRowAt(index) else {
            return nil
        }
        
        switch formItem {
        case .action(let actionValue):
            return actionValue
        default:
            return nil
        }
        
    }
    
}



public extension FormSection {
    
    var firstRow:FormItem? {
        return row(for: 0)
    }
    
    var secondRow:FormItem? {
        return row(for: 1)
    }
    
    var thirdRow:FormItem? {
        return row(for: 2)
    }
    
    var fourthRow:FormItem? {
        return row(for: 3)
    }
    
    
    
    var lastRow:FormItem? {
        return row(for: rows.count-1)
    }
    
    var secondToLastRow:FormItem? {
        return row(for: rows.count-2)
    }
    
    var thirdToLastRow:FormItem? {
        return row(for: rows.count-3)
    }
    
    
    var isEnabled:Bool {
        return rows.allSatisfy({ $0.isValid() })
    }
    
    
    var hasOnlyActionValues: Bool {
        return rows.allSatisfy({ $0.isActionValue() })
    }
    
    
    
    
    
}
