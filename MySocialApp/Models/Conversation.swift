import Foundation

class Conversation: Base {

    var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    var messages: ConversationMessages? {
        get { return super.getAttributeInstance("messages") as? ConversationMessages }
        set(messages) { super.setAttribute(withName: "messages", messages) }
    }
    var members: [User]? {
        get { return (self.getAttributeInstance("members") as! JSONableArray<User>?)?.array }
        set(members) { self.setArrayAttribute(withName: "members", members) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "name":
            return JSONableString().initAttributes
        case "messages":
            return ConversationMessages().initAttributes
        case "members":
            return JSONableArray<User>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
