//
//  File 2.swift
//  
//
//  Created by Justin Madewell on 6/12/21.
//

import Foundation


// MARK: - Selection List -

public extension FormSection {
    
    // MARK: - ItemSet -
    struct ItemSet {
        public var titles:[String]
        public var subtitles:[String]
        public var selectionIndicies:[Bool]
        public var models:[Any]?
        
        public init(_ titles:[String] = [],_ subtitles:[String] = [],_ selectionIndicies:[Bool] = [],_ models:[Any]? = nil) {
            self.titles = titles
            self.subtitles = subtitles
            self.selectionIndicies = selectionIndicies
            self.models = models
        }
        
        public init(_ titles:[String] = [],_ selectionIndicies:[Bool] = []) {
            self.titles = titles
            self.subtitles = titles.map({ _ in String() })
            self.selectionIndicies = selectionIndicies
            self.models = nil
        }
        
        public init(_ titles:[String] = []) {
            self.titles = titles
            self.subtitles = titles.map({ _ in String() })
            self.selectionIndicies = titles.map({ _ in false })
            self.models = nil
        }
        
        
        public var pushValues:[PushValue] {
            if let m = models {
                return zip(zip(titles, subtitles), zip(selectionIndicies, m)).map({
                    PushValue($0.0.0,
                              $0.1.0,
                              $0.0.1,
                              $0.1.1
                    )
                })
            } else {
               return zip(zip(titles, subtitles), selectionIndicies).map({
                    PushValue($0.0.0,
                              $0.1,
                              $0.0.1,
                              nil
                    )
                })
            }
        }
        
    }
    
    
    static func SelectableList(_ title:String?,_ subTitle:String?,_ footer:String?,_ itemSet:ItemSet) -> FormSection {
        FormSection(
            title ?? "",
            subTitle ?? "",
            itemSet.pushValues,
            footer ?? ""
        )
    }
    
    
    
    enum ActionResult {
        case worked, failed(String)
    }
    
    typealias ActionResultClosure = () -> ActionResult
    
    static func ActionSubmit(_ title:String,resultHandler: @escaping ActionResultClosure) -> FormSection {
        FormSection(ActionValue.Submit(title, { (_, f, _) in
            
            let result = resultHandler()
            switch result {
            case .worked:
                //f.feedback(.success)
                f.close()
            case .failed(let err):
                print("Error: \(err)")
                //f.feedback(.error)
            }
            
        }))
    }
    
    
    
    static func ActionSubmit(_ title:String,_ saveHandler: @escaping () -> Void) -> FormSection {
        FormSection(ActionValue.Submit(title, { (_, f, _) in
            saveHandler()
            f.close()
        }))
    }
    
}




public extension FormDataSource {
    
//    static func SingleSelectionList(_ title:String? = nil,
//                                    _ subTitle:String? = nil,
//                                    _ footer:String? = nil,
//                                    _ actionTitle:String = "Save",
//                                    _ itemSet:FormSection.ItemSet,
//                                    _ closure: @escaping ( ([String:String]) -> Void )) -> FormDataSource {
//
//        let data = FormDataSource(title ?? "", [
//            .SelectableList(title,subTitle,footer,itemSet),
//            .ActionSubmit(actionTitle, resultHandler: {
//
//                if Bool.random() {
//                    print("Worked!")
//                    return .worked
//                } else {
//                    print("Failed!")
//                    return .failed("Bool Error!")
//                }
//
//            }),
//            //.ActionSubmit(actionTitle, saveHandler)
//        ])
//
//        data.updateClosure = { (data) in
//            closure(data.activeParams)
//        }
//
//        return data
//
//    }
    
    
    static func SelectableList(_ formTitle:String,
                               _ title:String,
                               _ subTitle:String? = nil,
                               _ footer:String? = nil,
                               _ actionTitle:String = "Save",
                               _ itemSet:FormSection.ItemSet,
                               _ closure: @escaping ( ([String:String]) -> Void ),
                               _ saveHandler: @escaping () -> Void) -> FormDataSource {
        
        let data = FormDataSource(formTitle, [
            .SelectableList(title,subTitle,footer,itemSet),
            .ActionSubmit(actionTitle, resultHandler: {
                
                if Bool.random() {
                    return .worked
                } else {
                    return .failed("Bool Error!")
                }
                
            }),
            //.ActionSubmit(actionTitle, saveHandler)
        ])
        
        data.updateClosure = { (data) in
            closure(data.activeParams)
        }
        
        return data
    }
    
}
