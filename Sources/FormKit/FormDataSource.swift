import Foundation

// MARK: - FormDataSource -


// MARK: - FormDataSourceUpdateClosure -
public typealias FormDataSourceUpdateClosure = ( (FormDataSource) -> Void )

public protocol FormDataSourceUpdateDelegate: AnyObject {
    func dataSourceWasUpdated(_ dataSource:FormDataSource)
}


public class FormDataSource {
    
    public var storage:[String:Any] = [:]
    
    public var itemStore:[String:FormItem] = [:]
    
    public var additionalParameters:[String:String] = [:]
    
    public var yOffset:Double = 0.0
    
    public var lastPath: (row:Int,section:Int) = (-1,-1)
    public var lastRect: (x:Double,y:Double,w:Double,h:Double) = (0.0,0.0,0.0,0.0)
    
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
    
    public func setNeedsUpdate() {
        self.update()
    }
    
    public var updateClosure: FormDataSourceUpdateClosure?
    
}




// MARK: - FormController -
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
    
    
    
    public convenience init(_ title: String,_ sections:[FormSection]) {
        self.init()
        self.title = title
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
        self.sections = sections
        
    }
    
    
}


extension FormDataSource {
    
    public func headerValues() -> [HeaderValue] {
        var headers:[HeaderValue] = []
        for (i,section) in sections.enumerated() {
            var existingHeader = section.headerValue
            existingHeader.updateSection(i,section.title)
            headers.append(existingHeader)
        }
        return headers
    }
    
    public func footerValues() -> [FooterValue] {
        var footers:[FooterValue] = []
        for (i,section) in sections.enumerated() {
            if let existingFooter = section.footer {
                var f = existingFooter
                f.section = i
                footers.append(f)
            }
        }
        return footers
    }
    
}


extension FormDataSource {
    
    public func newWith(_ sections: [FormSection]) -> FormDataSource {
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
        let new = FormDataSource(title: self.title, sections: sections)
        new.updateClosure = self.updateClosure
        new.additionalParameters = self.additionalParameters
        new.storage = self.storage
        return new
    }
    
