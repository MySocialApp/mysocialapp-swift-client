import Foundation
import CoreLocation

class BaseLocation: Base {
    var latitude: Double? {
        get { return (super.getAttributeInstance("latitude") as! JSONableDouble?)?.double }
        set(latitude) { super.setDoubleAttribute(withName: "latitude", latitude) }
    }
    var longitude: Double? {
        get { return (super.getAttributeInstance("longitude") as! JSONableDouble?)?.double }
        set(longitude) { super.setDoubleAttribute(withName: "longitude", longitude) }
    }
    var accuracy: Float? {
        get { return (super.getAttributeInstance("accuracy") as! JSONableFloat?)?.float }
        set(accuracy) { super.setFloatAttribute(withName: "accuracy", accuracy) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "latitude", "longitude":
            return JSONableDouble().initAttributes
        case "accuracy":
            return JSONableFloat().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    func distance(from: BaseLocation) -> Double? {
        if let l1 = LocationUtils.fromLocation(self),
            let l2 = LocationUtils.fromLocation(from) {
            return l1.distance(from: l2)
        }
        return nil
    }
}
