
import UIKit


public struct DateValue {
    
    let identifier: UUID = UUID()
    public var customKey:String? = nil
    public var title:String?
    public var date:Date
    public var dateFormat = "yyyy-MM-dd"
    public var exportDateFormat:String?
    public var displayDateFormat:String?
    /// TableSelectable
    public var isSelectable: Bool = false
    
    public var minDate:Date?
    public var maxDate:Date?
    
}


extension DateValue {
    
    public init(_ date:Date = Date()) {
        self.title =  nil
        self.customKey = nil
        self.date = date
    }
    
    public init(title:String,date:Date) {
        self.title = title
        self.customKey = nil
        self.date = date
    }
    
    public init(_ title:String,_ date:Date) {
        self.title = title
        self.customKey = nil
        self.date = date
    }
    
    
    public init(_ title:String?,_ customKey:String,_ dateFormat:String,_ date:Date) {
        self.title = title
        self.customKey = customKey
        self.dateFormat = dateFormat
        self.date = date
    }
    
    public init(_ title:String,_ customKey:String) {
        self.title = title
        self.customKey = customKey
        self.date = Date()
    }


    public init(_ title:String,_ customKey:String,_ date:Date?) {
        self.title = title
        self.customKey = customKey
        self.date = date ?? Date()
    }
    
    
    public init(_ title:String,_ customKey:String,_ date:Date?,_ minDate:Date?,_ maxDate:Date?) {
        self.title = title
        self.customKey = customKey
        self.date = date ?? Date()
        self.minDate = minDate
        self.maxDate = maxDate
    }
    
    public init(_ title:String,_ customKey:String,_ displayFormat:String,_ exportFormat:String, _ date:Date?,_ minDate:Date?,_ maxDate:Date?) {
        self.title = title
        self.customKey = customKey
        self.date = date ?? Date()
        self.minDate = minDate
        self.maxDate = maxDate
        self.displayDateFormat = displayFormat
        self.exportDateFormat = exportFormat
    }
    
}


extension DateValue {
    
    public func newWith(_ date:Date) -> DateValue {
        DateValue(customKey: self.customKey,
                  title: self.title,
                  date: date,
                  dateFormat: self.dateFormat,
                  exportDateFormat: self.exportDateFormat,
                  displayDateFormat: self.displayDateFormat,
                  isSelectable: self.isSelectable,
                  minDate: self.minDate,
                  maxDate: self.maxDate
        )
    }
    
}



extension DateValue {
    
    var formattedValue:String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
    
    var displayValue:String {
        let formatter = DateFormatter()
        formatter.dateFormat = displayDateFormat ?? dateFormat
        return formatter.string(from: date)
    }
    
    var exportValue:String {
        let formatter = DateFormatter()
        formatter.dateFormat = exportDateFormat ?? dateFormat
        return formatter.string(from: date)
    }
    
    var range:Int? {
        guard let min = minDate,let max = maxDate else {
            return nil
        }
        return max.daysApart(min)
    }
    
}



extension DateValue {
    
    var encodedTitle:String {
        if let key = customKey {
            return key
        }
        if let title = title {
            return title
        }
        return "Date"
    }
    
}


extension DateValue: FormValue {
    
    public var formItem: FormItem {
        .date(self)
    }

    public func encodedValue() -> [String : String] {
        return [ encodedTitle : exportValue ]
    }
    
}


//: MARK: - FormValueDisplayable -
extension DateValue: FormValueDisplayable {
    
    public typealias Cell = DateValueCell
    public typealias Controller = FormController
    
    public var cellDescriptor: FormCellDescriptor {
        return FormCellDescriptor(Cell.identifier, configureCell, didSelect)
    }
    
    public func didSelect(_ formController: Controller, _ path: IndexPath) {
        /*  */
    }
    
    public func configureCell(_ formController: Controller, _ cell: Cell, _ path: IndexPath) {
        cell.formValue = self
        cell.indexPath = path
        cell.updateFormValueDelegate = formController
    }
    
    
}



extension DateValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: DateValue, rhs: DateValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


