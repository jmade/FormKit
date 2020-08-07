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
        }
    }
    
}



extension FormItem {
    
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
        }
    }
    
}



extension FormItem {
    
    public static func Random() -> FormItem {
        
        let randomValues: [FormValue] = [
            StepperValue.Random(),
            TextValue.Random(),
            TimeValue.Random(),
            ButtonValue.Random(),
            NoteValue.Random(),
            SegmentValue.Random(),
            NumericalValue.Random(),
            ReadOnlyValue.Random(),
            PickerSelectionValue.Random(),
            SwitchValue.Random(),
            SliderValue.Random(),
        ]
        
        return randomValues
            .map({ $0.formItem })
            .randomElement()!
    }
    
}



extension FormItem {
    
    public func matches<T>(type:T) -> Bool {
        switch self {
        case .stepper(_):
            return type is StepperValue
        case .text(_):
            return type is TextValue
        case .time(_):
            return type is TimeValue
        case .button(_):
            return type is ButtonValue
        case .note(_):
            return type is NoteValue
        case .segment(_):
            return type is SegmentValue
        case .numerical(_):
            return type is NumericalValue
        case .readOnly(_):
            return type is ReadOnlyValue
        case .picker(_):
            return type is PickerValue
        case .pickerSelection(_):
            return type is PickerSelectionValue
        case .action(_):
            return type is ActionValue
        case .listSelection(_):
            return type is ListSelectionValue
        case .timeInput(_):
            return type is TimeInputValue
        case .switchValue(_):
            return type is SwitchValue
        case .slider(_):
            return type is SliderValue
        case .map(_):
            return type is MapValue
        case .mapAction(_):
            return type is MapActionValue
        }
    }
    
}


