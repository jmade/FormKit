import UIKit
import WebKit

// MARK: - WebViewValue -
public struct WebViewValue {
    
    var identifier: UUID = UUID()
    public var customKey:String? = "WebViewValue"
    
    public var validators: [Validator] = []
    
    public var userContentControllerName = "WEB"
    
    public var content:String?
    
    public var scripts:[String] = []
    
}


// init

public extension WebViewValue {
    
    init(_ htmlContent:String) {
        self.content = htmlContent
    }
    
}


// MARK: - FormValue -
extension WebViewValue: FormValue {

    public var formItem: FormItem {
        .web(self)
    }
    
    public func encodedValue() -> [String : String] {
        [(customKey ?? "WebViewValue") : ""]
    }
}


//: MARK: - FormValueDisplayable -
extension WebViewValue: FormValueDisplayable {
    
    public typealias Cell = WebViewValueCell
    public typealias Controller = FormController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.ReuseID, configureCell, didSelect)
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.tableView = formController.tableView
        cell.updateFormValueDelegate = formController
    }
    
}





extension WebViewValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: WebViewValue, rhs: WebViewValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}













class FKWebView: WKWebView {

  init(frame: CGRect) {
    let configuration = WKWebViewConfiguration()
    super.init(frame: frame, configuration: configuration)
    self.navigationDelegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    return self.scrollView.contentSize
  }

}


extension FKWebView: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//    webView.evaluateJavaScript("document.readyState", completionHandler: { (_, _) in
//      webView.invalidateIntrinsicContentSize()
//    })
      
      checkWebView(webView)
      
  }
    
    
    private func checkWebView(_ webView: WKWebView) {
        if webView.isLoading == false {
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (result, error) in
                if let height = result as? CGFloat {
                    webView.frame.size.height += height
                }
            })
        }
    }
    

}











//: MARK: WebViewValueCell

public final class WebViewValueCell: UITableViewCell {
    
    static let ReuseID = "com.jmade.FormKit.WebViewValueCell.identifier"
    
    private let metaText = "<meta name='viewport' content='width=device-width, shrink-to-fit=YES'>"
    private let fullMetaText = "<meta name='viewport' content='width=device-width, shrink-to-fit=YES' initial-scale='0.75' maximum-scale='0.75' minimum-scale='0.5' user-scalable='no'>"
    
    var formValue : WebViewValue? {
        didSet {
            guard let webViewValue = formValue else { return }
            webView.configuration.userContentController.removeAllUserScripts()
            webView.configuration.userContentController.add(self, name: webViewValue.userContentControllerName)
            
            if let html = webViewValue.content {
                let htmlString = "\(fullMetaText)\(html)"
                webView.loadHTMLString(htmlString, baseURL: nil)
            }
        }
    }
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    
    
    var indexPath:IndexPath?
    var tableView: UITableView?
    
    private var lastHeight: CGFloat = 0
    
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    private var webViewHeightContraint: NSLayoutConstraint!
    private var contentViewHeightContraint: NSLayoutConstraint!
    

    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(webView)
        
        webViewHeightContraint = webView.heightAnchor.constraint(equalToConstant: 44)
        webViewHeightContraint.isActive = true
        
        contentView.leadingAnchor.constraint(equalTo: webView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: webView.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: webView.bottomAnchor).isActive = true
        
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
        webView.isOpaque = false
        
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
    }
    
    
    private func animatedLayout(toHeight:CGFloat) {
        
        if lastHeight != toHeight {
            UIView.setAnimationsEnabled(false)
            self.tableView?.beginUpdates()
            webViewHeightContraint.constant = toHeight
            self.tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            lastHeight = toHeight
        }
    }
    
}


extension WebViewValueCell: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      checkWebView(webView)
      
  }
    
    
    private func checkWebView(_ webView: WKWebView) {
        if webView.isLoading == false {
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] (result, error) in
                if let height = result as? CGFloat {
                    self?.animatedLayout(toHeight: height)
                }
            })
        }
    }
    

}






extension WebViewValueCell: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle JS Messages Here
        
        if #available(iOS 14.0, *) {
            print("""
            [WebController] (didReceiveMessage): '\(message.name)' From: \(message.frameInfo.request.url?.lastPathComponent ?? "-")
            """)
        }
        
//        if let json = message.body as? [String:Any] {
//            DispatchQueue.main.async(execute: { [weak self] in
//                guard let self = self else { return }
//                self.handleWebMessage(json)
//            })
//        }
        
    }
}




