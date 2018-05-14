import Foundation

class FriendRequest: Base {
    var outgoing: [User]?{
        get { return (super.getAttributeInstance("outgoing") as! JSONableArray<User>?)?.array }
        set(outgoing) { super.setArrayAttribute(withName: "outgoing", outgoing) }
    }
    var incoming: [User]?{
        get { return (super.getAttributeInstance("incoming") as! JSONableArray<User>?)?.array }
        set(incoming) { super.setArrayAttribute(withName: "incoming", outgoing) }
    }
    
    public override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "outgoing", "incoming":
            return JSONableArray<User>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
