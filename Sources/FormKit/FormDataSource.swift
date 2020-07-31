import Foundation

// MARK: - FormDataSource -


// MARK: - FormDataSourceUpdateClosure -
public typealias FormDataSourceUpdateClosure = ( (FormDataSource) -> Void )


/// TODO: Consider turning this into a struct? and make the function a mutating one? would it change automattically?

public class FormDataSource {
    
    public var title:String = ""
    
    public var sections:[FormSection] = [] {
        didSet {
            if oldValue != sections {
                updateClosure(self)
            }
        }
    }
    
    public var updateClosure: FormDataSourceUpdateClosure = { _ in }
    
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
    
    
    public func valueForKey(_ key:String) -> String? {
        if let value = encodedValuesForKeys([key])[key] {
            return value
        }
        return nil
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
        sections[path.section].rows[path.row] = formValue.formItem
    }
    
    
    public func itemAt(_ path:IndexPath) -> FormItem? {
        if sections.count-1 >= path.section {
            return sections[path.section].itemForRowAt(path.row)
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
    
    public static func Demo() -> FormDataSource {
        return FormDataSource(sections: [
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




