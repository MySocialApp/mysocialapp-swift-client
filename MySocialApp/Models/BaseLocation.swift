import Foundation

public class BaseLocation: Base {
    public var latitude: Double? {
        get { return (super.getAttributeInstance("latitude") as! JSONableDouble?)?.double }
        set(latitude) { super.setDoubleAttribute(withName: "latitude", latitude) }
    }
    public var longitude: Double? {
        get { return (super.getAttributeInstance("longitude") as! JSONableDouble?)?.double }
        set(longitude) { super.setDoubleAttribute(withName: "longitude", longitude) }
    }
    public var accuracy: Float? {
        get { return (super.getAttributeInstance("accuracy") as! JSONableFloat?)?.float }
        set(accuracy) { super.setFloatAttribute(withName: "accuracy", accuracy) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "latitude", "longitude":
            return JSONableDouble().initAttributes
        case "accuracy":
            return JSONableFloat().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public convenience init(latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public func distance(from: BaseLocation) -> Double? {
        if let l1 = LocationUtils.fromLocation(self),
            let l2 = LocationUtils.fromLocation(from) {
            return l1.distance(from: l2)
        }
        return nil
    }
}
