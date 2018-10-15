import Foundation

public class RideIdGenerator: Base {
    public var rideId: String? {
        get { return (super.getAttributeInstance("id") as! JSONableString?)?.string }
        set(rideId) { super.setStringAttribute(withName: "id", rideId) }
    }
    public var url: String? {
        get { return (super.getAttributeInstance("url") as! JSONableString?)?.string }
        set(url) { super.setStringAttribute(withName: "url", url) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "id", "url":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
