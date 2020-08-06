import UIKit
import MapKit

// needs section inits too

// MARK: - MapValue -
public struct MapValue: Codable {
    let identifier: UUID = UUID()
    var lat: Double? = nil
    var lng: Double? = nil
    var radius: Double? = nil
    
    //var coordinate:CLLocationCoordinate2D? = nil
    //var radius:Measurement<UnitLength>? = nil
}


extension MapValue {
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = lat, let lng = lng else {
            return nil
        }
        return .init(latitude: lat, longitude: lng)
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
