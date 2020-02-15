import UIKit

//: MARK: - ItemsLoadingView -
public class ItemsLoadingView : UIView {
    
    let loadingLabel = UILabel()
    
    /*
    lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "LOADING"
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    */
    
    lazy var progress: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            indicator.style = .large
        } else {
            indicator.style = .gray
        }
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    required public init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        
//        loadingLabel.textColor = .gray
//        loadingLabel.text = "LOADING"
//        loadingLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(progress)
        addSubview(loadingLabel)
        
        if #available(iOS 9.0, *) {
            progress.topAnchor.constraint(equalTo: topAnchor, constant: 8.0).isActive = true
        }
        progress.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        loadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        loadingLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        loadingLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        loadingLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        
        /*
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: progress, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: progress, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 30),
            NSLayoutConstraint(item: loadingLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: loadingLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 75), // 52
            ])
        */
    }
    
    convenience init(message:String, textStyle:UIFont.TextStyle, color:UIColor) {
        self.init(frame: .zero)
        
        defer {
            loadingLabel.font = UIFont.preferredFont(forTextStyle: textStyle)
            loadingLabel.textColor = color
            print("Setting Label text: \(message)")
            loadingLabel.text = message
        }
       
        
    }
    
    override public func willRemoveSubview(_ subview: UIView) {
        if subview == progress { progress.stopAnimating() }
        super.willRemoveSubview(subview)
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        progress.startAnimating()
    }
    
    
    public func styleLoadingLabel(font: UIFont, color:UIColor) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.loadingLabel.font = font
            self?.loadingLabel.textColor = color
        })
    }

    public func setLoadingMessage(_ loadingMessage:String) {
        print("[Loading View] setting Loading Message")
        DispatchQueue.main.async(execute: { [weak self] in
            self?.loadingLabel.text = loadingMessage
        })
    }
    
    
    public func displayMessage(_ message:String) {
        DispatchQueue.main.async(execute: { [weak self] in
            UIView.animate(withDuration: 1/3, animations: {
                self?.loadingLabel.font = UIFont.preferredFont(forTextStyle: .headline)
                self?.loadingLabel.textColor = .black
                self?.loadingLabel.text = message
                self?.progress.stopAnimating()
                self?.progress.removeFromSuperview()
            }, completion: { _ in
                
            })
        })
    }
    
    public func end(){
        DispatchQueue.main.async(execute: { [weak self] in
            UIView.animate(withDuration: 1/3, animations: {
                self?.alpha = 0
            }, completion: { _ in
                self?.removeFromSuperview()
            })
        })
    }
}
