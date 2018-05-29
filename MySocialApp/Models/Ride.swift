import Foundation
import RxSwift

class Ride: BaseCustomField {

    var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    var desc: String?{
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(description) { super.setStringAttribute(withName: "description", description) }
    }
    var rideEstimatedTime: Int64?{
        get { return (super.getAttributeInstance("estimated_ride_time") as! JSONableInt64?)?.int64 }
        set(rideEstimatedTime) { super.setInt64Attribute(withName: "estimated_ride_time", rideEstimatedTime) }
    }
    var staticMapsURL: String?{
        get { return (super.getAttributeInstance("static_maps_url") as! JSONableString?)?.string }
        set(staticMapsURL) { super.setStringAttribute(withName: "static_maps_url", staticMapsURL) }
    }
    var totalDistance: Int64?{
        get { return (super.getAttributeInstance("total_distance") as! JSONableInt64?)?.int64 }
        set(totalDistance) { super.setInt64Attribute(withName: "total_distance", totalDistance) }
    }
    var users: [User]?{
        get { return (super.getAttributeInstance("users") as! JSONableArray<User>?)?.array }
        set(users) { super.setArrayAttribute(withName: "users", users) }
    }
    var locations: [RideLocation]?{
        get { return (super.getAttributeInstance("locations") as! JSONableArray<RideLocation>?)?.array }
        set(locations) { super.setArrayAttribute(withName: "locations", locations) }
    }
    var startLocation: Location?{
        get { return super.getAttributeInstance("start_location") as? Location }
        set(startLocation) { super.setAttribute(withName: "start_location", startLocation) }
    }
    var endLocation: Location?{
        get { return super.getAttributeInstance("end_location") as? Location }
        set(endLocation) { super.setAttribute(withName: "end_location", endLocation) }
    }
    var hasRide: Bool?{
        get { return (super.getAttributeInstance("has_ride") as! JSONableBool?)?.bool }
        set(hasRide) { super.setBoolAttribute(withName: "has_ride", hasRide) }
    }
    var rideType: RideType? {
        get { if let t = (super.getAttributeInstance("ride_type") as! JSONableString?)?.string { return RideType(rawValue: t) } else { return nil } }
        set { super.setStringAttribute(withName: "ride_type", newValue?.rawValue) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "name", "description", "static_maps_url", "ride_type":
            return JSONableString().initAttributes
        case "total_distance", "estimated_ride_time":
            return JSONableInt64().initAttributes
        case "users":
            return JSONableArray<User>().initAttributes
        case "locations":
            return JSONableArray<RideLocation>().initAttributes
        case "start_location", "end_location":
            return Location().initAttributes
        case "has_ride":
            return JSONableBool().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    override func getBodyImageURL() -> String? {
        return self.staticMapsURL
    }
}
