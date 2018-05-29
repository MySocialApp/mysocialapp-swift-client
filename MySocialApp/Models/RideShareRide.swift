import Foundation

class RideShareRide: Base {
    
    var rideId: String? {
        get { return (self.getAttributeInstance("ride_id") as! JSONableString).string }
        set(rideId) { self.setStringAttribute(withName: "ride_id", rideId) }
    }
    var lastUpdate: Date? {
        get { return (self.getAttributeInstance("last_update") as! JSONableDate).date }
        set(lastUpdate) { self.setDateAttribute(withName: "last_update", lastUpdate) }
    }
    var userId: Int64? {
        get { return (self.getAttributeInstance("user_id") as! JSONableInt64).int64 }
        set(userId) { self.setInt64Attribute(withName: "user_id", userId) }
    }
    var deviceId: String? {
        get { return (self.getAttributeInstance("device_id") as! JSONableString).string }
        set(deviceId) { self.setStringAttribute(withName: "device_id", deviceId) }
    }
    var name: String? {
        get { return (self.getAttributeInstance("name") as! JSONableString).string }
        set(name) { self.setStringAttribute(withName: "name", name) }
    }
    var favorite: Bool? {
        get { return (self.getAttributeInstance("favorite") as! JSONableBool).bool }
        set(favorite) { self.setBoolAttribute(withName: "favorite", favorite) }
    }
    var distance: Int? {
        get { return (self.getAttributeInstance("distance") as! JSONableInt).int }
        set(distance) { self.setIntAttribute(withName: "distance", distance) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "ride_id", "device_id", "name":
            return JSONableString().initAttributes
        case "favorite":
            return JSONableBool().initAttributes
        case "last_update":
            return JSONableDate().initAttributes
        case "user_id":
            return JSONableInt64().initAttributes
        case "distance":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    var track: Track? {
        get { return Track.encode(deviceId: deviceId, userId: userId, rideId: rideId) }
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let r = object as? RideShareRide, let thisId = self.rideId, let thatId = r.rideId {
            return thisId == thatId
        }
        return super.isEqual(object)
    }
}
