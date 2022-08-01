
import UIKit

// MARK: - FormTransport -
public struct FormTransport: Codable {
    
    public struct Form: Codable {
        
        public var title:String?
        
        public struct Section: Codable {
            
            public var title:String?
            public var subtitle:String?
            public var footer:String?
            public var collapsed:Bool?
            
            public struct Value: Codable {
                
                public enum FormValueType: String, Codable {
                    case push
                    case text
                    case display
                    case int
                    case double
                    case float
                    case list
                    case submit
                }
                
                public struct Properties: Codable {
                    /// Shared
                    var customKey: String?
                    
                    /// `Numerical Value`
                    var intValue: Int?
                    var floatValue: Double?
                    var doubleValue: Double?
                    
                    /// `TextValue`
                    var title: String?
                    var value: String?
                    var placeholder: String?
                    
                    /// `PushValue`
                    var primary: String?
                    var secondary: String?
                    var selected: Bool?
                    var pushing: String?
                    
                    /// `ListSelect`
                    var selectionMode: String?
                    
                    public struct ListItemProperties: Codable {
                        var primary: String?
                        var secondary: String?
                        var identifier: String?
                        var selected: Bool?
                    }
                    
                    var items:[ListItemProperties]?
                    
                    /// `ActionValue` for submiting the form
                    var endpoint:String?
                    var requiredKeys:[String]?
                }
                
                var type:FormValueType?
                var data:Properties
            }
            
            public var formValues:[Value]?
        }
        
        public var sections:[Section]
    }
    
    public var form: Form
    
}


extension FormTransport.Form.Section.Value.Properties.ListItemProperties {
    
    var listItem:ListItem {
        var item = ListItem(title: primary ?? "",
                            selected: selected ?? false,
                            valueIdentifier: identifier
        )
        item.detail = secondary
        return item
    }
    
}



fileprivate typealias ResponseHandler<T> = (T) -> Void
fileprivate typealias JSON = [String:Any]

fileprivate enum NetworkError: Error {
    case badURL
    case badData
    case badParse
    case message(String)
}

fileprivate func downloadJSON(_ urlString:String,completionHandler: @escaping ( Result<JSON,NetworkError> ) -> Void) {
    DispatchQueue.global().async(execute: {
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    if let json = json {
                        DispatchQueue.main.async(execute: {
                            completionHandler(
                                .success(json)
                            )
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            completionHandler(
                                .failure(
                                    .badParse
                                )
                            )
                        })
                    }
                } catch let error {
                    DispatchQueue.main.async(execute: {
                        completionHandler(
                            .failure(
                                .message("\(error)")
                            )
                        )
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    completionHandler(
                        .failure(
                            .badData
                        )
                    )
                })
            }
        } else {
            DispatchQueue.main.async(execute: {
                completionHandler(
                    .failure(
                        .badURL
                    )
                )
            })
        }
    })
}



extension FormTransport.Form.Section.Value {
    
    public var formItem:FormItem {
        switch type {
        case .push:
            if let viewControllerName = data.pushing {
                return .push(
                    PushValue(data.primary, data.secondary, nil) { _, form, path in
                        if let viewControllerType = NSClassFromString(viewControllerName) as? UIViewController.Type {
                            form.navigationController?.pushViewController(
                                viewControllerType.init(),
                                animated: true
                            )
                        }
                    }
                )
            } else {
                if let selected = data.selected {
                    return .push(
                        PushValue(data.primary ?? "", selected, data.secondary ?? "", nil)
                    )
                } else {
                    return .push(
                        PushValue(data.primary, data.secondary, nil) { _, _, _ in
                            
                        }
                    )
                }
            }
        case .text:
            var tv = TextValue(data.title ?? "", data.customKey)
            if let value = data.value {
                tv.value = value
            }
            tv.placeholder = data.placeholder
            return .text(tv)
        case .display:
            return .readOnly(
                ReadOnlyValue(centeredValue: data.title ?? "")
            )
        case .int:
            var nv = NumericalValue.int(data.title ?? "", data.customKey ?? "" , "")
            if let val = data.value {
                if let intVal = Int(val) {
                    nv = nv.newWith("\(intVal)")
                }
            }
            if let val = data.intValue {
                nv = nv.newWith("\(val)")
            }
            return .numerical(nv)
        case .double, .float:
            var nv = NumericalValue(floatTitle: data.title ?? "")
            nv.customKey = data.customKey
            if let val = data.value {
                if let doubleVal = Double(val) {
                    nv = nv.newWith("\(doubleVal)")
                }
            }
            if let val = data.doubleValue {
                nv = nv.newWith("\(val)")
            }
            if let val = data.floatValue {
                nv = nv.newWith("\(val)")
            }
            return .numerical(nv)
        case .list:
            guard let items = data.items else {
                return .empty
            }
            
            var selType: ListSelectionValue.SelectionType = .single
            if let selectionMode = data.selectionMode {
                if selectionMode == "multi" {
                    selType = .multiple
                }
            }
            return .listSelection(
                ListSelectionValue(data.title ?? "",
                                          data.customKey,
                                          items.map({ $0.listItem }),
                                          selType)
            )
        case .submit:
            return .action(
                ActionValue(title: data.title ?? "Submit",
                            color: .success,
                            formClosure: { av, form, path in
                                form.updateActionValue(av.operatingVersion(), at: path)
                                     
                                
                                //
                                
                            })
            )
        default:
            return .empty
        }
    }
    
}



