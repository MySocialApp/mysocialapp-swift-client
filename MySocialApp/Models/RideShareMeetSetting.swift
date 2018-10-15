import Foundation

public class RideShareMeetSetting: Base {
    public var active: Bool? {
        get { return (self.getAttributeInstance("active") as! JSONableBool).bool }
        set(active) { self.setBoolAttribute(withName: "active", active) }
    }
    public var maximumDistance: Int? {
        get { return (self.getAttributeInstance("maximum_distance") as! JSONableInt).int }
        set(maximumDistance) { self.setIntAttribute(withName: "maximum_distance", maximumDistance) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "active":
            return JSONableBool().initAttributes
        case "maximum_distance":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
