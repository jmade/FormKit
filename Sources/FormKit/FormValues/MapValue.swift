import UIKit
import MapKit

// needs section inits too




// MARK: - MapValue -
public struct MapValue: Codable {
    let identifier: UUID = UUID()
    public var customKey:String? = "MapValue"
    var lat: Double? = nil
    var lng: Double? = nil
    var radius: Double? = nil
}

public typealias MapValueChangeClosure = (MapValue) -> ()



// MARK: - FormValue -
extension MapValue: FormValue {
    
    public var formItem: FormItem {
        .map(self)
    }
    
}


//: MARK: - FormValueDisplayable -
extension MapValue: FormValueDisplayable {
    
    public typealias Cell = MapValueCell
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



public extension MapValue {
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = lat, let lng = lng else {
            return nil
        }
        return .init(latitude: lat, longitude: lng)
    }
    
    
    var placemark: MKPlacemark? {
        guard let coordinate = coordinate else {
            return nil
        }
        return .init(coordinate: coordinate)
    }
    
    
    var measurement:Measurement<UnitLength>? {
        guard let radius = radius else {
            return nil
        }
        return .init(value: radius, unit: .meters)
    }
    
}




extension MapValue: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: MapValue, rhs: MapValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


// init

public extension MapValue {
    
    init(_ lat:Double? = nil,_ lng:Double? = nil,_ radius:Measurement<UnitLength>? = nil) {
        self.lng = lng
        self.lat = lat
        self.radius = radius?.converted(to: .meters).value
    }
    
    
    init(lat:Double,lng:Double,_ radius:Measurement<UnitLength>? = nil) {
        self.lng = lng
        self.lat = lat
        self.radius = radius?.converted(to: .meters).value
    }
    
    init(mapItem:MKMapItem,_ radius:Measurement<UnitLength>? = nil) {
        self.lng = mapItem.placemark.coordinate.longitude
        self.lat = mapItem.placemark.coordinate.latitude
        self.radius = radius?.converted(to: .meters).value
    }
    
    init(mapItem:MKMapItem,_ radius:Double?) {
        self.lng = mapItem.placemark.coordinate.longitude
        self.lat = mapItem.placemark.coordinate.latitude
        self.radius = radius
    }
    
    
}


// extend the frameworks to take in my types
// ( reverse injection ) 
//: MARK: MapValueCell


public final class MapValueCell: UITableViewCell {
    static let identifier = "jmade.FormKit.MapValueCell.identifier"
    
    
    var formValue : MapValue? {
        didSet {
            guard let mapValue = formValue else { return }
            handleMapValue(mapValue)
            
            self.selectionStyle = .none
        }
    }
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath:IndexPath?
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        mapView.delegate = self
        return mapView
    }()
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.heightAnchor.constraint(equalToConstant: 220.0).isActive = true
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
        mapView.removeAnnotations(mapView.annotations)
    }
    
    
}


extension MapValueCell {
    
    private func handleMapValue(_ mapValue:MapValue) {
        
        guard let coordinate = mapValue.coordinate else {
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        
        if let measurement = mapValue.measurement {
            mapView.addOverlay(
                MKCircle(center: coordinate,
                         radius: measurement.converted(to: .meters).value
                ),
                level: .aboveRoads
            )
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.039, longitudeDelta: 0.039)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}



extension MapValueCell: MKMapViewDelegate  {
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MKCircle {
            let renderer = CircleGeoZoneRenderer(overlay: overlay)
            renderer.lineWidth = 8.0
            if #available(iOS 13.0, *) {
                renderer.strokeColor = .systemRed
                renderer.fillColor = UIColor.systemRed.withAlphaComponent(0.1)
            } else {
                renderer.strokeColor = .red
                renderer.fillColor = UIColor.red.withAlphaComponent(0.1)
            }
            return renderer
        }

        return MKOverlayRenderer()
    }
    
}


//: MARK: - CircleGeoZoneRenderer -
public class CircleGeoZoneRenderer : MKCircleRenderer {
    
    override public func applyStrokeProperties(to context: CGContext, atZoomScale zoomScale: MKZoomScale) {
        super.applyStrokeProperties(to: context, atZoomScale: zoomScale)
        context.setLineWidth(4.0)
        if #available(iOS 13.0, *) {
            context.setStrokeColor(UIColor.systemRed.cgColor)
        } else {
            context.setStrokeColor(UIColor.red.cgColor)
        }

    }
    
    public override func applyFillProperties(to context: CGContext, atZoomScale zoomScale: MKZoomScale) {
        super.applyFillProperties(to: context, atZoomScale: zoomScale)
        if #available(iOS 13.0, *) {
            context.setStrokeColor(UIColor.systemRed.withAlphaComponent(0.1).cgColor)
        } else {
            context.setStrokeColor(UIColor.green.withAlphaComponent(0.1).cgColor)
        }
        
    }
}
