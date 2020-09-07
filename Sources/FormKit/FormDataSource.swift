import Foundation

// MARK: - FormDataSource -


// MARK: - FormDataSourceUpdateClosure -
public typealias FormDataSourceUpdateClosure = ( (FormDataSource) -> Void )


public protocol FormDataSourceUpdateDelegate: class {
    func dataSourceWasUpdated(_ dataSource:FormDataSource)
}


public class FormDataSource {
    
    public weak var delegate:FormDataSourceUpdateDelegate?
    
    public var title:String = ""
    
    public var sections:[FormSection] = [] {
        didSet {
            update()
        }
    }
    
    
    private func update() {
        let copy = self
        if let delegate = delegate {
            delegate.dataSourceWasUpdated(copy)
        }
        updateClosure?(copy)
    }
    
    public var updateClosure: FormDataSourceUpdateClosure? = nil
    
}


extension FormDataSource {
    
    public func generateFormController() -> FormController {
        FormController(formData: self)
    }
    
    public func formController() -> FormController {
        FormController(formData: self)
    }
    
    public func controller() -> FormController {
        FormController(formData: self)
    }
   
}


extension FormDataSource {
    
    public convenience init(sections:[FormSection]) {
        self.init()
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
        self.sections = sections
        
    }
    
    
    
    public convenience init(section:FormSection) {
           self.init()
            
        let newSections = [section]
           
           newSections.forEach( {
               $0.updateClosure = { [weak self] (section) in
                   self?.sectionWasUpdated(section: section)
               }
           })
           
           self.sections = newSections
           
       }
    
    
    public convenience init(title: String?,_ section:FormSection) {
        self.init()
         
     let newSections = [section]
        
        newSections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
        self.sections = newSections
        
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
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
        self.sections = sections
        
    }
    
    /// updateClosure
    public convenience init(title: String, sections:[FormSection],_ updateClosure: @escaping FormDataSourceUpdateClosure) {
        self.init()
        self.title = title
        self.updateClosure = updateClosure
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
        self.sections = sections
        
    }
    
    
}


extension FormDataSource {
    
    /// Trickle down the update closure, when a section changes
    private func sectionWasUpdated(section: FormSection) {
        update()
    }
    
}


extension FormDataSource {
    
    public func newWithSection(_ section:FormSection, at sectionIndex:Int) -> FormDataSource {
        
        let newSection = section
        newSection.updateClosure = {  [weak self] (section) in
            self?.sectionWasUpdated(section: section)
        }
        
        sections[sectionIndex] = newSection
        
        let copy = self
        return copy
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
    
    
    public func valueForKey(_ key:String) -> String? {
        if let value = encodedValuesForKeys([key])[key] {
            return value
        }
        return nil
    }
    
    
    
    
  
}





extension FormDataSource {
    
    
    public var params:[String:String] {
        var value:[ [String:String] ] = []
        
        for section in sections {
            for row in section.rows {
                value.append(row.encodedValues)
            }
        }
        
        return value.merged()
    }
    
    
    public func logParams() {
        var report = "\n"
        report += "-------------\n"
        report += "Form: \(title)\n"
        report += "-------------\n"
        
        for (i,section) in sections.enumerated() {
            //report += "-------------"
            report += "-- Section [\(i)]: \(section.title) --\n"
            
            for (i,row) in section.rows.enumerated() {
                report += "  [\(i)] \(row.encodedValues)\n"
            }
        }
     
        report += "-------------\n"
        print(report)

    }
    
    
    
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
    
    
    
    
    public var isEmpty:Bool {
        return sections.isEmpty
    }
    

    public func rowsForSection(_ section:Int) -> [FormItem] {
        if sections.count-1 >= section {
            return sections[section].rows
        } else {
            return []
        }
    }
    
    
    public func updateFirstSection(_ section:FormSection) {
        let existingSections = self.sections.dropFirst()
        self.sections = [[section],existingSections].reduce([],+)
    }
    
   
    
    public func updateWith(formValue:FormValue,at path:IndexPath) {
        let qualifiedSections = path.section >= 0 && path.section <= sections.count - 1
        if qualifiedSections {
            let rowCount = sections[path.section].rows.count
            if path.row >= 0 && path.row <= rowCount - 1 {
                sections[path.section].rows[path.row] = formValue.formItem
            } else {
                print("[FormKit Error]: (Row Error) Unable to update FormValue at IndexPath: \(path)")
            }
        } else {
             print("[FormKit Error]: (Section Error) Unable to update FormValue at IndexPath: \(path)")
        }
       
        
    }
    
    
    public func itemAt(_ path:IndexPath) -> FormItem? {
        if sections.count-1 >= path.section {
            return sections[path.section].itemForRowAt(path.row)
        } else {
            return nil
        }
    }
    
    
    public func sectionTitle(at section:Int) -> String? {
        if sections.count-1 >= section {
            return sections[section].title
        } else {
            return nil
        }
    }
    
}


extension FormDataSource {
    
