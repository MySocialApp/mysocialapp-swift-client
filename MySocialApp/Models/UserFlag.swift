import Foundation

public class UserFlag: Base {
    public var imageUrl: String?{
        get { return (super.getAttributeInstance("image_url") as! JSONableString?)?.string }
        set(imageUrl) { super.setStringAttribute(withName: "image_url", imageUrl) }
    }

    public var text: String?{
        get { return (super.getAttributeInstance("text") as! JSONableString?)?.string }
        set(text) { super.setStringAttribute(withName: "text", text) }
    }
    
    public var link: String?{
        get { return (super.getAttributeInstance("link") as! JSONableString?)?.string }
        set(link) { super.setStringAttribute(withName: "link", link) }
    }
    
    public var linkText: String?{
        get { return (super.getAttributeInstance("link_text") as! JSONableString?)?.string }
        set(linkText) { super.setStringAttribute(withName: "link_text", linkText) }
    }
    
    public var desc: String?{
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(desc) { super.setStringAttribute(withName: "description", desc) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "image_url", "text", "link", "link_text", "description":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
