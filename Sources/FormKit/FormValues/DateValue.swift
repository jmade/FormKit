//
//  File.swift
//  
//
//  Created by Justin Madewell on 10/1/20.
//

import UIKit


public struct DateValue {
    var identifier: UUID = UUID()
    public var customKey:String? = nil
    public var title:String?
    public var date:Date? = Date()
    public var dateFormat:String?
    /// TableSelectable
    public var isSelectable: Bool = false
}


extension DateValue {
    public init(_ title:String?,_ customKey:String,_ dateFormat:String? = nil,_ date:Date? = Date()) {
        self.title = title
        self.customKey = customKey
        self.dateFormat = dateFormat
        self.date = date
    }
    
    
    public func newWith(_ date:Date) -> DateValue {
        DateValue(identifier: UUID(), customKey: self.customKey, title: self.title, date: date, dateFormat: self.dateFormat, isSelectable: self.isSelectable)
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
    
    
    var selectedValue:String {
        if let date = date {
            return "\(date)"
        }
        return ""
    }
    
}


extension DateValue: FormValue {
    
    public var formItem: FormItem {
        .date(self)
    }

    public func encodedValue() -> [String : String] {
        return [ encodedTitle : selectedValue ]
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










// MARK: - DateValueCell -  
public final class DateValueCell: UITableViewCell {
    
    static let identifier = "com.jmade.FormKit.DateValueCell.identifier"
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeekDayCell.self, forCellWithReuseIdentifier: WeekDayCell.ReuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
        if #available(iOS 13.0, *) {
            view.backgroundColor = .tertiarySystemBackground
        } else {
            view.backgroundColor = .white
        }
        view.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8.0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }()
    
    
    private var dataSource:[WeekDayCellData] = WeekDayCellData.Data(60)
    
    
    var formValue : DateValue? {
        didSet {
            guard formValue != nil else { return }
            prepareCollectionView()
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
            
            collectionView.topAnchor.constraint(equalTo: dateContainer.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 4.0),
            infoLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            
            dateContainer.bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor)
        ])
        
        //dateContainer.heightAnchor.constraint(equalToConstant: 92.0),
        //collectionView.heightAnchor.constraint(equalToConstant: 88.0),
        //collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52.0),
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

    
    private func prepareCollectionView() {
        
        let animator = UIViewPropertyAnimator(duration: 1/3, curve: .linear) { [weak self] in
            guard let self = self else { return }
            self.infoLabel.text = self.dataSource[0].info
            if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.itemSize = CGSize(
                    width: self.collectionView.bounds.width/7,
                    height: self.collectionView.bounds.height
                )
            }
        }
        
        animator.addCompletion { (position) in
            if position == .end {
                self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            }
        }
        
        animator.startAnimation()
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
        infoLabel.text = dataSource[indexPath.row].info
        guard let dateValue = formValue else { return }
        let newValue = dateValue.newWith(dataSource[indexPath.row].date)
        updateFormValueDelegate?.updatedFormValue(
            newValue,
            indexPath
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

