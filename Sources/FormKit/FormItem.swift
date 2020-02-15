//
//  FormItem.swift
//  FW Device
//
//  Created by Justin Madewell on 12/18/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit

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
        }
    }
    
}



extension FormItem {
    public static func Random() -> FormItem {
        return [
            StepperValue.Random().formItem,
            TextValue.Random().formItem,
            TimeValue.Random().formItem,
            ButtonValue.Random().formItem,
            NoteValue.Random().formItem,
            SegmentValue.Random().formItem,
            NumericalValue.Random().formItem,
            ReadOnlyValue.Random().formItem,
            PickerSelectionValue.Random().formItem,
            ].randomElement()!
    }
}


