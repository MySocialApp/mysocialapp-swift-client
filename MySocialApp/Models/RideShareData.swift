import Foundation

class RideShareData: Base {
    var timestamp: Int64? {
        get { return (super.getAttributeInstance("timestamp") as! JSONableInt64?)?.int64 }
        set(timestamp) { super.setInt64Attribute(withName: "timestamp", timestamp) }
    }
    var rideId: String? {
        get { return (super.getAttributeInstance("ride_id") as! JSONableString?)?.string }
        set(rideId) { super.setStringAttribute(withName: "ride_id", rideId) }
    }
    var latitude: Double? {
        get { return (super.getAttributeInstance("latitude") as! JSONableDouble?)?.double }
        set(latitude) { super.setDoubleAttribute(withName: "latitude", latitude) }
    }
    var longitude: Double? {
        get { return (super.getAttributeInstance("longitude") as! JSONableDouble?)?.double }
        set(longitude) { super.setDoubleAttribute(withName: "longitude", longitude) }
    }
    var altitude: Double? {
        get { return (super.getAttributeInstance("altitude") as! JSONableDouble?)?.double }
        set(altitude) { super.setDoubleAttribute(withName: "altitude", altitude) }
    }
    var accuracy: Float? {
        get { return (super.getAttributeInstance("accuracy") as! JSONableFloat?)?.float }
        set(accuracy) { super.setFloatAttribute(withName: "accuracy", accuracy) }
    }
    var moving: Bool? {
        get { return (super.getAttributeInstance("moving") as! JSONableBool?)?.bool }
        set(moving) { super.setBoolAttribute(withName: "moving", moving) }
    }
    var batteryLevel: Int? {
        get { return (super.getAttributeInstance("battery_level") as! JSONableInt?)?.int }
        set(batteryLevel) { super.setIntAttribute(withName: "battery_level", batteryLevel) }
    }
    var flag: RideShareFlag? {
        get { if let f = (super.getAttributeInstance("flag") as? JSONableString)?.string { return RideShareFlag(rawValue: f) } else { return nil } }
        set(flag) { if let f = flag { super.setStringAttribute(withName: "flag", f.rawValue) } else { super.setStringAttribute(withName: "flag", nil) } }
    }
    
    convenience init(_ timestamp: Int64?, _ rideId: String?, _ latitude: Double?, _ longitude: Double?, _ altitude: Double?, _ accuracy: Float?, _ moving: Bool?, _ batteryLevel: Int?, _ flag: RideShareFlag?) {
        self.init()
        self.timestamp = timestamp
        self.rideId = rideId
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.accuracy = accuracy
        self.moving = moving
        self.batteryLevel = batteryLevel
        self.flag = flag
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "timestamp":
            return JSONableInt64().initAttributes
        case "ride_id", "flag":
            return JSONableString().initAttributes
        case "latitude", "longitude", "altitude":
            return JSONableDouble().initAttributes
        case "accuracy":
            return JSONableFloat().initAttributes
        case "moving":
            return JSONableBool().initAttributes
        case "battery_level":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
