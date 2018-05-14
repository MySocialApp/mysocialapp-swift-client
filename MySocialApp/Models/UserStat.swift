import Foundation

class UserStat: Base {
    
    var status: Status? {
        get { return self.getAttributeInstance("status") as? Status }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "status":
            return Status().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }

    var createdRides: Int? { get {
        if let d = (self.getAttributeInstance("ride")?.getAttributeInstance("total_created", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }
    
    var totalFriends: Int? { get {
        if let d = (self.getAttributeInstance("friend")?.getAttributeInstance("total", withCreationMethod: JSONableDouble().initAttributes) as? JSONableDouble)?.double {
            return Int(d)
        }
        return nil
    } }

    class Status: Base {
        
        var lastConnectionDate: Date? {
            get { return (super.getAttributeInstance("last_connection_date") as! JSONableDate?)?.date }
            set(lastConnectionDate) { super.setDateAttribute(withName: "last_connection_date", lastConnectionDate) }
        }
        var state: State? {
            get { if let s = (super.getAttributeInstance("state") as! JSONableString?)?.string { return State(rawValue: s) } else { return nil } }
            set(state) { if let s = state { self.setStringAttribute(withName: "state", s.rawValue) } else { self.setStringAttribute(withName: "state", nil) } }
        }
        
        internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
            switch name {
            case "state":
                return JSONableString().initAttributes
            case "last_connection_date":
                return JSONableDate().initAttributes
            default:
                return super.getAttributeCreationMethod(name: name)
            }
        }
        
        enum State: String {
            case connected = "CONNECTED"
            case riding = "RIDING"
            case away = "AWAY"
            case unknown = "UNKNOWN"
            case notConnected = "NOT_CONNECTED"
            case disabled = "DISABLED"
        }
        enum Size: String {
            case normal = "NORMAL"
            case medium = "MEDIUM"
            case small = "SMALL"
        }
    }
}
