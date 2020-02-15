import Foundation


// MARK: - FormSection -

// MARK: - FormSectionUpdateClosure -
public typealias FormSectionUpdateClosure = ( (FormSection) -> Void )

public class FormSection: Equatable {
    
    var title:String = " "
    
    var rows:[FormItem] = [] {
        didSet {
            if oldValue != rows {
                updateClosure(self)
            }
        }
    }
    
    var updateClosure:FormSectionUpdateClosure = { _ in }
}


extension FormSection {
    
    public convenience init(title:String,rows:[FormItem]) {
        self.init()
        self.title = title
        self.rows = rows
    }
    
    public convenience init(_ rows:[FormItem]) {
        self.init()
        self.title = " "
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
    
    
    public convenience init(_ values:[FormValue]) {
        self.init()
        self.title = " "
        self.rows = values.map({ $0.formItem })
    }
    
    public convenience init(_ value:FormValue) {
        self.init()
        self.title = " "
        self.rows = [value.formItem]
    }
    
    
    
}



extension FormSection {
    
    var inputRows:[Int] {
        var indicies:[Int] = []
        for (i,v) in rows.enumerated() {
            switch v {
            case .text(_),.note(_) ,.numerical(_):
                indicies.append(i)
            default:
                break
            }
        }
        return indicies
    }
    
    
    func itemForRowAt(_ row:Int) -> FormItem? {
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
        return  "\(rows)".hashValue
    }
    
