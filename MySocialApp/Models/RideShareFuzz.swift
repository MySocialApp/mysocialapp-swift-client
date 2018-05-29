import Foundation

class RideShareFuzz: Base {
    var radiusDistance: Int64? {
        get { return (super.getAttributeInstance("radius_distance") as! JSONableInt64?)?.int64 }
        set(radiusDistance) { super.setInt64Attribute(withName: "radius_distance", radiusDistance) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "radius_distance":
            return JSONableInt64().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
