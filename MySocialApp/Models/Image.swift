import Foundation

public class Image: JSONable {
    public var type: String? {
        get { return (super.getAttributeInstance("type") as! JSONableString?)?.string }
        set(type) { super.setStringAttribute(withName: "type", type) }
    }
    public var providedURL: String? {
        get { return (super.getAttributeInstance("provided_url") as! JSONableString?)?.string }
        set(providedURL) { super.setStringAttribute(withName: "provided_url", providedURL) }
    }
    public var small: String? {
        get { return (super.getAttributeInstance("small") as! JSONableString?)?.string }
        set(small) { super.setStringAttribute(withName: "small", small) }
    }
    public var medium: String? {
        get { return (super.getAttributeInstance("medium") as! JSONableString?)?.string }
        set(medium) { super.setStringAttribute(withName: "medium", medium) }
    }
    public var large: String? {
        get { return (super.getAttributeInstance("large") as! JSONableString?)?.string }
        set(large) { super.setStringAttribute(withName: "large", large) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "type", "provided_url", "small", "large":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
