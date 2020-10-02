//
//  File.swift
//  
//
//  Created by Justin Madewell on 10/1/20.
//

import UIKit


public struct DateValue {
    var identifier: UUID = UUID()
    public var customKey:String? = "MapValue"
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
        guard date != nil else {
            return ""
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
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
       lazy var tableView = UITableView()
       
       lazy var infoLabel = UILabel()
       lazy var dateContainer = UIView()
    
    private var dataSource:[WeekDayCellData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var formValue : DateValue? {
        didSet {
            guard formValue != nil else { return }
            self.dataSource =  WeekDayCellData.Data(60)
            

            self.infoLabel.text = dataSource[0].info
            if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.itemSize = CGSize(
                    width: collectionView.bounds.width/7,
                    height: collectionView.bounds.height
                )
            }
            
            
            self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            
            
            self.selectionStyle = .none
        }
    }
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath:IndexPath?
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //activateDefaultHeightAnchorConstraint(220)
        setupCollectionView()
    }

    
    override public func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
    }
    
}


extension DateValueCell {
    
    private func getSelectDayIndex() -> Int? {
        if let selectedCollectionviewPaths = collectionView.indexPathsForSelectedItems {
            if let dayIndex = selectedCollectionviewPaths.first {
                return dayIndex.row
            }
        }
        return nil
    }
    
    
    private func setupCollectionView() {
        
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            dateContainer.backgroundColor = .systemBackground
        } else {
            dateContainer.backgroundColor = .white
        }
        contentView.addSubview(dateContainer)
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = .preferredFont(forTextStyle: .body)
        infoLabel.textAlignment = .center
        dateContainer.addSubview(infoLabel)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
    
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeekDayCell.self, forCellWithReuseIdentifier: WeekDayCell.ReuseID)
        
        
        dateContainer.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            dateContainer.heightAnchor.constraint(equalToConstant: 92.0),
            dateContainer.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 0),
            dateContainer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 0),
            dateContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: 0),
            
            collectionView.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: dateContainer.topAnchor, constant: 0),
            collectionView.heightAnchor.constraint(equalToConstant: 88.0),
            
            infoLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor, constant: 0),
            infoLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: 0),
            infoLabel.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor, constant: -2.0),
            infoLabel.centerXAnchor.constraint(equalTo: dateContainer.centerXAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor, constant: 0)
        ])
        
        

        dateContainer.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        dateContainer.layer.masksToBounds = true
        dateContainer.layer.cornerRadius = 12.0
        
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
        
        
        
        /// informdelegate here... dataSource[indexPath.row].date
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

