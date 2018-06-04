import Foundation

public class UserStatStatus: Base {
    
    public var lastConnectionDate: Date? {
        get { return (super.getAttributeInstance("last_connection_date") as! JSONableDate?)?.date }
        set(lastConnectionDate) { super.setDateAttribute(withName: "last_connection_date", lastConnectionDate) }
    }
    public var state: State? {
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

    public enum State: String {
        case connected = "CONNECTED"
        case riding = "RIDING"
        case away = "AWAY"
        case unknown = "UNKNOWN"
        case notConnected = "NOT_CONNECTED"
        case disabled = "DISABLED"
    }
}
