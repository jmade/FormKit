import UIKit
import MapKit

public typealias MapKitOverlayRendererClosure = ((MKMapView,MKOverlay) -> MKOverlayRenderer)
public typealias MapKitAnnotationViewClosure = ((MKMapView,MKAnnotation) -> MKAnnotationView?)
public typealias MapViewConigurationClosure = ((MKMapView) -> Void)

public struct MapData {
    public var polygon:MKPolygon?
    public var overlay:MKOverlay?
    public var annotation:MKAnnotation?
    public var region:MKCoordinateRegion?
    public var mapRect:MKMapRect?
    public var camera:MKMapCamera?
    public var overlayRendererClosure: MapKitOverlayRendererClosure?
    public var annotationViewClosure: MapKitAnnotationViewClosure?
    public var mapConfiguration: MapViewConigurationClosure?
}


public extension MapData {
    
    init(_ polygon: MKPolygon? = nil,_ overlay: MKOverlay? = nil,_ annotation: MKAnnotation? = nil, _ region: MKCoordinateRegion? = nil,_ mapRect: MKMapRect? = nil,_ camera:MKMapCamera? = nil,_ overlayRendererClosure: MapKitOverlayRendererClosure? = nil,_ annotationViewClosure: MapKitAnnotationViewClosure? = nil,_ mapConfiguration: MapViewConigurationClosure? = nil) {
        self.polygon = polygon
        self.overlay = overlay
        self.annotation = annotation
        self.region = region
        self.mapRect = mapRect
        self.camera = camera
        self.overlayRendererClosure = overlayRendererClosure
        self.annotationViewClosure = annotationViewClosure
        self.mapConfiguration = mapConfiguration
    }
    
}







// MARK: - MapValue -
public struct MapValue {
    var identifier: UUID = UUID()
    public var customKey:String? = "MapValue"
    var lat: Double? = nil
    var lng: Double? = nil
    var radius: Double? = nil
    
    /*
    public struct MapData {
        public var polygon:MKPolygon?
        public var overlay:MKOverlay?
        public var annotation:MKAnnotation?
        public var region:MKCoordinateRegion?
        public var mapRect:MKMapRect?
        public var overlayRendererClosure: MapKitOverlayRendererClosure?
        public var annotationViewClosure: MapKitAnnotationViewClosure?
        
        /*
        public init(polygon:MKPolygon?,overlay:MKOverlay?,annotation:MKAnnotation?,region:MKCoordinateRegion?,mapRect:MKMapRect?,overlayRendererClosure: MapKitOverlayRendererClosure?,annotationViewClosure: MapKitAnnotationViewClosure?) {
            self.polygon = polygon
            self.overlay = overlay
            self.annotation = annotation
            self.region = region
            self.mapRect = mapRect
            self.overlayRendererClosure = overlayRendererClosure
            self.annotationViewClosure = annotationViewClosure
        }
        */
    }
    */
    
    public var mapData: MapData?
    public var validators: [Validator] = []
}

public typealias MapValueChangeClosure = (MapValue) -> ()


public extension MapValue {
    init(_ mapData:MapData) {
        self.mapData = mapData
    }
}



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





// MARK: - MapValueCell -
public final class MapValueCell: UITableViewCell {
    
    static let identifier = "com.jmade.FormKit.MapValueCell.identifier"
    
    
    var formValue : MapValue? {
        didSet {
            guard let mapValue = formValue else { return }
            
            if mapView == nil {
                self.mapView = createMapView()
            }
            
            if let data = mapValue.mapData {
                handleMapData(data)
            } else {
                handleMapValue(mapValue)
            }
            
            self.selectionStyle = .none
        }
    }
    
    weak var updateFormValueDelegate: UpdateFormValueDelegate?
    var indexPath:IndexPath?
    
    public var mapView: MKMapView? = nil
    
    private lazy var overView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        view.backgroundColor = .init(white: 0.7, alpha: 0.5)
        return view
    }()
    
    
    required init?(coder aDecoder: NSCoder) {fatalError()}
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activateDefaultHeightAnchorConstraint(220)
        contentView.bringSubviewToFront(overView)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        formValue = nil
        
        if let annos = mapView?.annotations {
            if annos.isEmpty == false {
                mapView?.removeAnnotations(annos)
            }
        }
        
    }
    
    
}


extension MapValueCell {
    
    private func handleMapData(_ data:MapData) {
        guard let mapView = mapView else {return}
        
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        if !mapView.overlays.isEmpty {
            mapView.removeOverlays(mapView.overlays)
        }
        
        data.mapConfiguration?(mapView)
        
        if let polygon = data.polygon {
            mapView.addOverlay(polygon)
        }
        
        if let annotation = data.annotation {
            mapView.addAnnotation(annotation)
        }
        
        if let overlay = data.overlay {
            mapView.addOverlay(overlay)
        }
        
        if let rect = data.mapRect {
            let edgePadding = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
            mapView.setVisibleMapRect(
                mapView.mapRectThatFits(rect, edgePadding: edgePadding),
                edgePadding: edgePadding,
                animated: true
            )
        }
        
        
        if let region = data.region {
            mapView.setRegion(region, animated: true)
        }
        
        if let cam = data.camera {
            
            UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.5) { [weak self] in
                           guard let self = self else { return }
                           self.mapView?.camera = cam
            }.startAnimation()
            
        }
        
        
    }
    
    private func handleMapValue(_ mapValue:MapValue) {
        
        guard
            let coordinate = mapValue.coordinate,
            let mapView = mapView
        else {
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
    
    
    private func createMapView() -> MKMapView {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        mapView.delegate = self
        return mapView
    }
    
}



extension MapValueCell: MKMapViewDelegate  {
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("didAdd: \(views)")
        
        for view in views {
            view.setSelected(true, animated: true)
        }
    }
    
    
    public func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        print("didSelect anno: \(annotation)")
    }
    
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let mapValue = formValue {
            if let closure = mapValue.mapData?.annotationViewClosure {
                return closure(mapView,annotation)
            }
        }
        
           return nil
       }
    
    
    
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let mapValue = formValue {
            if let closure = mapValue.mapData?.overlayRendererClosure {
                return closure(mapView,overlay)
            }
        }
        
        
        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: (overlay as! MKPolygon))
            renderer.lineWidth = 4.0
            if #available(iOS 13.0, *) {
                renderer.strokeColor = .systemBlue
                renderer.fillColor = UIColor.systemRed.withAlphaComponent(0.3)
            } else {
                renderer.strokeColor = .blue
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
            }
            return renderer
        }
        
        
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
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
    
    
    
    public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self else { return }
            UIViewPropertyAnimator(duration: 0.3, curve: .easeIn) { [weak self] in
                guard let self = self else { return }
                self.overView.isHidden = false
                if let mapView = self.mapView {
                    self.contentView.bringSubviewToFront(mapView)
                }
            }.startAnimation()
        })
        
        
    }
    
}

