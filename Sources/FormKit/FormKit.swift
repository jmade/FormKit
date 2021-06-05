


struct FormKit {
    var text = "Hello, World!"
}




import Foundation


fileprivate extension Collection {
    func anySatisfy(_ p: (Element) -> Bool) -> Bool {
        return !self.allSatisfy { !p($0) }
    }
}



// MARK: - FormValidation -
public struct FormValidation { }



// MARK: - SelectionList -
public extension FormValidation {
    
    static var SelectionList: FormValidationClosure = { (data,form) in
        
        let isValid = form.dataSource.activeParams.values.anySatisfy({ $0 == "selected" })
        
        if let section = data.sections.last {
            if !section.isEnabled && isValid {
                let newItems: [FormItem] = [
                    section.actionValue(for: 0)
                    ].compactMap({ $0 })
                    .map({ $0.readyVersion() })
                    .map({ FormItem.action($0) })
                form.changeLastSection(FormSection(newItems))
            } else if section.isEnabled && !isValid {
                let newItems: [FormItem] = [
                    section.actionValue(for: 0),
                    ].compactMap({ $0 })
                    .map({ $0.disabled() })
                    .map({ FormItem.action($0) })
                form.changeLastSection(FormSection(newItems))
            }
        }
        
    }
}



// MARK: - DateRange -
public extension FormValidation {
    
    static var DateRange:FormValidationClosure = { (data,form) in
        
        var invalidKeys:[String] = []

        let datePickerItems = data.allItems.filter({
            $0.item.asDatePickerValue() != nil
        })

        guard let start = datePickerItems.first?.item.asDatePickerValue(), let end = datePickerItems.last?.item.asDatePickerValue() else {
            return
        }
        
        if Calendar.current.compare(start.date, to: end.date, toGranularity: .day) == .orderedDescending {
            invalidKeys = ["start_date"]
        }

      
        var dateItems:[(DatePickerValue,IndexPath)] = []
        data.allItems.forEach {
            if let dpv = $0.item.asDatePickerValue() {
                dateItems.append((dpv,$0.path))
            }
        }

        for item in dateItems {
            if invalidKeys.containsItem(item.0.encodedTitle) {
                if item.0.isValid {
                    form.setNewDatePickerValue(item.0.invalidated(), at: item.1)
                }
            } else {
                if item.0.isInvalid {
                    form.setNewDatePickerValue(item.0.validated(), at: item.1)
                }
            }
        }

        let isValid = invalidKeys.isEmpty

        if let section = data.sections.last {
            if !section.isEnabled && isValid {
                let newItems: [FormItem] = [
                    section.actionValue(for: 0)
                    ].compactMap({ $0 })
                    .map({ $0.readyVersion() })
                    .map({ FormItem.action($0) })
                form.changeLastSection(FormSection(newItems))
            } else if section.isEnabled && !isValid {
                let newItems: [FormItem] = [
                    section.actionValue(for: 0),
                    ].compactMap({ $0 })
                    .map({ $0.disabled() })
                    .map({ FormItem.action($0) })
                form.changeLastSection(FormSection(newItems))
            }
        }
    }
    
}



// MARK: - DateTimeRange -
public extension FormValidation {
    
    static var DateTimeRange:FormValidationClosure = { (data,form) in
           
        var invalidKeys:[String] = []
        
        let datePickerItems = data.allItems.filter({ $0.item.asDatePickerValue() != nil })
        
        let timeValueItems = data.allItems.filter({ $0.item.asTimeInputValue() != nil })
        
        
        guard
            let start = datePickerItems.first?.item.asDatePickerValue(),
            let end = datePickerItems.last?.item.asDatePickerValue(),
            let startTime = timeValueItems.first?.item.asTimeInputValue(),
            let endTime = timeValueItems.last?.item.asTimeInputValue()
            else {
                return
        }
        
        if startTime.isAfter(endTime) {
            invalidKeys.append("start_time")
        }
        
        if Calendar.current.compare(start.date, to: end.date, toGranularity: .day) == .orderedDescending {
            invalidKeys.append("start_date")
        }
        
        var dateItems:[(DatePickerValue,IndexPath)] = []
        var timeItems:[(TimeInputValue,IndexPath)] = []
        data.allItems.forEach {
            
            if let dpv = $0.item.asDatePickerValue() {
                dateItems.append((dpv,$0.path))
            }
            
            if let tiv = $0.item.asTimeInputValue() {
                timeItems.append((tiv,$0.path))
            }
        }
        
        for item in dateItems {
            if invalidKeys.containsItem(item.0.encodedTitle) {
                if item.0.isValid {
                    form.setNewDatePickerValue(item.0.invalidated(), at: item.1)
                }
            } else {
                if item.0.isInvalid {
                    form.setNewDatePickerValue(item.0.validated(), at: item.1)
                }
            }
        }
        
        
        for item in timeItems {
            if invalidKeys.containsItem(item.0.encodedTitle) {
                if item.0.isValid {
                    form.setNewTimeInputValue(item.0.invalidated(), at: item.1)
                }
            } else {
                if item.0.isInvalid {
                    form.setNewTimeInputValue(item.0.validated(), at: item.1)
                }
            }
        }
        
        
        
        
        let isValid = invalidKeys.isEmpty
        
        if let section = data.sections.last {
            if !section.isEnabled && isValid {
                let newItems: [FormItem] = [
                    section.actionValue(for: 0)
                    ].compactMap({ $0 })
                    .map({ $0.readyVersion() })
                    .map({ FormItem.action($0) })
                form.changeLastSection(FormSection(newItems))
            } else if section.isEnabled && !isValid {
                let newItems: [FormItem] = [
                    section.actionValue(for: 0),
                    ].compactMap({ $0 })
                    .map({ $0.disabled() })
                    .map({ FormItem.action($0) })
                form.changeLastSection(FormSection(newItems))
            }
        }
    }
    
}