    public static func == (lhs: FormSection, rhs: FormSection) -> Bool {
        return lhs.hash == rhs.hash
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
            ActionValue.DemoAdd().formItem,
            ActionValue.DemoExp().formItem
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








// MARK: - FormDataSource -


// MARK: - FormDataSourceUpdateClosure -
public typealias FormDataSourceUpdateClosure = ( (FormDataSource) -> Void )


/// TODO: Consider turning this into a struct? and make the function a mutating one? would it change automattically?


public class FormDataSource {
    
    var title:String = ""
    
    var sections:[FormSection] = [] {
        didSet {
            if oldValue != sections {
                updateClosure(self)
            }
        }
    }
    
    var updateClosure: FormDataSourceUpdateClosure = { _ in }
    
}


extension FormDataSource {
    
    func generateFormController() -> FormController {
        FormController(formData: self)
    }
    
    func formController() -> FormController {
        FormController(formData: self)
    }
    
    func controller() -> FormController {
        FormController(formData: self)
    }
   
}


extension FormDataSource {
    
    public convenience init(sections:[FormSection]) {
        self.init()
        self.sections = sections
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
    }
    
    public convenience init(_ sections:[FormSection] = []) {
        self.init()
        self.sections = sections
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
    }
    
    
    public convenience init(title: String, sections:[FormSection]) {
        self.init()
        self.title = title
        self.sections = sections
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
    }
    
    /// updateClosure
    public convenience init(title: String, sections:[FormSection],_ updateClosure: @escaping FormDataSourceUpdateClosure) {
        self.init()
        self.title = title
        self.sections = sections
        self.updateClosure = updateClosure
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
    }
    
    
}


extension FormDataSource {
    
    /// Trickle down the update closure, when aytime a section changes
    private func sectionWasUpdated(section: FormSection) {
        updateClosure(self)
    }
    
}


extension FormDataSource {
    
   public func newWithSection(_ section:FormSection, at sectionIndex:Int) -> FormDataSource {
        
        var newSections: [FormSection] = []
        
        if sectionIndex > 0 {
            Array(0...(sectionIndex-1)).forEach({
                newSections.append(sections[$0])
            })
        }
        
        newSections.append(section)
        
        if (sections.count-1) > sectionIndex {
            Array(sectionIndex+1...sections.count-1).forEach({
                newSections.append(sections[$0])
            })
        }
        
        return FormDataSource(title: self.title, sections: newSections)
    }
    
}


// MARK: - EncodedValueArray -
extension FormDataSource {
    
    public typealias EncodedValueArray = [(key:String,value:String)]
    
    public func encodedValues() -> EncodedValueArray {
        
        let items = sections.map({ $0.rows }).reduce([],+)
        
        let qualifiedItems = items.filter { (formItem) -> Bool in
            switch formItem {
            case .readOnly(_), .action(_), .button(_):
                return false
            default:
                return true
            }
        }
        
        return qualifiedItems.map { $0.encodedValues }.map { (encodedValue) -> (key:String,value:String) in
            return (key:encodedValue.keys.first ?? "?" ,value: encodedValue.values.first ?? "?" )
        }
    }
    
    
    public func encodedValuesForKeys(_ keys: [String]) -> [String:String] {
        let foundValues = encodedValues().filter({ keys.contains($0.key) })
        var params:[String:String] = [:]
        for item in foundValues {
            params.updateValue(item.value, forKey: item.key)
        }
        return params
    }
    
    
    
}


extension FormDataSource {
    
    // MARK: - EncodedFormDataSource -
    public typealias EncodedFormDataSource = [String:[[String:[String:String]]]]
    
    private func makeEncodedFormDataSource() -> EncodedFormDataSource {
        return [
            "Form" : sections.map({ $0.encodedSection })
        ]
    }
    
    
    public func encoded() -> EncodedFormDataSource {
        return makeEncodedFormDataSource()
    }
    
    public func log() {
        let encoded = makeEncodedFormDataSource()
        var report = "\n"
        report += "\"Form\" : {\n"
        encoded["Form"]?.forEach({
            let sectionTitle = $0.keys.first ?? "-"
            report += "  "
            report += "\"\(sectionTitle)\" : {\n"
            for (_,v) in $0.enumerated() {
                v.value.forEach( {
                    report += "  "
                    report += "  "
                    report += "\"\($0.key)\" : \"\($0.value)\",\n"
                })
                report = String(report.dropLast())
                report = String(report.dropLast())
                report += "\n"
                report += "  },\n"
            }
        })
        
        report = String(report.dropLast())
        report = String(report.dropLast())
        report += "\n}\n"
        
        print(report)
    }
    
    
    
    
    var isEmpty:Bool {
        return sections.isEmpty
    }
    
    func rowsForSection(_ section:Int) -> [FormItem] {
        if sections.count-1 >= section {
            return sections[section].rows
        } else {
            return []
        }
    }
    
    func updateFirstSection(_ section:FormSection) {
        let existingSections = self.sections.dropFirst()
        self.sections = [[section],existingSections].reduce([],+)
    }
    
    
    func updateWith(formValue:FormValue,at path:IndexPath) {
        sections[path.section].rows[path.row] = formValue.formItem
    }
    
    
    func itemAt(_ path:IndexPath) -> FormItem? {
        if sections.count-1 >= path.section {
            return sections[path.section].itemForRowAt(path.row)
        } else {
            return nil
        }
    }
    
}


extension FormDataSource {
    
    var inputIndexPaths:[IndexPath] {
        var values:[IndexPath] = []
        Array(0..<sections.count).forEach({
            let sectionIndex = $0
            sections[$0].inputRows.forEach({
                values.append(IndexPath(row: $0, section: sectionIndex))
            })
        })
        return values
    }
    
    var firstInputIndexPath: IndexPath? {
        return inputIndexPaths.first
    }
    
    func nextIndexPath(_ from: IndexPath) -> IndexPath? {
        if let currentIndex = inputIndexPaths.indexOf(from) {
            let nextIndex = currentIndex + 1
            if nextIndex > inputIndexPaths.count - 1 {
                return inputIndexPaths.first
            } else {
                return inputIndexPaths[nextIndex]
            }
        } else {
            return nil
        }
    }
    
    func previousIndexPath(_ from: IndexPath) -> IndexPath? {
        if let currentIndex = inputIndexPaths.indexOf(from) {
            var nextIndex = currentIndex - 1
            if nextIndex < 0 {
                nextIndex = inputIndexPaths.count - 1
            }
            return inputIndexPaths[nextIndex]
        } else {
            return nil
        }
    }
    
}


extension FormDataSource {
    
    public class func Random() -> FormDataSource {
          return FormDataSource(
              sections: Array(0...Int.random(in: 0...5)).map({ _ in FormSection.Random()})
          )
      }
    
    static func Demo() -> FormDataSource {
        return FormDataSource(sections: [
            .OtherDemo(),
            .NumericsDemo(),
            .TextDemo(),
            .TestingSection()
        ])
    }
}




