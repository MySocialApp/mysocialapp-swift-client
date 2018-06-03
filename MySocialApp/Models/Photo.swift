import Foundation

class Photo: Base, Taggable {

    var message: String?{
        get { return (super.getAttributeInstance("message") as! JSONableString?)?.string }
        set(message) { super.setStringAttribute(withName: "message", message) }
    }
    var url: String?{
        get { return (super.getAttributeInstance("url") as! JSONableString?)?.string }
        set(url) { super.setStringAttribute(withName: "url", url) }
    }
    var smallURL: String?{
        get { return (super.getAttributeInstance("small_url") as! JSONableString?)?.string }
        set(smallURL) { super.setStringAttribute(withName: "small_url", smallURL) }
    }
    var mediumURL: String?{
        get { return (super.getAttributeInstance("medium_url") as! JSONableString?)?.string }
        set(mediumURL) { super.setStringAttribute(withName: "medium_url", mediumURL) }
    }
    var highURL: String?{
        get { return (super.getAttributeInstance("high_url") as! JSONableString?)?.string }
        set(highURL) { super.setStringAttribute(withName: "high_url", highURL) }
    }
    var target: Base?{
        get { return super.getAttributeInstance("target") as? Base }
        set(target) { super.setAttribute(withName: "target", target) }
    }
    var tagEntities: TagEntities?{
        get { return super.getAttributeInstance("tag_entities") as? TagEntities }
        set(tagEntities) { super.setAttribute(withName: "tag_entities", tagEntities) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "message", "url", "small_url", "medium_url", "high_url":
            return JSONableString().initAttributes
        case "target":
            return Base().initAttributes
        case "tag_entities":
            return TagEntities().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
