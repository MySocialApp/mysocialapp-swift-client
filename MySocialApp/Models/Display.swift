import Foundation

class Display: Base {

    var originalURL: String?{
        get { return (super.getAttributeInstance("original_url") as! JSONableString?)?.string }
        set(originalURL) { super.setStringAttribute(withName: "original_url", originalURL) }
    }
    var originalURLToDisplay: String?{
        get { return (super.getAttributeInstance("original_url_to_display") as! JSONableString?)?.string }
        set(originalURLToDisplay) { super.setStringAttribute(withName: "original_url_to_display", originalURLToDisplay) }
    }
    var originalHostURL: String?{
        get { return (super.getAttributeInstance("original_host_url") as! JSONableString?)?.string }
        set(originalHostURL) { super.setStringAttribute(withName: "original_host_url", originalHostURL) }
    }
    var shortURL: String?{
        get { return (super.getAttributeInstance("short_url") as! JSONableString?)?.string }
        set(shortURL) { super.setStringAttribute(withName: "short_url", shortURL) }
    }
    var title: String?{
        get { return (super.getAttributeInstance("title") as! JSONableString?)?.string }
        set(title) { super.setStringAttribute(withName: "title", title) }
    }
    var desc: String?{
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(description) { super.setStringAttribute(withName: "description", description) }
    }
    var previewURL: String?{
        get { return (super.getAttributeInstance("preview_url") as! JSONableString?)?.string }
        set(previewURL) { super.setStringAttribute(withName: "preview_url", previewURL) }
    }
    var resourceId: String?{
        get { return (super.getAttributeInstance("resource_id") as! JSONableString?)?.string }
        set(resourceId) { super.setStringAttribute(withName: "resource_id", resourceId) }
    }
    var originalPrice: Float?{
        get { return (super.getAttributeInstance("original_price") as! JSONableFloat?)?.float }
        set(originalPrice) { super.setFloatAttribute(withName: "original_price", originalPrice) }
    }
    var discountPrice: Float?{
        get { return (super.getAttributeInstance("discount_price") as! JSONableFloat?)?.float }
        set(discountPrice) { super.setFloatAttribute(withName: "discount_price", discountPrice) }
    }
    var rate: Int?{
        get { return (super.getAttributeInstance("rate") as! JSONableInt?)?.int }
        set(rate) { super.setIntAttribute(withName: "rate", rate) }
    }
    var rateBase: Int?{
        get { return (super.getAttributeInstance("rate_base") as! JSONableInt?)?.int }
        set(rateBase) { super.setIntAttribute(withName: "rate_base", rateBase) }
    }
    var rateText: String?{
        get { return (super.getAttributeInstance("rate_text") as! JSONableString?)?.string }
        set(rateText) { super.setStringAttribute(withName: "rate_text", rateText) }
    }
 
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "title", "description", "original_url", "original_url_to_display", "original_host_url", "short_url", "preview_url", "resource_id", "rate_text":
            return JSONableString().initAttributes
        case "original_price", "discount_price":
            return JSONableFloat().initAttributes
        case "rate", "rate_base":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
