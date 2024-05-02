//
//  FormItem.swift
//
//  Created by Justin Madewell on 12/18/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit

/// TODO: make something like a `FormItemDescriptor` that is a Codable object that can be used to initialize a `FormItem` which can be used to be stored and sent as JSON objects.


// MARK: - FormItem -
public enum FormItem {
    case stepper(StepperValue)
    case text(TextValue)
    case time(TimeValue)
    case button(ButtonValue)
    case note(NoteValue)
    case segment(SegmentValue)
    case numerical(NumericalValue)
    case readOnly(ReadOnlyValue)
    case picker(PickerValue)
    case pickerSelection(PickerSelectionValue)
    case action(ActionValue)
    case listSelection(ListSelectionValue)
    case timeInput(TimeInputValue)
    case switchValue(SwitchValue)
    case slider(SliderValue)
    case map(MapValue)
    case mapAction(MapActionValue)
    case custom(CustomValue)
    case input(InputValue)
    case date(DateValue)
    case datePicker(DatePickerValue)
    case push(PushValue)
    case dateTime(DateTimeValue)
    case token(TokenValue)
    case color(ColorValue)
    case web(WebViewValue)
}

extension FormItem {
    
    static var empty:FormItem {
        .readOnly(ReadOnlyValue(centeredValue: ""))
    }
}




extension FormItem: DiffAware {
    
    public var diffId: Int {
        return hash
    }
    
    public static func compareContent(_ a: FormItem, _ b: FormItem) -> Bool {        a.encodedValues == b.encodedValues
    }
}



// MARK: - CellDescriptable -
extension FormItem: FormCellDescriptable {
    /// extend the value type with a `CellDescriptor` var to add support for initialization of each cell type
    public var cellDescriptor: FormCellDescriptor {
        switch self {
        case .stepper(let stepper):
            return stepper.cellDescriptor
        case .text(let text):
            return text.cellDescriptor
        case .time(let time):
            return time.cellDescriptor
        case .button(let button):
            return button.cellDescriptor
        case .note(let note):
            return note.cellDescriptor
        case .segment(let segment):
            return segment.cellDescriptor
        case .numerical(let numerical):
            return numerical.cellDescriptor
        case .readOnly(let readOnly):
            return readOnly.cellDescriptor
        case .picker(let picker):
            return picker.cellDescriptor
        case .pickerSelection(let pickerSelection):
            return pickerSelection.cellDescriptor
        case .action(let action):
            return action.cellDescriptor
        case .listSelection(let list):
            return list.cellDescriptor
        case .timeInput(let time):
            return time.cellDescriptor
        case .switchValue(let switchValue):
            return switchValue.cellDescriptor
        case .slider(let sliderValue):
            return sliderValue.cellDescriptor
        case .map(let mapValue):
            return mapValue.cellDescriptor
        case .mapAction(let mapActionValue):
            return mapActionValue.cellDescriptor
        case .custom(let customValue):
            return customValue.cellDescriptor
        case .input(let inputValue):
            return inputValue.cellDescriptor
        case .date(let dateValue):
            return dateValue.cellDescriptor
        case .datePicker(let datePicker):
            return datePicker.cellDescriptor
        case .push(let pushValue):
            return pushValue.cellDescriptor
        case .dateTime(let dateTimeValue):
            return dateTimeValue.cellDescriptor
        case .token(let tokenValue):
            return tokenValue.cellDescriptor
        case .color(let colorValue):
            return colorValue.cellDescriptor
        case .web(let webValue):
            return webValue.cellDescriptor
        }
    }
}


extension FormItem: Hashable, Equatable {
    
    public static func == (lhs: FormItem, rhs: FormItem) -> Bool {
        return lhs.hash == rhs.hash
    }
    
    public var hash: Int {
        switch self {
        case .stepper(let stepper):
            return stepper.hashValue
        case .text(let text):
            return text.hashValue
        case .time(let time):
            return time.hashValue
        case .button(let button):
            return button.hashValue
        case .note(let note):
            return note.hashValue
        case .segment(let segment):
            return segment.hashValue
        case .numerical(let numerical):
            return numerical.hashValue
        case .readOnly(let readOnly):
            return readOnly.hashValue
        case .picker(let picker):
            return picker.hashValue
        case .pickerSelection(let pickerSelection):
            return pickerSelection.hashValue
        case .action(let action):
            return action.hashValue
        case .listSelection(let list):
            return list.hashValue
        case .timeInput(let time):
            return time.hashValue
        case .switchValue(let switchValue):
            return switchValue.hashValue
        case .slider(let sliderValue):
            return sliderValue.hashValue
        case .map(let mapValue):
            return mapValue.hashValue
        case .mapAction(let mapActionValue):
            return mapActionValue.hashValue
        case .custom(let custom):
            return custom.hashValue
        case .input(let input):
            return input.hashValue
        case .date(let date):
            return date.hashValue
        case .datePicker(let datePicker):
            return datePicker.hashValue
        case .push(let pushValue):
            return pushValue.hashValue
        case .dateTime(let dateTimeValue):
            return dateTimeValue.hashValue
        case .token(let tokenValue):
            return tokenValue.hashValue
        case .color(let colorValue):
            return colorValue.hashValue
        case .web(let webValue):
            return webValue.hashValue
        }
    }
    
}



