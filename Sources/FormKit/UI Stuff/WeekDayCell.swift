
import UIKit


//: MARK: - CircleView -
public class CircleView: UIView {
    required public init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    init() {
        super.init(frame: .zero)
        self.layer.cornerRadius = bounds.width/2
        self.layer.masksToBounds = true
    }
    public override func layoutSubviews() {
        self.layer.cornerRadius = bounds.width/2
        self.layer.masksToBounds = true
    }
}



// MARK: - WeekDayCellData -
struct WeekDayCellData {
    let date: Date
    let weekDay:String
    let dayOfMonth: String
    var showIndicator: Bool = false
}


extension WeekDayCellData {
    
    func newShowingIndicator() -> WeekDayCellData {
        WeekDayCellData(date: self.date,
                        weekDay: self.weekDay,
                        dayOfMonth: self.dayOfMonth,
                        showIndicator: true
        )
    }
    
    func newWithoutIndicator() -> WeekDayCellData {
        WeekDayCellData(date: self.date,
                        weekDay: self.weekDay,
                        dayOfMonth: self.dayOfMonth,
                        showIndicator: false
        )
    }
    
    
    mutating func turnOn() {
        self.showIndicator = true
    }
    
    mutating func turnOff() {
        self.showIndicator = false
    }
}


extension WeekDayCellData {
    
    var dayOfMonthText: String {
        return "\(dayOfMonth)"
    }
    
    var dayOfWeekText: String {
        return weekDay.uppercased()
    }
    
    var indicatorViewIsHidden: Bool {
        return !showIndicator
    }
    
    var isToday: Bool {
        return date.isToday()
    }
    
    func matches(_ theirs:String) -> Bool {
        return theirs == self.date.dateString()
    }
}


extension WeekDayCellData {
    
    static func Data(_ daysAhead:Int = 13) -> [WeekDayCellData] {
        
        var data: [WeekDayCellData] = []
    
        func getValueFrom(_ date:Date) -> (dayOfMonth:String,weekDay:String) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d-E"
            let dateString = dateFormatter.string(from: date)
            return ((dateString.split("-").first ?? ""),(dateString.split("-").last ?? ""))
        }
        
        var date = Date()
        
        Array(0...daysAhead).forEach({ _ in
            let val = getValueFrom(date)
            data.append(
                WeekDayCellData(
                    date: date,
                    weekDay: val.weekDay,
                    dayOfMonth: val.dayOfMonth
                )
            )
           date = date.nextDay()
        })
        
        return data
    }
    
    
    var info:String {
        return "\(newInfoString)"
    }
    
    
    private var newInfoString: String {
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = "EEEE, MMMM d, yyyy"
        return dateFormator.string(from: self.date)
    }
    
}



// MARK: - WeekDayCell -
class WeekDayCell: UICollectionViewCell {
    static let ReuseID = "com.jmade.FormKit.WeekDayCell"
    
    lazy var weekDayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    lazy var dayOfMonthLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    lazy var indictorView: CircleView = {
        let view = CircleView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .label
        } else {
            view.backgroundColor = .black
        }
        return view
    }()
    
    var weekDayCellData: WeekDayCellData? = nil {
        didSet {
            guard let weekDayCellData = weekDayCellData else { return }
            weekDayLabel.text = weekDayCellData.dayOfWeekText
            dayOfMonthLabel.text = weekDayCellData.dayOfMonthText
            indictorView.isHidden = weekDayCellData.indicatorViewIsHidden
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                UIViewPropertyAnimator(duration: 0.1, curve: .easeIn) {
                    [weak self] in
                    
                    if #available(iOS 13.0, *) {
                        self?.contentView.backgroundColor = .systemBlue
                        
                        self?.weekDayLabel.textColor = .white
                        self?.dayOfMonthLabel.textColor = .white
                        self?.indictorView.backgroundColor = .white
                    } else {
                        self?.contentView.backgroundColor = .blue
                        self?.weekDayLabel.textColor = .white
                        self?.dayOfMonthLabel.textColor = .white
                        self?.indictorView.backgroundColor = .white
                    }
                }.startAnimation()
            } else {
                UIViewPropertyAnimator(duration: 0.1, curve: .easeIn) {
                    [weak self] in
                   if #available(iOS 13.0, *) {
                        self?.contentView.backgroundColor = .secondarySystemBackground
                    
                        self?.weekDayLabel.textColor = .label
                        self?.dayOfMonthLabel.textColor = .label
                        self?.indictorView.backgroundColor = .label
                    } else {
                        self?.contentView.backgroundColor = .white
                    
                        self?.weekDayLabel.textColor = .black
                        self?.dayOfMonthLabel.textColor = .black
                        self?.indictorView.backgroundColor = .black
                    }
                }.startAnimation()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [weekDayLabel,dayOfMonthLabel,indictorView]
            .forEach({
                $0.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview($0)
            })
    
        NSLayoutConstraint.activate([
            weekDayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            weekDayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
            
            dayOfMonthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            dayOfMonthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            
            indictorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            indictorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.08),
            indictorView.heightAnchor.constraint(equalTo: indictorView.widthAnchor, multiplier: 1.0),
            indictorView.topAnchor.constraint(equalTo: dayOfMonthLabel.bottomAnchor, constant: 2.0),
        ])
        
        
        contentView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 12.0
        
    }
    
    func configureCell(_ data:WeekDayCellData) {
        self.weekDayCellData = data
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = nil
        weekDayCellData = nil
        weekDayLabel.text = nil
        dayOfMonthLabel.text = nil
        indictorView.isHidden = true
    }
}

