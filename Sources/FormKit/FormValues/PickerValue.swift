import UIKit


//: MARK: - PickerValue -
public struct PickerValue: FormValue, Equatable, Hashable {
    public var customKey: String? = "PickerValue"
    
    
    public var formItem: FormItem {
        get {
            return FormItem.picker(self)
        }
    }
    
    var values:[String]
    var selectedIndex: Int
    public init(_ values:[String],_ selectedIndex:Int = 0){
        self.values = values
        self.selectedIndex = selectedIndex
    }
}

extension PickerValue: FormValueDisplayable {
    
    public typealias Cell = PickerCell
    public typealias Controller = FormController
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        //
    }
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
}



public final class PickerCell: UITableViewCell {
    static let identifier = "pickerCell"
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath: IndexPath?
    
    var pickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    var pickerDataSource:[String] = []
    
    var formValue : PickerValue! {
        didSet {
            pickerDataSource = formValue.values
            if let path = indexPath {
                updateFormValueDelegate?.updatedFormValue(formValue, path)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        contentView.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        
        // Standard Height
        let normalHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88.0)
        normalHeightConstraint.priority = UILayoutPriority(499.0)
        normalHeightConstraint.isActive = true
        
    }
    
}


extension PickerCell: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
}

extension PickerCell: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let path = indexPath {
            updateFormValueDelegate?.updatedFormValue(PickerValue(pickerDataSource, row), path)
        }
    }
    
}