extension FormItem {
    
    public var encodedKey:String? {
        return encodedValues.keys.first
    }
    
    public var encodedValues:[String:String] {
        switch self {
        case .stepper(let stepper):
            return stepper.encodedValue()
        case .text(let text):
            return text.encodedValue()
        case .time(let time):
            return time.encodedValue()
        case .button(let button):
            return button.encodedValue()
        case .note(let note):
            return note.encodedValue()
        case .segment(let segment):
            return segment.encodedValue()
        case .numerical(let numerical):
            return numerical.encodedValue()
        case .readOnly(let readOnly):
            return readOnly.encodedValue()
        case .picker(let picker):
            return picker.encodedValue()
        case .pickerSelection(let pickerSelection):
            return pickerSelection.encodedValue()
        case .action(let action):
            return action.encodedValue()
        case .listSelection(let list):
            return list.encodedValue()
        case .timeInput(let time):
            return time.encodedValue()
        case .switchValue(let switchValue):
            return switchValue.encodedValue()
        case .slider(let sliderValue):
            return sliderValue.encodedValue()
        case .map(let mapValue):
            return mapValue.encodedValue()
        case .mapAction(let mapActionValue):
            return mapActionValue.encodedValue()
        case .custom(let custom):
            return custom.encodedValue()
        case .input(let input):
            return input.encodedValue()
        case .date(let date):
            return date.encodedValue()
        case .datePicker(let datePicker):
            return datePicker.encodedValue()
        case .push(let pushValue):
            return pushValue.encodedValue()
        case .dateTime(let dateTimeValue):
            return dateTimeValue.encodedValue()
        case .token(let tokenValue):
            return tokenValue.encodedValue()
        case .color(let colorValue):
            return colorValue.encodedValue()
        case .web(let webValue):
            return webValue.encodedValue()
        }
    }
    
}



extension FormItem {
    
    public var copyValue:String {
        displayValues.first?.value ?? ""
    }
    
    public var displayValues:[String:String] {
        switch self {
        case .stepper(let stepper):
            return [stepper.title : stepper.encodedValue().values.first!]
        case .text(let text):
            return [text.title : text.encodedValue().values.first!]
        case .time(let time):
            return [time.title : time.encodedValue().values.first!]
        case .button(let button):
            return [button.title : button.encodedValue().values.first!]
        case .note(let note):
            return [ (note.customKey ?? note.title) ?? "Note": note.encodedValue().values.first!]
        case .segment(let segment):
            return [segment.customKey ?? "Segment" : segment.encodedValue().values.first!]
        case .numerical(let numerical):
            return [numerical.title : numerical.encodedValue().values.first!]
        case .readOnly(let readOnly):
            return [readOnly.title : readOnly.encodedValue().values.first!]
        case .picker(let picker):
            return [picker.customKey ?? "Picker" : picker.encodedValue().values.first!]
        case .pickerSelection(let pickerSelection):
            return [pickerSelection.title : pickerSelection.encodedValue().values.first!]
        case .action(let action):
            return [action.title : action.encodedValue().values.first!]
        case .listSelection(let list):
            return [list.title : list.encodedValue().values.first!]
        case .timeInput(let time):
            return [time.title : time.encodedValue().values.first!]
        case .switchValue(let switchValue):
            return [switchValue.title : switchValue.encodedValue().values.first!]
        case .slider(let sliderValue):
            return [sliderValue.title : sliderValue.encodedValue().values.first!]
        case .map(let mapValue):
            return [mapValue.customKey ?? "Map" : mapValue.encodedValue().values.first!]
        case .mapAction(let mapActionValue):
            return [mapActionValue.customKey ?? "Map" : mapActionValue.encodedValue().values.first!]
        case .custom(let custom):
            return [custom.identifier.uuidString : custom.encodedValue().values.first!]
        case .input(let input):
            return [input.title : input.encodedValue().values.first!]
        case .date(let date):
            return [(date.title ?? date.customKey) ?? "Date" : date.encodedValue().values.first!]
        case .datePicker(let datePicker):
            return [(datePicker.title ?? datePicker.customKey) ?? "Date" : datePicker.encodedValue().values.first!]
        case .push(let pushValue):
            return [pushValue.primary ?? "Push" : pushValue.encodedValue().values.first!]
        case .dateTime(let dateTimeValue):
            return [dateTimeValue.title : dateTimeValue.encodedValue().values.first!]
        case .token(let tokenValue):
            return [tokenValue.title : tokenValue.encodedValue().values.first!]
        case .color(let colorValue):
            return [colorValue.title : colorValue.encodedValue().values.first!]
        case .web(let webValue):
            return ["WebValue" : webValue.encodedValue().values.first! ]
        }
            
        
    }
    
}