    public var inputIndexPaths:[IndexPath] {
        var values:[IndexPath] = []
        Array(0..<sections.count).forEach({
            let sectionIndex = $0
            sections[$0].inputRows.forEach({
                values.append(IndexPath(row: $0, section: sectionIndex))
            })
        })
        return values
    }
    
    public var firstInputIndexPath: IndexPath? {
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
            var previousIndex = currentIndex - 1
            
            if previousIndex < 0 {
                previousIndex = inputIndexPaths.count - 1
            }
            
            
            if previousIndex > (inputIndexPaths.count - 1) {
                previousIndex = 0
                return inputIndexPaths[0]
            } else {
                return inputIndexPaths[previousIndex]
            }
            
            
        } else {
            return nil
        }
    }
    
}


extension FormDataSource {
    
    public class func Random() -> FormDataSource {
          return FormDataSource(
              sections: Array(0...Int.random(in: 1...5)).map({ _ in FormSection.Random()})
          )
      }
    
    public static func Demo() -> FormDataSource {
        return FormDataSource(sections: [
            .TextDemo(),
            .TextDemo(),
            .OtherDemo(),
            .NumericsDemo(),
            .TextDemo(),
            .TestingSection(),
            .init([
                .switchValue(.init(title: "Switch Mode")),
                .slider(.Random()),
                .timeInput(.Random()),
                .text(.init(title: "Input:")),
                .action(ActionValue(title: "Random Form", formClosure: { (_, ctl, _) in
                    ctl.navigationController?.pushViewController(
                        FormDataSource.Random().controller(),
                        animated: true
                    )
                }))
            ])
        ])
    }
}



extension FormDataSource {
    
    public func section(for index: Int) -> FormSection? {
        guard index >= 0, index < sections.endIndex else {
            return nil
        }
        
        return sections[index]
    }
    
    
    public func item(for row:Int,in sectionIndex:Int) -> FormItem? {
        return self.section(for: sectionIndex)?.row(for: row)
    }
    
    
    public func first<T>() -> T? {
        for section in sections {
            for item in section.rows {
                if item.matches(type: T.self) {
                    return item as? T
                }
            }
        }
        
        return nil
    }
    
    
    
    
    
}


extension FormDataSource {
    
   public struct Evaluation {
        struct Sets {
            let insert: IndexSet
            let delete: IndexSet
            let reload: IndexSet
        }
        let sets:Sets
        let reloads: [SectionChange]
    }
    
}



extension FormDataSource {

    
    public class func evaluate(_ old:FormDataSource, new:FormDataSource) -> Evaluation {

        var sectionChanges:[SectionChange] = []
        
        for i in 0..<max(old.sections.count, new.sections.count) {
            let isOldSectionEmpty = old.rowsForSection(i).isEmpty
            let isNewSectionEmpty = new.rowsForSection(i).isEmpty
            let changingSection = (isOldSectionEmpty == false) && (isNewSectionEmpty == false)
            let addingSection = (isOldSectionEmpty == true) && (isNewSectionEmpty == false)
            let removingSection = (isOldSectionEmpty == false) && (isNewSectionEmpty == true)
            if changingSection {
                let changes = diff(old: old.rowsForSection(i), new: new.rowsForSection(i))
                sectionChanges.append(SectionChange(operation: .reloading, section: i, changes: changes, indexSet: nil))
            }
            if addingSection {
                sectionChanges.append(SectionChange(operation: .adding, section: i, changes: nil, indexSet: IndexSet(arrayLiteral: i)))
            }
            if removingSection {
                sectionChanges.append(SectionChange(operation: .deleting, section: i, changes: nil, indexSet: IndexSet(arrayLiteral: i)))
            }
        }
        
        let inserts = sectionChanges.filter({ $0.operation == .adding }).map({$0.section})
        let deletes = sectionChanges.filter({ $0.operation == .deleting }).map({$0.section})
        
        var sectionReloads:[Int] = []
        var actualInserts:[Int] = []
        for i in inserts {
            if Array(0..<old.sections.count).contains(i) {
                sectionReloads.append(i)
            } else {
                actualInserts.append(i)
            }
        }
        
        return Evaluation(
            sets:  Evaluation.Sets(
                insert: IndexSet(actualInserts),
                delete: IndexSet(deletes),
                reload: IndexSet(sectionReloads)
            ),
            reloads: sectionChanges
        )
        
        
    }
    
}





