import Foundation

class RideDirection: Base {
    var distanceInMeters: Int64? {
        get { return (super.getAttributeInstance("distance_in_meters") as! JSONableInt64?)?.int64 }
        set(distanceInMeters) { super.setInt64Attribute(withName: "distance_in_meters", distanceInMeters) }
    }
    var durationInSeconds: Int64? {
        get { return (super.getAttributeInstance("duration_in_seconds") as! JSONableInt64?)?.int64 }
        set(durationInSeconds) { super.setInt64Attribute(withName: "duration_in_seconds", durationInSeconds) }
    }
    var locations: JSONableArray<RideLocation>? {
        get { return self.getAttributeInstance("locations") as? JSONableArray<RideLocation> }
        set(locations) { self.setAttribute(withName: "locations", locations) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "distance_in_meters", "duration_in_seconds":
            return JSONableInt64().initAttributes
        case "locations":
            return JSONableArray<RideLocation>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
}
