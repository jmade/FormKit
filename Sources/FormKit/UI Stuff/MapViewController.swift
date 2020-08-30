//
//  MapViewController.swift
//  FWTest
//
//  Created by Justin Madewell on 8/4/20.
//  Copyright © 2020 MadewellTech. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark,searchItem:SearchResultItem?)
}



final class MapViewController: UIViewController {
    
    public var mapValueChangeClosure:MapValueChangeClosure? = nil
    public var mapActionUpdateClosure: MapActionUpdateClosure? = nil
    
    private var searchItem: SearchResultItem? = nil
    
    public var mapView: MKMapView?
    
    private var radius:Measurement<UnitLength>? = nil
    
    private var selectedPin:MKPlacemark? = nil
    
    
    private var mapValue:MapValue {
        guard let placemark = selectedPin else {
            return .init(lat: Double(), lng: Double(), self.radius)
        }
        return .init(mapItem: MKMapItem(placemark: placemark), self.radius)
    }
    
    private var mapActionValue: MapActionValue {
        return .init(searchItem?.primary, searchItem?.secondary, mapValue)
    }
    
    
    // Search
    private var locationSearchTable:LocationSearchTable? = nil
    private var resultSearchController:UISearchController? = nil
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    init(mapValue:MapValue?) {
        super.init(nibName: nil, bundle: nil)
        if let mapValue = mapValue {
            self.selectedPin = mapValue.placemark
            self.radius = mapValue.measurement
        }
    }
    
    
    init(mapActionValue:MapActionValue) {
        super.init(nibName: nil, bundle: nil)
        if let mapValue = mapActionValue.mapValue {
            self.selectedPin = mapValue.placemark
            self.radius = mapValue.measurement
        }
        
        self.searchItem = SearchResultItem(primary: mapActionValue.primary, secondary: mapActionValue.secondary)
    }
    
    
    override func loadView() {
        let view = UIView()
        self.view = view
    }
    
        
    
    fileprivate func makeMapView() -> MKMapView {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.delegate = self
        return mapView
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mapView = mapView {
            mapView.delegate = self
        } else {
            self.mapView = makeMapView()
        }

        
        
        let locationSearchTable = LocationSearchTable()
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        if let loadedPin = selectedPin {
            displayAnnotationAt(coordinate: loadedPin.coordinate, title: searchItem?.primary, subtitle: searchItem?.secondary)
            
        }
        
    }

    
    
}


// MARK: - MKMapViewDelegate -
extension MapViewController: MKMapViewDelegate  {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "MapViewController.Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MKCircle {
            let renderer = MKCircleRenderer()
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




// MARK: - HandleMapSearch -
extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark, searchItem: SearchResultItem?) {
        
        self.searchItem = searchItem
        self.selectedPin = placemark
        
        displayAnnotationAt(coordinate: placemark.coordinate, title: searchItem?.primary, subtitle: searchItem?.secondary)
        
         //mapValueChangeClosure?(self.mapValue)
         mapActionUpdateClosure?(self.mapActionValue)
    }
    
    
    private func load(_ mapActionValue:MapActionValue) {
        
        if let coord = mapActionValue.mapValue?.coordinate {
            self.selectedPin = MKPlacemark(coordinate: coord)
            self.searchItem = SearchResultItem(primary: mapActionValue.primary, secondary: mapActionValue.secondary)
            
            displayAnnotationAt(coordinate: coord, title: mapActionValue.primary, subtitle: mapActionValue.secondary)
        }
        
    }
    
    
    
    
    private func displayAnnotationAt(coordinate: CLLocationCoordinate2D,title: String?,subtitle: String? ) {
        
        guard let mapView = mapView else {
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        
        
        if let radius = radius {
            mapView.addOverlay(
                MKCircle(center: coordinate,
                         radius: radius.converted(to: .meters).value
                ),
                level: .aboveRoads
            )
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.039, longitudeDelta: 0.039)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    
//    private func handlePlacemark(_ placemark:MKPlacemark) {
//
//        var subtitle:String? = nil
//        if let city = placemark.locality,
//            let state = placemark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
//
//
//
//    }
    
    
//
//    func dropPinZoomIn(placemark:MKPlacemark) {
//
//
//
//
//    }
    
}








////: MARK: - CircleGeoZoneRenderer -
//public class CircleGeoZoneRenderer : MKCircleRenderer {
//
//    override public func applyStrokeProperties(to context: CGContext, atZoomScale zoomScale: MKZoomScale) {
//        super.applyStrokeProperties(to: context, atZoomScale: zoomScale)
//        context.setLineWidth(4.0)
//        if #available(iOS 13.0, *) {
//            context.setStrokeColor(UIColor.systemRed.cgColor)
//        } else {
//            context.setStrokeColor(UIColor.red.cgColor)
//        }
//
//    }
//
//    public override func applyFillProperties(to context: CGContext, atZoomScale zoomScale: MKZoomScale) {
//        super.applyFillProperties(to: context, atZoomScale: zoomScale)
//        if #available(iOS 13.0, *) {
//            context.setStrokeColor(UIColor.systemRed.withAlphaComponent(0.1).cgColor)
//        } else {
//            context.setStrokeColor(UIColor.green.withAlphaComponent(0.1).cgColor)
//        }
//
//    }
//}
