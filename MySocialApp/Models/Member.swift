import Foundation

public class Member<T: RawRepresentable where T.RawValue == String>: JSONable {
    public var createdDate: Date? {
        get { return (super.getAttributeInstance("created_date") as! JSONableDate?)?.date }
        set(createdDate) { super.setDateAttribute(withName: "created_date", createdDate) }
    }
    public var updatedDate: Date? {
        get { return (super.getAttributeInstance("updated_date") as! JSONableDate?)?.date }
        set(updatedDate) { super.setDateAttribute(withName: "updated_date", updatedDate) }
    }
    public var event: Event? {
        get { return super.getAttributeInstance("event") as? Event }
        set(event) { super.setAttribute(withName: "event", event) }
    }
    public var group: Group? {
        get { return super.getAttributeInstance("group") as? Group }
        set(group) { super.setAttribute(withName: "group", group) }
    }
    public var user: User? {
        get { return super.getAttributeInstance("user") as? User }
        set(user) { super.setAttribute(withName: "user", user) }
    }
    public var status: T? {
        get { if let s = (super.getAttributeInstance("status") as! JSONableString?)?.string { return T(rawValue: s) } else { return nil } }
        set(status) { super.setStringAttribute(withName: "status", status?.rawValue) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "created_date", "updated_date":
            return JSONableDate().initAttributes
        case "event":
            return Event().initAttributes
        case "group":
            return Group().initAttributes
        case "user":
            return User().initAttributes
        case "status":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
