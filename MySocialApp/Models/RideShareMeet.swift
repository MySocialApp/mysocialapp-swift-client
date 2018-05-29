import Foundation
import MapKit

class RideShareMeet: Base, MKAnnotation {
    var title: String? { get { return self.owner?.displayedName } }
    var coordinate: CLLocationCoordinate2D {
        get {
            if let lat = self.location?.latitude, let lng = self.location?.longitude {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
            return CLLocationCoordinate2D()
        }
    }
    var date: Date? { get { return (self.getAttributeInstance("date") as! JSONableDate?)?.date } }
    var userId: Int64? { get { return (self.getAttributeInstance("user_id") as! JSONableInt64?)?.int64 } }
    var distance: Double? { get { return (self.getAttributeInstance("distance") as! JSONableDouble?)?.double } }
    var location: Location? { get { return self.getAttributeInstance("location") as? Location } }
    var new: Bool? { get { return (self.getAttributeInstance("new") as! JSONableBool?)?.bool } }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "date":
            return JSONableDate().initAttributes
        case "user_id":
            return JSONableInt64().initAttributes
        case "distance":
            return JSONableDouble().initAttributes
        case "location":
            return Location().initAttributes
        case "new":
            return JSONableBool().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
