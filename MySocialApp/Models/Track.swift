import Foundation

class Track: Base {
    var deviceId: String? {
        get { return (super.getAttributeInstance("device_id") as! JSONableString?)?.string }
        set(deviceId) { super.setStringAttribute(withName: "device_id", deviceId) }
    }
    var userId: Int64? {
        get { return (super.getAttributeInstance("user_id") as! JSONableInt64?)?.int64 }
        set(userId) { super.setInt64Attribute(withName: "user_id", userId) }
    }
    var rideId: String? {
        get { return (super.getAttributeInstance("ride_id") as! JSONableString?)?.string }
        set(rideId) { super.setStringAttribute(withName: "ride_id", rideId) }
    }

    static func decode(fromTrackingId id: String?) -> Track? {
        if let ids = id?.components(separatedBy: "-"), ids.count >= 3, let u = Int64(ids[1]) {
            return Track(ids[0], u, ids[2])
        }
        return nil
    }
    
    static func decode(fromTrackingURL url: String?) -> Track? {
        if let u = url {
            let c = u.components(separatedBy: "/")
            if c.count > 1 {
                return Track.decode(fromTrackingId: c.last)
            }
        }
        return nil
    }
    
    static func encode(deviceId: String?, userId: Int64?, rideId: String?) -> Track? {
        if let d = deviceId, let u = userId, let r = rideId {
            return Track(d,u,r)
        }
        return nil
    }
    
    convenience init(_ deviceId: String, _ userId: Int64, _ rideId: String) {
        self.init()
        self.deviceId = deviceId
        self.userId = userId
        self.rideId = rideId
    }
    
    var trackingId: String {
        get {
            if let d = self.deviceId, let u = self.userId, let r = self.rideId {
                return "\(d)-\(u)-\(r)"
            }
            return ""
        }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "device_id", "ride_id":
            return JSONableString().initAttributes
        case "user_id":
            return JSONableInt64().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
