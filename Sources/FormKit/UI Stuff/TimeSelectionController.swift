import UIKit

/// called on `dataSource`

//: MARK: - TimeSelectionController -
public class TimeSelectionController: UIViewController {
    
    weak var updateFormValueDelegate:UpdateFormValueDelegate?
    
    var indexPath:IndexPath?
    
    var timeValue:TimeValue? {
        didSet {
            if let timeValue = timeValue {
                startingTime = timeValue.time
                title = timeValue.title
            }
        }
    }
    
    var startingTime:String? = nil
    var minIncrement: Int = 5
    
    private lazy var picker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        let margin = view.layoutMarginsGuide
        pickerView.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        pickerView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        return pickerView
    }()
    
    
    private var dataSource: [[String]] = [
        ["1","2","3","4","5","6","7","8","9","10","11","12"],
        ["00","05","10","15","20","25","30","35","40","45","50","55"],
        ["AM","PM"]
    ]
    
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        let f = UIImpactFeedbackGenerator()
        f.prepare()
        return f
    }()
    
    required public init?(coder aDecoder: NSCoder) {fatalError()}
    public init() {super.init(nibName: nil, bundle: nil)}
    public convenience init(_ timeValue:TimeValue) {
        self.init()
        defer {
            self.timeValue = timeValue
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        if #available(iOS 13.0, *) {
             view.backgroundColor = .secondarySystemBackground
        } else {
             view.backgroundColor = .white
        }
        
        dataSource = generateDataSource()
        //setupPicker()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTime()
    }
    
    @objc
    func handleSave(){
        resolvePicker()
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    
   private func setupPicker(){
        picker.delegate = self
        picker.dataSource = self
        let margin = view.layoutMarginsGuide
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        picker.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
    }
    
    private func generateDataSource() -> [[String]] {
        return [
            ["1","2","3","4","5","6","7","8","9","10","11","12"],
            stride(from: 0, to: 60, by: minIncrement).map({String(format: "%02d", $0)}),
            ["AM","PM"]
        ]
    }
    
    
    private func setTime() {
        
        if let startingTime = startingTime {
            let hourSplit = startingTime.split(":")
            if let hour = hourSplit.first {
                if let index = dataSource[0].indexOf(hour) {
                    picker.selectRow(index, inComponent: 0, animated: true)
                }
            }
            if let nextSplit = hourSplit.last {
                let minSplit = nextSplit.split(" ")
                if let mins = minSplit.first {
                    if let index = dataSource[1].indexOf(mins) {
                        picker.selectRow(index, inComponent: 1, animated: true)
                    }
                }
                if let meridan = minSplit.last {
                    if let index = dataSource[2].indexOf(meridan) {
                        picker.selectRow(index, inComponent: 2, animated: true)
                    }
                }
            }
        } else {
            setToCurrentTime()
        }
            
       
        feedbackGenerator.impactOccurred()
    }
    
    
    
    private func setToCurrentTime() {
        
        func findIndexOf(_ value:String,in strings:[String]) -> Int {
            for (i, str) in strings.enumerated() {
                if value == str {
                    return i
                }
            }
            return 0
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: Date())
        
        let dateTimeString = dateString.split(separator: " ").first!
        let hourString = String(dateTimeString.split(separator: ":").first!)
        let minString = String(dateTimeString.split(separator: ":").last!)
        let periodString = String(dateString.split(separator: " ").last!)
        
        let hourColumnIndex = findIndexOf(hourString, in: dataSource[0])
        let minColumnIndex = findIndexOf(minString, in: dataSource[1])
        let periodColumnIndex = findIndexOf(periodString, in: dataSource[2])
        
        picker.selectRow(hourColumnIndex, inComponent: 0, animated: true)
        picker.selectRow(minColumnIndex, inComponent: 1, animated: true)
        picker.selectRow(periodColumnIndex, inComponent: 2, animated: true)
    }
    
}


extension TimeSelectionController: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSource.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource[component].count
    }
}


extension TimeSelectionController: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return dataSource[component][row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        /* do something cool here ??... */
    }
    
    func resolvePicker() {
        let selectedHour = dataSource[0][picker.selectedRow(inComponent: 0)]
        let selectedMins = dataSource[1][picker.selectedRow(inComponent: 1)]
        let period = dataSource[2][picker.selectedRow(inComponent: 2)]
        updateFormValueDelegate?.updatedFormValue(
            TimeValue(title: title ?? "", time: "\(selectedHour):\(selectedMins) \(period)"),
            indexPath
        )
        
    }
    
}
