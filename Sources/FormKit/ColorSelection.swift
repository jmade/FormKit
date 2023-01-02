
import UIKit

@available(iOS 14.0, *)
class ColorSelection: UIViewController {
    
    private let colorPickerController = UIColorPickerViewController()
    
    private var selectedColor: UIColor? {
        didSet {
            selectedColorClosure?(selectedColor)
        }
    }

    var selectedColorClosure: ((UIColor?) -> Void)?
    
    private var loadedColor: UIColor?
    
    public var color: UIColor {
        get {
            if let selectedColor {
                return selectedColor
            }
            return loadedColor ?? .white
        }
        
        set {
            loadedColor = newValue
        }
    }
    
    
    init(color:UIColor? = nil,selectedColorClosure: @escaping (UIColor?) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.loadedColor = color
        self.selectedColorClosure = selectedColorClosure
        self.colorPickerController.delegate = self
    }
    
    
    init(_ selectedColorClosure: @escaping (UIColor?) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.selectedColorClosure = selectedColorClosure
        self.colorPickerController.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
    }
    
    
    
    private func setup() {
        
        let topStack = UIStackView()
        topStack.alignment = .fill
        topStack.distribution = .fillProportionally
        topStack.axis = .horizontal
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        let rainbowButton = UIButton()
        rainbowButton.setTitle("Full Spectrum", for: .normal)
        rainbowButton.addTarget(self, action: #selector(rainbowButtonSelected), for: .touchUpInside)
        rainbowButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark.circle") , for: .normal)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill") , for: .selected)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        topStack.addArrangedSubview(rainbowButton)
        topStack.addArrangedSubview(closeButton)
        
        view.addSubview(topStack)
        
        addChild(colorPickerController)
        colorPickerController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(colorPickerController.view)
        
        NSLayoutConstraint.activate([
            
            topStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            topStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            topStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            colorPickerController.view.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8),
            colorPickerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorPickerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorPickerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        colorPickerController.didMove(toParent: self)
        
        if let loadedColor {
            colorPickerController.selectedColor = loadedColor
        }
        
        
    }
    
    
    @objc private func rainbowButtonSelected() {
        selectedColor = nil
        dismiss(animated: true)
    }
    
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



@available(iOS 14.0, *)
extension ColorSelection: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
    }

    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        selectedColor = color
        if continuously == false {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1/4) { [weak self] in
                self?.dismiss(animated: true)
            }

        }
    }
    
}