extension FormTransport.Form.Section {
    
    var isSubmit:Bool {
        formValues?.first?.isSubmit ?? false
    }
    
}

extension FormTransport.Form.Section.Value {
    
    var isSubmit:Bool {
        type == .submit
    }
    
}


extension FormTransport {
    
    private func submitItem(data: Form.Section.Value.Properties,completionHandler: @escaping ([String:Any]) -> Void) -> FormItem {
        return .action(
            submitActionValue(data: data, completionHandler: completionHandler)
        )
    }
    
    
    
    private func convertParams(_ params:[String:String]) -> String {
        var p = params
        p["mobileid"] = UIDevice.current.identifierForVendor!.uuidString
        p["os"] = "iOS"
        return "?"+p.map {"\($0)=\($1.replacingOccurrences(of: "+", with: "%2B"))"}.joined(separator: "&")
    }
    
    
    private func buildURLWith(_ endpoint:String?,_ params:[String:String]) -> String? {
        if let endpoint = endpoint {
            return "\(endpoint)\(convertParams(params))"
        }
        return nil
    }
    
    
    private func submitActionValue(data: Form.Section.Value.Properties,completionHandler: @escaping ([String:Any]) -> Void) -> ActionValue {
        ActionValue(title: data.title ?? "Submit",
                    color: .success,
                    formClosure: { av, form, path in
            if let urlString = buildURLWith(data.endpoint, form.params()) {
                print("URL:\n\(urlString)")
                form.updateActionValue(av.operatingVersion(), at: path)
                downloadJSON(urlString) { [weak form] in
                    form?.updateActionValue(av.readyVersion(), at: path)
                    switch $0 {
                    case .success(let json):
                        completionHandler(json)
                    case .failure(let error):
                        completionHandler(["message":"Network Error: \(error)"])
                    }
                }
            }
        })
    }
    
    private func submitSection(data: Form.Section.Value.Properties,completionHandler: @escaping ([String:Any]) -> Void) -> FormSection {
        FormSection(
            submitActionValue(data: data, completionHandler: completionHandler)
        )
    }
    
    
    private func sections(completionHandler: @escaping ([String:Any]) -> Void) -> [FormSection] {
        if form.sections.count > 1 {
            if form.sections.last!.isSubmit {
                var topSections = form.sections
                let submitSection = topSections.popLast()
                var submitSections = topSections.map({ $0.formSection })
                if let data = submitSection?.formValues?.first?.data {
                    submitSections.append(
                        self.submitSection(data: data, completionHandler: completionHandler)
                    )
                }
                return submitSections
            } else {
                return form.sections.map({ $0.formSection })
            }
        } else {
            return form.sections.map({ $0.formSection })
        }
    }
    
    
    private func formDataSource(completionHandler: @escaping ([String:Any]) -> Void) -> FormDataSource {
        FormDataSource(
             form.title ?? "",
             sections(completionHandler: completionHandler)
         )
    }
    
    private var validationKeys:Set<String> {
        Set(
            self.form.sections.last?.formValues?.first?.data.requiredKeys ?? []
        )
    }
    
    
    public var validationClosure: FormValidationClosure {
        { (data,form) in
            
            let isValid = validationKeys.isSubset(of: data.activeSet)
            
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
    
}



extension FormTransport.Form.Section {
    
    public var formItems:[FormItem] {
        formValues?.map({ $0.formItem }) ?? []
    }
    
    public var formSection:FormSection {
        FormSection(title: title,
                    subtitle: subtitle,
                    footer: footer,
                    formItems: formItems
        )
    }
    
}


extension FormTransport {
    
    public func formController(completionHandler: @escaping ([String:Any]) -> Void) -> FormController {
        let form = FormController(self.form.title ?? "", formDataSource(completionHandler: completionHandler) )
        form.validationClosure = validationClosure
        return form
    }
    
}








