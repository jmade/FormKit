//
//  File.swift
//  
//
//  Created by Justin Madewell on 12/1/22.
//

import Foundation


public protocol FormControllerConfigurable {
    
    /// title of the FormController
    var title:String? {get set}
    
    var showsCancelButton:Bool {get set}
    
    var showsDoneButton:Bool {get set}
    
    var loadingMessage:String? {get set}
    
    var loadingClosure: FormController.FormDataLoadingClosure? {get set}
    
    var dismissalClosure:FormControllerDismissalClosure? {get set}
    
    /// Called each input of the FormController
    var validationClosure: FormValidationClosure? {get set}
    
    /// Called when the `FormDataSource` is changed.
    var updateClosure: FormDataSourceUpdateClosure? {get set}
}



public struct FormControllerConfiguration {
    
    public var showsCancelButton: Bool = false
    
    public var showsDoneButton: Bool = false
    
    public var title: String?
    
    public var dismissalClosure: FormControllerDismissalClosure?
    
    public var validationClosure: FormValidationClosure?
    
    public var loadingMessage: String?
    
    public var loadingClosure: FormController.FormDataLoadingClosure?
    
    public var updateClosure: FormDataSourceUpdateClosure?
}

public extension FormControllerConfiguration {
    
    init(_ showsDoneButton:Bool,_ loadingClosure: FormController.FormDataLoadingClosure?) {
        self.showsDoneButton = showsDoneButton
        self.loadingClosure = loadingClosure
    }
    
    init(_ showsCancelButton:Bool,_ loadingMessage:String,loadingClosure: @escaping FormController.FormDataLoadingClosure) {
        self.showsCancelButton = showsCancelButton
        self.loadingClosure = loadingClosure
        self.loadingMessage = loadingMessage
    }
    
}


//public extension FormControllerConfiguration {
//
//    init(showsCancelButton: Bool = false, showsDoneButton: Bool = false, title: String? = nil, dismissalClosure: FormControllerDismissalClosure? = nil, validationClosure: FormValidationClosure? = nil, loadingMessage: String? = nil, loadingClosure: FormController.FormDataLoadingClosure? = nil, updateClosure: FormDataSourceUpdateClosure? = nil) {
//        self.showsCancelButton = showsCancelButton
//        self.showsDoneButton = showsDoneButton
//        self.title = title
//        self.dismissalClosure = dismissalClosure
//        self.validationClosure = validationClosure
//        self.loadingMessage = loadingMessage
//        self.loadingClosure = loadingClosure
//        self.updateClosure = updateClosure
//    }
//
//}



extension FormControllerConfiguration: FormControllerConfigurable {
    
}





