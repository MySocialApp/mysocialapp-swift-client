import Foundation

public class UserDistance: Base {
    public var userId: Int64? {
        get { return (super.getAttributeInstance("user_id") as! JSONableInt64?)?.int64 }
        set(userId) { super.setInt64Attribute(withName: "userId", userId) }
    }
    public var distance: Int64? {
        get { return (super.getAttributeInstance("distance") as! JSONableInt64?)?.int64 }
        set(distance) { super.setInt64Attribute(withName: "distance", distance) }
    }
    public var ranking: Int? {
        get { return (super.getAttributeInstance("ranking") as! JSONableInt?)?.int }
        set(ranking) { super.setIntAttribute(withName: "ranking", ranking) }
    }
    public var totalRanked: Int? {
        get { return (super.getAttributeInstance("total_ranked") as! JSONableInt?)?.int }
        set(totalRanked) { super.setIntAttribute(withName: "total_ranked", totalRanked) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "user_id", "distance":
            return JSONableInt64().initAttributes
        case "ranking", "total_ranked":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}