    public func newWith(title:String,sections: [FormSection]) -> FormDataSource {
        
        sections.forEach( {
            $0.updateClosure = { [weak self] (section) in
                self?.sectionWasUpdated(section: section)
            }
        })
        
        let new = FormDataSource(title: title, sections: sections)
        new.updateClosure = self.updateClosure
        new.additionalParameters = self.additionalParameters
        new.storage = self.storage
        return new
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
    
    public var displayParams:[String:String] {
        var value:[ [String:String] ] = []
        
        for section in sections {
            for row in section.rows {
                for entry in row.displayValues {
                    if !entry.value.isEmpty {
                        value.append(["\(entry.key)":"\(entry.value)"])
                    }
                }
            }
        }
        
        var data:[String:String] = [:]
        
        for v in value {
            if let key = v.first?.key {
                data[key] = v.first!.value
            }
        }
        
        return data
        
        //return value.merged()
    }
    
    
    public var params:[String:String] {
        var value:[ [String:String] ] = []
        
        for section in sections {
            for row in section.rows {
                value.append(row.encodedValues)
            }
        }
        
        return value.merged()
    }
    
    
    public var activeParams:[String:String] {
        var value:[ [String:String] ] = []
        
        for param in params {
            if !param.value.isEmpty && (param.value != "-1") && !param.key.isEmpty && (param.value != "-- Please Select --") {
                value.append([param.key:param.value])
            }
        }
        
        
        for param in additionalParameters {
            if !param.value.isEmpty && (param.value != "-1") && !param.key.isEmpty && (param.value != "-- Please Select --") {
                value.append([param.key:param.value])
            }
        }
        
        return value.merged()
    }
    
    
    public func containsItemWithKey(_ key:String) -> Bool {
        
        var found = false
        
        for section in sections {
            for row in section.rows {
                if let rowKey = row.encodedKey {
                    //print("[FormKit] checking key: '\(rowKey)' matches: '\(key)'? \(rowKey == key)")
                    if rowKey == key {
                        found = true
                    }
                }
            }
        }
        //print("[FormKit] Found? \(found)")
        return found
    }
    
    
    public var activeSet: Set<String> {
        Set(Array(activeParams.keys))
    }
    
    
    
    public var dataDescription:String {
        let line = "-------------\n"
        
        var report = "\n"
        report += line
        report += "Form: \(title)\n"
        report += line
        
        for (i,section) in sections.enumerated() {
            //report += "-------------"
            report += "-- Section (\(i)) \(section.title) --\n"
            
            for (i,row) in section.rows.enumerated() {
                report += "  [\(i)] \(row.encodedValues)\n"
            }
        }
     
        report += line
        
        return report
    }
    
    
    private var additionalParamsDescriptor: String {
        
        var report = ""
        
        report += "-------------\n"
        report += "-- Additional Parameters --\n"
        
        var idx = 0
        for (k,v) in additionalParameters {
            report += "  [\(idx)] [\"\(k)\" : \"\(v)\"]\n"
            idx += 1
        }
        report += "-------------\n"
        
        return report
        
    }
    
    
    public func logParams(_ section:Int? = nil) {
        if let sec = section {
            var report = "\n"
            report += "-------------\n"
            report += "Form: \(title)\n"
            report += "-------------\n"
            
            for (i,section) in sections.enumerated() {
                if sec == i {
                    report += "...\n"
                    report += "-- Section [\(i)]: \(section.title) --\n"
                    
                    for (i,row) in section.rows.enumerated() {
                        report += "  [\(i)] \(row.encodedValues)\n"
                    }
                    report += "...\n"
                }
            }
         
            report += "-------------\n"
            print(report)
            print(additionalParamsDescriptor)
        } else {
            print(dataDescription)
            print(additionalParamsDescriptor)
        }

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

    
    public var isValid:Bool {
        sections.allSatisfy({ $0.isValid })
    }
    
    
    public struct InvalidItem: Equatable {
        var formItem:FormItem
        var indexPath:IndexPath
        var messages:[String]
        
        public static func == (lhs: InvalidItem, rhs: InvalidItem) -> Bool {
            lhs.indexPath == rhs.indexPath && lhs.messages == rhs.messages
        }

    }
    
    public var invalidItems:[InvalidItem] {
        var items:[InvalidItem] = []
        for (sectionIdx,section) in sections.enumerated() {
            for (rowIdx,row) in section.rows.enumerated() {
                if row.invalid {
                    items.append(
                        InvalidItem(
                            formItem: row,
                            indexPath: IndexPath(row: rowIdx, section: sectionIdx),
                            messages: row.errorMessages
                        )
                    )
                }
            }
        }
        return items
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
    
    
    public func itemsForSection(_ section:Int) -> [FormItem] {
        if sections.count-1 >= section {
            return sections[section].rows
        } else {
            return []
        }
    }
    
    
    public func itemsForSectionAt(_ path:IndexPath) -> [FormItem] {
        let section = path.section
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
                self.logParams()
                print("\n")
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
    
    
    
    public func containsStoredObjectForKey(_ key:String) -> Bool {
        ( storage.index(forKey: key) != nil )
    }
    
    
    
    public func getListSelectionValueForKey(_ key:String) -> (ListSelectionValue,IndexPath)? {
        for (sectionIndex,section) in sections.enumerated() {
            for (rowIndex,row) in section.rows.enumerated() {
                if let encodedKey = row.encodedKey {
                    if encodedKey == key {
                        switch row {
                        case .listSelection(let ls):
                            return (ls,IndexPath(row: rowIndex, section: sectionIndex))
                        default:
                            break
                        }
                    }
                }
            }
        }
        return nil
    }
    
   
    
}


extension FormDataSource {
    
    public func getInputIndexPaths() -> [IndexPath] {
        var values:[IndexPath] = []
               for (section,formSection) in sections.enumerated() {
                   if formSection.headerValue.state == .expanded {
                       for row in formSection.inputRows {
                           values.append(
                               IndexPath(row: row, section: section)
                           )
                       }
                   }
                   
               }
        return values
    }
    
    
    public var inputIndexPaths:[IndexPath] {
       return getInputIndexPaths()
    }
    
    
    public var firstInputIndexPath: IndexPath? {
        return inputIndexPaths.first
    }
    
    
    func nextIndexPath(_ from: IndexPath) -> IndexPath? {
        if let currentIndex = getInputIndexFor(from) {
            let nextIndex = currentIndex+1
            if nextIndex > (inputIndexPaths.count-1) {
                return inputIndexPaths.first
            } else {
                return inputIndexPaths[nextIndex]
            }
        } else {
            print("Error finding Index \(from)")
            return nil
        }
    }
    
    
    func previousIndexPath(_ from: IndexPath) -> IndexPath? {
        if let currentIndex = getInputIndexFor(from) {
            let previousIndex = (currentIndex-1)
            if previousIndex < 0 {
                return inputIndexPaths.last
            } else {
                return inputIndexPaths[previousIndex]
            }
        } else {
            print("Error finding Index \(from)")
            return nil
        }
    }
    
    
    private func getInputIndexFor(_ path:IndexPath) -> Int? {
        for (i,inputPath) in inputIndexPaths.enumerated() {
            if inputPath == path {
                return i
            }
        }
        return nil
    }
    
    
}


extension FormDataSource {
    
    public func pathForActionValue(_ actionValue:ActionValue) -> IndexPath? {
        
        for (sectionIndex,section) in sections.enumerated() {
            for (row,item) in section.rows.enumerated() {
                if item.isActionValue(actionValue) {
                    return IndexPath(row: row, section: sectionIndex)
                }
            }
        }
        
        return nil
        
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
    
    public var lastSection:FormSection? {
        return sections.last
    }
    
    public var lastSectionIdx:Int {
        return sections.count-1
    }
    
    public func section(for index: Int) -> FormSection? {
        guard index >= 0, index < sections.endIndex else {
            return nil
        }
        
        return sections[index]
    }
    
    
    public func section(for path: IndexPath) -> FormSection? {
        let index = path.section
        guard index >= 0, index < sections.endIndex else {
            return nil
        }
        
        return sections[index]
    }
    
    public func sectionTitle(at: Int) -> String? {
        if let sec = section(for: at) {
            return sec.title
        }
        return nil
    }
    
    
    var sectionHeaders:[String] {
        return sections.map({ $0.title })
    }
    
    
    public func item(for row:Int,in sectionIndex:Int) -> FormItem? {
        return self.section(for: sectionIndex)?.row(for: row)
    }
    
    
    public func item(for key:String) -> FormItem? {
        for section in sections {
            for row in section.rows {
                if let rowKey = row.encodedKey {
                    if rowKey == key {
                        return row
                    }
                }
            }
        }
        return nil
    }
    
    
    
    
    public var allItems:[(item:FormItem,path:IndexPath)] {
        var all:[(item:FormItem,path:IndexPath)] = []
        
        for (section,s) in sections.enumerated() {
            for (row,item) in s.rows.enumerated() {
                all.append(
                    (item,IndexPath(row: row, section: section))
                )
            }
        }
        
        return all
        
    }
    
}


extension FormDataSource {
    
   public struct Evaluation {
        struct Sets {
            var insert: IndexSet?
            var delete: IndexSet?
            var reload: IndexSet?
        }
        let sets:Sets
        let reloads: [SectionChange]
    }
    
}


extension FormDataSource.Evaluation {
    
    var isReloadsOnly:Bool {
        sets.insert == nil && sets.delete == nil && sets.reload != nil
    }
    
}



extension FormDataSource {

    
    public class func evaluate(_ old:FormDataSource, new:FormDataSource) -> Evaluation {

        var sectionChanges:[SectionChange] = []
        
        var reloads:[Int] = []
        var deletes:[Int] = []
        var inserts:[Int] = []
        
        print("\n>>Evaluation")
        
        for i in 0..<max(old.sections.count, new.sections.count) {
            
            print("--\nSection: \(i)")
            
            let isOldSectionEmpty = old.rowsForSection(i).isEmpty
            let isNewSectionEmpty = new.rowsForSection(i).isEmpty
            
            print("OldEmpty? \(isOldSectionEmpty) | NewEmpty? \(isNewSectionEmpty)")
            
            
            let changingSection = (isOldSectionEmpty == false) && (isNewSectionEmpty == false)
            let addingSection = (isOldSectionEmpty == true) && (isNewSectionEmpty == false)
            let removingSection = (isOldSectionEmpty == false) && (isNewSectionEmpty == true)
            
            print("Changing? \(changingSection)")
            print("Adding? \(addingSection)")
            print("Removing? \(removingSection)")
            
            
            var sectionChange: SectionChange? = nil
            let indexSet = IndexSet(arrayLiteral: i)
        
            if changingSection {
                let changes = diff(old: old.rowsForSection(i), new: new.rowsForSection(i))
                //sectionChanges.append(SectionChange(operation: .reloading, section: i, changes: changes, indexSet: nil))
                sectionChange = SectionChange(operation: .reloading, section: i, changes: changes, indexSet: indexSet)
                
                //sectionChanges.append(SectionChange(operation: .reloading, section: i, changes: changes, indexSet: IndexSet(arrayLiteral: i)))
                print("Changing Section: \(i)")
                reloads.append(i)
            }
            
            if addingSection {
                sectionChange = SectionChange(operation: .adding, section: i, changes: nil, indexSet: indexSet)
                //sectionChanges.append(SectionChange(operation: .adding, section: i, changes: nil, indexSet: IndexSet(arrayLiteral: i)))
                print("Adding Section: \(i)")
                inserts.append(i)
            }
            
            
            if removingSection {
                sectionChange = SectionChange(operation: .deleting, section: i, changes: nil, indexSet: indexSet)
                //sectionChanges.append(SectionChange(operation: .deleting, section: i, changes: nil, indexSet: IndexSet(arrayLiteral: i)))
                print("Removing Section: \(i)")
                deletes.append(i)
            }
            
            
            if let change = sectionChange {
                sectionChanges.append(
                    change
                )
            }
            
            //IndexSet(arrayLiteral: i))
            
            
        }
        print("--")
        
        let sectionInserts = sectionChanges.filter({ $0.operation == .adding }).map({$0.section})
        //let sectionDeletes = sectionChanges.filter({ $0.operation == .deleting }).map({$0.section})
        
        var sectionReloads:[Int] = []
        var actualInserts:[Int] = []
        for i in sectionInserts {
            if Array(0..<old.sections.count).contains(i) {
                sectionReloads.append(i)
            } else {
                actualInserts.append(i)
            }
        }
        
        print("Inserts: \(inserts)")
        print("Deletes: \(deletes)")
        print("Reloads: \(reloads)")
        
        print("<<Evaluation\n")
        
        return Evaluation(
            sets:  Evaluation.Sets(
                insert: inserts.isEmpty ? nil : IndexSet(inserts),
                delete: deletes.isEmpty ? nil : IndexSet(deletes),
                reload: reloads.isEmpty ? nil : IndexSet(reloads)
            ),
            reloads: sectionChanges.filter({ $0.operation == .reloading })
        )
        
        
    }
    
}


extension FormDataSource {
    
    public func indexPathForKey(_ customKey:String?) -> IndexPath? {
        for (sectionIndex,section) in sections.enumerated() {
            for (rowIndex,formItem) in section.rows.enumerated() {
                if formItem.encodedKey == customKey {
                    return IndexPath(row: rowIndex,
                                     section: sectionIndex
                    )
                }
            }
        }
        return nil
    }
    
}





