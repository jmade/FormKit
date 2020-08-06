//
//  FormSection.swift
//  
//
//  Created by Justin Madewell on 2/16/20.
//

import Foundation


// MARK: - FormSection -

// MARK: - FormSectionUpdateClosure -
public typealias FormSectionUpdateClosure = (FormSection) -> Void

public class FormSection: Equatable {
    
    public var title:String = ""
    
    public var rows:[FormItem] = [] {
        didSet {
            if oldValue != rows {
                updateClosure(self)
            }
        }
    }
    
    public var updateClosure:FormSectionUpdateClosure = { _ in }
}


extension FormSection {
    
    public convenience init(title:String,rows:[FormItem]) {
        self.init()
        self.title = title
        self.rows = rows
    }
    
    public convenience init(_ rows:[FormItem]) {
        self.init()
        self.rows = rows
    }
    
    public convenience init(_ title:String) {
        self.init()
        self.title = title
        self.rows = []
    }
    
    public convenience init(_ title:String,_ rows:[FormItem]) {
        self.init()
        self.title = title
        self.rows = rows
    }
    
    
}




extension FormSection {
    
    public convenience init(_ title:String,_ values:[FormValue]) {
        self.init()
        self.title = title
        self.rows = values.map({ $0.formItem })
    }
    
    public convenience init(_ title:String,_ value:FormValue) {
        self.init()
        self.title = title
        self.rows = [value.formItem]
    }
    
    
    public convenience init(_ values:[FormValue]) {
        self.init()
        self.rows = values.map({ $0.formItem })
    }
    
    public convenience init(_ value:FormValue) {
        self.init()
        self.rows = [value.formItem]
    }
    
  
    
    
    
}



extension FormSection {
    
    
    public convenience init(_ mapValue:MapValue = MapValue(),_ actionValues:[ActionValue]) {
        self.init()
        
        self.rows = [ [mapValue],[actionValues]  ].reduce(+,[])
    }
    
    public convenience init(mapValue:MapValue? = nil) {
        self.init()
        self.rows = [ [MapValue()],[actionValues]  ].reduce(+,[])
    }
    
}





extension FormSection {
    
    public var inputRows:[Int] {
        var indicies:[Int] = []
        for (i,v) in rows.enumerated() {
            switch v {
            case .text(_),.note(_) ,.numerical(_),.timeInput(_):
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
        if rows.count-1 >= row {
            return rows[row]
        } else {
            return nil
        }
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
        FormSection(
            self.title,
            [self.rows,newRows].reduce([],+)
        )
    }
    
    
   public func newWithRows(_ newRows:[FormItem]) -> FormSection {
           FormSection(
               self.title,
               newRows
           )
       }
    
}



extension FormSection {
    
    public class func Random() -> FormSection {
        
        let randomFormItems:[FormItem] = stride(from: 0, to: Int.random(in: 2...6), by: 1).map({ _ in return FormItem.Random() })
        
        //var randomItems = Array( (0...Int.random(in: 2...6)) ).map({ _ in FormItem.Random() })
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
