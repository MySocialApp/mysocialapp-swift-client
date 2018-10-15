import Foundation

public class FriendRequests: Base {
    public var outgoing: [User]?{
        get { return (super.getAttributeInstance("outgoing") as! JSONableArray<User>?)?.array }
        set(outgoing) { super.setArrayAttribute(withName: "outgoing", outgoing) }
    }
    public var incoming: [User]?{
        get { return (super.getAttributeInstance("incoming") as! JSONableArray<User>?)?.array }
        set(incoming) { super.setArrayAttribute(withName: "incoming", outgoing) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "outgoing", "incoming":
            return JSONableArray<User>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