extension DateValue {
    public static func Random() -> DateValue {
        DateValue("Date",
                  Date(
                    timeIntervalSince1970:
                    Double.random(in: 1...Date().timeIntervalSince1970)
            )
        )
    }
}



extension UIColor {
    
    
    static var dateValueBackground:UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray4
        } else {
            return .white
        }
    }
    
    
    static var dateValueSelection:UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray
        } else {
            return .white
        }
    }
    
}







// MARK: - DateValueCell -  
public final class DateValueCell: UITableViewCell {
    
    static let identifier = "com.jmade.FormKit.DateValueCell.identifier"
    
    static let OFFSET: CGFloat = 600.0
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.backgroundColor = .dateValueBackground
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeekDayCell.self, forCellWithReuseIdentifier: WeekDayCell.ReuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentOffset = CGPoint(x: DateValueCell.OFFSET, y: 0)
        dateContainer.addSubview(collectionView)
        return collectionView
    }()
    
    
    private lazy var infoLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        dateContainer.addSubview(label)
        return label
    }()
    
    
    private lazy var dateContainer:UIView = {
        let view = UIView()
        view.backgroundColor = .dateValueBackground
        view.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8.0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }()
    
    
    private var dataSource:[WeekDayCellData] = []
    
    var formValue : DateValue? {
        didSet {
            
            guard let dateValue = formValue else {
                animate(.out)
                return
            }
            
            if dataSource.isEmpty {
                if let range = dateValue.range {
                    dataSource = WeekDayCellData.GenerateData(range: range)
                } else {
                    dataSource = WeekDayCellData.Data(60)
                }
            }
            animate(.in)
        }
    }
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath:IndexPath?
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NSLayoutConstraint.activate([
            dateContainer.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            dateContainer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            dateContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: dateContainer.topAnchor, constant: 4.0),
            collectionView.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 4.0),
            infoLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            
            dateContainer.bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 4.0),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor),
            collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52.0),
        ])
        prepareCollectionView()
    }
  
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }

    
    override public func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
    }
    
}


extension DateValueCell {
    
    enum AnimationDirection {
        case `in`,out
    }
    
    private func animate(_ direction:AnimationDirection) {
        
        let animator = UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.75, animations: nil)
        
        let cv = collectionView
        let label = infoLabel
        let text = dataSource[0].info
        
        var path = IndexPath(row: 0, section: 0)
        if let dateValue = formValue {
            for (i,day) in dataSource.enumerated() {
                if day.date.dateString() == dateValue.date.dateString() {
                    path = IndexPath(row: i, section: 0)
                }
            }
        }
        
        switch direction {
        case .in:
            animator.addAnimations {
                cv.selectItem(at: path, animated: false, scrollPosition: .left)
                cv.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
                label.text = text
            }
        case .out:
            animator.addAnimations {
                cv.scrollToItem(at: IndexPath(row: 30, section: 0), at: .left, animated: false)
            }
            label.text = nil
        }
        
        animator.startAnimation()
    }
  
    

    
    private func prepareCollectionView() {
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(
                width: self.collectionView.bounds.width/7,
                height: self.collectionView.bounds.height
            )
        }
        
    }
    
}



// MARK: - UICollectionView -
extension DateValueCell: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekDayCell.ReuseID, for: indexPath) as? WeekDayCell {
            cell.configureCell(dataSource[indexPath.row])
            return cell
        }
        
        return UICollectionViewCell()
    }
}


extension DateValueCell: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dateValue = formValue else { return }
        
        UIViewPropertyAnimator(duration: 1/3, curve: .easeInOut) { [weak self] in
            guard let self = self else { return }
            self.infoLabel.text = self.dataSource[indexPath.row].info
        }.startAnimation()
        
        updateFormValueDelegate?.updatedFormValue(
            dateValue.newWith(dataSource[indexPath.row].date),
            self.indexPath
        )
        
    }
}


extension DateValueCell: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.size.width/7, height: collectionView.bounds.size.height)
    }
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

