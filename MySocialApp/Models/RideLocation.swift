import Foundation

class RideLocation: Location {
    var position: Int? {
        get { return (super.getAttributeInstance("position") as! JSONableInt?)?.int }
        set(position) { super.setIntAttribute(withName: "position", position) }
    }
    var altitude: Double? {
        get { return (super.getAttributeInstance("altitude") as! JSONableDouble?)?.double }
        set(altitude) { super.setDoubleAttribute(withName: "altitude", altitude) }
    }
    var rideId: Int64? {
        get { return (super.getAttributeInstance("ride_id") as! JSONableInt64?)?.int64 }
        set(rideId) { super.setInt64Attribute(withName: "ride_id", rideId) }
    }
    var note: String? {
        get { return (super.getAttributeInstance("note") as! JSONableString?)?.string }
        set(note) { super.setStringAttribute(withName: "note", note) }
    }
    var locationType: RideLocationType? {
        get { if let t = (super.getAttributeInstance("location_type") as! JSONableString?)?.string { return RideLocationType(rawValue: t) } else { return nil } }
        set(locationType) { if let t = locationType { super.setStringAttribute(withName: "location_type", t.rawValue) } else { super.setStringAttribute(withName: "location_type", nil) } }
    }

    internal func safeToSend() -> RideLocation {
        let l = RideLocation()
        l.rideId = self.rideId
        l.locationType = self.locationType
        l.position = self.position
        l.latitude = self.latitude
        l.longitude = self.longitude
        l.altitude = self.altitude
        l.note = self.note
        return l
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "note", "location_type":
            return JSONableString().initAttributes
        case "ride_id":
            return JSONableInt64().initAttributes
        case "position":
            return JSONableInt().initAttributes
        case "altitude":
            return JSONableDouble().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
