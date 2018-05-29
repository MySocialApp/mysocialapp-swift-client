import Foundation

class Member<T: RawRepresentable where T.RawValue == String>: JSONable {
    var createdDate: Date? {
        get { return (super.getAttributeInstance("created_date") as! JSONableDate?)?.date }
        set(createdDate) { super.setDateAttribute(withName: "created_date", createdDate) }
    }
    var updatedDate: Date? {
        get { return (super.getAttributeInstance("updated_date") as! JSONableDate?)?.date }
        set(updatedDate) { super.setDateAttribute(withName: "updated_date", updatedDate) }
    }
    var event: Event? {
        get { return super.getAttributeInstance("event") as? Event }
        set(event) { super.setAttribute(withName: "event", event) }
    }
    var user: User? {
        get { return super.getAttributeInstance("user") as? User }
        set(user) { super.setAttribute(withName: "user", user) }
    }
    var status: T? {
        get { if let s = (super.getAttributeInstance("status") as! JSONableString?)?.string { return T(rawValue: s) } else { return nil } }
        set(status) { super.setStringAttribute(withName: "status", status?.rawValue) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "created_date", "updated_date":
            return JSONableDate().initAttributes
        case "event":
            return Event().initAttributes
        case "user":
            return User().initAttributes
        case "status":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