extension FormItem {
    
    public static func Random() -> FormItem {
        
        let randomValues: [FormValue] = [
            StepperValue.Random(),
            TextValue.Random(),
            TimeInputValue.Random(),
            NoteValue.Random(),
            SegmentValue.Random(),
            NumericalValue.Random(),
            ReadOnlyValue.Random(),
            PickerSelectionValue.Random(),
            SwitchValue.Random(),
            SliderValue.Random(),
            ListSelectionValue.DemoSingle(),
            InputValue.Random(),
            DateValue.Random(),
            DatePickerValue.Random()
        ]
        
        return randomValues
            .map({ $0.formItem })
            .randomElement()!
    }
    
}



extension FormItem {
    
    
    public func isActionValue(_ actionValue:ActionValue? = nil) -> Bool {
        var isActionValue:Bool = false
        switch self {
        case .action(let av):
            if let inquiring = actionValue {
                isActionValue = inquiring.dataMatches(av)
            } else {
                isActionValue = true
            }
            break
        default:
            break
        }
        return isActionValue
    }
    
    
    public func isDatePickerValue(_ datePickerValue:DatePickerValue? = nil) -> Bool {
        var isDatePickerValue:Bool = false
        switch self {
        case .datePicker(let dpv):
            if let inquiring = datePickerValue {
                isDatePickerValue = inquiring.dataMatches(dpv)
            } else {
                isDatePickerValue = true
            }
            break
        default:
            break
        }
        return isDatePickerValue
    }
    
    
    public func asDatePickerValue() -> DatePickerValue? {
        switch self {
        case .datePicker(let dpv):
            return dpv
        default:
            break
        }
        return nil
    }
    
    
    public func asDateTimeValue() -> DateTimeValue? {
        switch self {
        case .dateTime(let dtv):
            return dtv
        default:
            break
        }
        return nil
    }
    
    
    public func asActionValue() -> ActionValue? {
        switch self {
        case .action(let action):
            return action
        default:
            break
        }
        return nil
    }

    
    public func asPushValue() -> PushValue? {
        switch self {
        case .push(let push):
            return push
        default:
            break
        }
        return nil
    }
    
    
    public func asSliderValue() -> SliderValue? {
        switch self {
        case .slider(let slider):
            return slider
        default:
            break
        }
        return nil
    }
    
    
    public func asCustomValue() -> CustomValue? {
        switch self {
        case .custom(let custom):
            return custom
        default:
            break
        }
        return nil
    }
    
    
    public func isValid() -> Bool {
        switch self {
        case .action(let action):
            if action.isValid() == false {
                return false
            } else {
                return true
            }
        case .datePicker(let dpv):
            return dpv.isValid
        case .timeInput(let tiv):
            return tiv.isValid
        case .dateTime(let dtv):
            return dtv.isValid
        default:
           return false
        }
    }
    
}


extension FormItem: Validatable {
    
    var validators: [Validator] {
        switch self {
        case .stepper(let stepper):
            return stepper.validators
        case .text(let text):
            return text.validators
        case .time(let time):
            return time.validators
        case .button(let button):
            return button.validators
        case .note(let note):
            return note.validators
        case .segment(let segment):
            return segment.validators
        case .numerical(let numerical):
            return numerical.validators
        case .readOnly(let readOnly):
            return readOnly.validators
        case .picker(let picker):
            return picker.validators
        case .pickerSelection(let pickerSelection):
            return pickerSelection.validators
        case .action(let action):
            return action.validators
        case .listSelection(let list):
            return list.validators
        case .timeInput(let time):
            return time.validators
        case .switchValue(let switchValue):
            return switchValue.validators
        case .slider(let sliderValue):
            return sliderValue.validators
        case .map(let mapValue):
            return mapValue.validators
        case .mapAction(let mapActionValue):
            return mapActionValue.validators
        case .custom(let custom):
            return custom.validators
        case .input(let input):
            return input.validators
        case .date(let date):
            return date.validators
        case .datePicker(let datePicker):
            return datePicker.validators
        case .push(let pushValue):
            return pushValue.validators
        case .dateTime(let dateTimeValue):
            return dateTimeValue.validators
        case .token(let tokenValue):
            return tokenValue.validators
        case .color(let colorValue):
            return colorValue.validators
        case .web(let webValue):
            return webValue.validators
        }
    }
}


//


// MARK: - SectionChange -
struct SectionChange {
    enum Operation {
        case adding,deleting,reloading
    }
    let operation:Operation
    let section: Int
    var changes:[Change<FormItem>]?
    var indexSet:IndexSet?
}


