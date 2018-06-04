import Foundation
import RxSwift

public class URLTag: TagEntity {

    public var originalURL: String?{
        get { return (super.getAttributeInstance("original_url") as! JSONableString?)?.string }
        set(originalURL) { super.setStringAttribute(withName: "original_url", originalURL) }
    }
    public var originalURLToDisplay: String?{
        get { return (super.getAttributeInstance("original_url_to_display") as! JSONableString?)?.string }
        set(originalURLToDisplay) { super.setStringAttribute(withName: "original_url_to_display", originalURLToDisplay) }
    }
    public var originalHostURL: String?{
        get { return (super.getAttributeInstance("original_host_url") as! JSONableString?)?.string }
        set(originalHostURL) { super.setStringAttribute(withName: "original_host_url", originalHostURL) }
    }
    public var shortURL: String?{
        get { return (super.getAttributeInstance("short_url") as! JSONableString?)?.string }
        set(shortURL) { super.setStringAttribute(withName: "short_url", shortURL) }
    }
    public var title: String?{
        get { return (super.getAttributeInstance("title") as! JSONableString?)?.string }
        set(title) { super.setStringAttribute(withName: "title", title) }
    }
    public var desc: String?{
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(description) { super.setStringAttribute(withName: "description", description) }
    }
    public var previewURL: String?{
        get { return (super.getAttributeInstance("preview_url") as! JSONableString?)?.string }
        set(previewURL) { super.setStringAttribute(withName: "preview_url", previewURL) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "original_url", "original_url_to_display", "original_host_url", "short_url", "title", "description", "preview_url":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }

    public override func getBodyImageURL() -> String? {
        return previewURL
    }
}
