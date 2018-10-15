import Foundation

public class ConversationMessage: Base {
    public var message: String? {
        get { return (super.getAttributeInstance("message") as! JSONableString?)?.string }
        set(message) { super.setStringAttribute(withName: "message", message) }
    }
    public var photo: Photo?{
        get { return super.getAttributeInstance("photo") as? Photo }
        set(photo) { super.setAttribute(withName: "photo", photo) }
    }
    public var tagEntities: TagEntities?{
        get { return super.getAttributeInstance("tag_entities") as? TagEntities }
        set(tagEntities) { super.setAttribute(withName: "tag_entities", tagEntities) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "message":
            return JSONableString().initAttributes
        case "photo":
            return Photo().initAttributes
        case "tag_entities":
            return TagEntities().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
