import Foundation

public class Comment: Base, Taggable {

    public var message: String?{
        get { return (super.getAttributeInstance("message") as! JSONableString?)?.string }
        set(message) { super.setStringAttribute(withName: "message", message) }
    }
    public var tagEntities: TagEntities?{
        get { return super.getAttributeInstance("tag_entities") as? TagEntities }
        set(tagEntities) { super.setAttribute(withName: "tag_entities", tagEntities) }
    }
    public var photo: Photo?{
        get { return super.getAttributeInstance("photo") as? Photo }
        set(photo) { super.setAttribute(withName: "photo", photo) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "message":
            return JSONableString().initAttributes
        case "tag_entities":
            return TagEntities().initAttributes
        case "photo":
            return Photo().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
