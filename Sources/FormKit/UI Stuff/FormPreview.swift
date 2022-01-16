//
//  File.swift
//  
//
//  Created by Justin Madewell on 1/14/22.
//

import UIKit
import QuickLook



public class FKPreview: NSObject, QLPreviewItem {
    let displayName: String
    let url:URL
   
    init(_ displayName: String,_ url:URL) {
        self.displayName = displayName
        self.url = url
        super.init()
    }
    
    init(_ url:URL) {
        self.displayName = String()
        self.url = url
        super.init()
    }
    

    public var previewItemTitle: String? {
        return displayName
    }

    public var previewItemURL: URL? {
        return url
    }
}


//extension FormController: QLPreviewControllerDataSource {
//
//    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//        1
//    }
//
//    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//        guard let preview = previewItem else {
//            return FKPreview("Error",.init(stringLiteral: ""))
//        }
//        return preview
//    }
//
//    public func showPreview(_ url:URL,_ title:String? = nil) {
//
//    }
//}
