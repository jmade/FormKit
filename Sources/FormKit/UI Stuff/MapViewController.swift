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
    func dropPinZoomIn(placemark:MKPlacemark)
}



final class MapViewController: UIViewController {
    
    public var mapValueChangeClosure:MapValueChangeClosure? = nil
    public var mapActionUpdateClosure: MapActionUpdateClosure? = nil
    
    var mapView: MKMapView?
    
    private var radius:Measurement<UnitLength>? = nil
    
    private var selectedPin:MKPlacemark? = nil
    
    private var mapValue:MapValue {
        guard let placemark = selectedPin else {
            return .init(lat: Double(), lng: Double(), radius)
        }
        return .init(mapItem: MKMapItem(placemark: placemark), radius)
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
    
    override func loadView() {
        let view = UIView()
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.mapView = mapView
        self.mapView?.delegate = self
        self.view = view
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            dropPinZoomIn(placemark:loadedPin)
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
    
    
    func dropPinZoomIn(placemark:MKPlacemark) {
        
        selectedPin = placemark
        
        
        
       
        
        
        guard let mapView = mapView else {
            mapValueChangeClosure?(self.mapValue)
            mapActionUpdateClosure?(
                 MapActionValue(placemark.searchItem.primary, placemark.searchItem.secondary, self.mapValue)
            )
            return
        }
        
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        if let radius = radius {
            mapView.addOverlay(
                MKCircle(center: placemark.coordinate,
                         radius: radius.converted(to: .meters).value
                ),
                level: .aboveRoads
            )
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.039, longitudeDelta: 0.039)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        mapValueChangeClosure?(self.mapValue)
        
        mapActionUpdateClosure?(
             MapActionValue(placemark.searchItem.primary, placemark.searchItem.secondary, self.mapValue)
        )
        
    }
    
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
