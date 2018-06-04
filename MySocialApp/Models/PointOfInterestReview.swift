import Foundation

class PointOfInterestReview: Comment {
    public override var idStr: String? {
        get { return (super.getAttributeInstance("id") as! JSONableString?)?.string }
        set(idStr) { super.setStringAttribute(withName: "id", idStr) }
    }
    public override var id: Int64? {
        get { return nil }
        set(id) { }
    }
    public var parentId: String? {
        get { return (super.getAttributeInstance("parent_id") as! JSONableString?)?.string }
        set(parentId) { super.setStringAttribute(withName: "parent_id", parentId) }
    }
    public var userId: Int64? {
        get { return (super.getAttributeInstance("user_id") as! JSONableInt64?)?.int64 }
        set(userId) { super.setInt64Attribute(withName: "user_id", userId) }
    }
    public var rate: Int? {
        get { return (super.getAttributeInstance("rate") as! JSONableInt?)?.int }
        set(rate) { super.setIntAttribute(withName: "rate", rate) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "id", "parent_id":
            return JSONableString().initAttributes
        case "user_id":
            return JSONableInt64().initAttributes
        case "rate":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
