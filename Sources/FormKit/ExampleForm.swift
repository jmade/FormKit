//
//  File.swift
//  
//
//  Created by Justin Madewell on 6/7/23.
//

import UIKit


let ExampleData = [
    ("Item 1",5004321),
    ("Item 2",5004322),
    ("Item 3",5004323),
    ("Item 4",5004324),
    ("Item 5",5004325),
    ("Item 6",5004326),
    ("Item 7",5004327),
    ("Item 8",5004328),
    ("Item 9",5004329),
]

extension Array where Element == ListItem {
    
    static var exampleItems:[ListItem] {
        ExampleData.map({
            ListItem($0.0, "\($0.1)", false)
        })
    }
    
}



public enum ExampleForm {
    
}

// DataSource
public extension ExampleForm {
    
    enum dataSources {
        
        static var example:FormDataSource {
            FormDataSource(title: "Example", sections: [
                ExampleForm.sections.listSelection,
            ]) { ds in
                ds.log()
            }
        }
        
    }
    
}

// Sections
public extension ExampleForm {
    
    enum sections {
        
        static var listSelection:FormSection {
            FormSection(title: "ListSelection", subtitle: "a Selectable List with Search ", footer: nil, formItems: [
                ExampleForm.formValues.mulitpleSelection.formItem,
            ])
        }
    }
    
}


// FormValues
public extension ExampleForm {
    
    enum formValues {
        
        static var mulitpleSelection: ListSelectionValue {
            ListSelectionValue("Multiple Selection","multiple_selection", .exampleItems, .multiple)
        }
        
    }
}






public extension FormDataSource {
    
    static var exampleDataSource:FormDataSource {
        FormDataSource(title: "Example", sections: [
            .exampleListSelection
        ]) { ds in
            ds.log()
        }
    }
    
}



// MARK: - ListSelectionValue -
public extension FormSection {
    
    static var exampleListSelection:FormSection {
        FormSection(title: "ListSelection", subtitle: "a Selectable List with Search ", footer: nil, formItems: [
            ListSelectionValue.mulitpleSelectionExample.formItem,
        ])
    }
    
}


public extension ListSelectionValue {
    
    static var mulitpleSelectionExample: ListSelectionValue {
        ListSelectionValue("Multiple Selection","multiple_selection", .exampleItems, .multiple)
    }
    
}
