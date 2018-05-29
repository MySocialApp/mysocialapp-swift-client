import Foundation

class Badge: JSONable {
    var type: String? {
        get { return (super.getAttributeInstance("type") as! JSONableString?)?.string }
        set(type) { super.setStringAttribute(withName: "type", type) }
    }
    var colorHex: String? {
        get { return (super.getAttributeInstance("color_hex") as! JSONableString?)?.string }
        set(colorHex) { super.setStringAttribute(withName: "color_hex", colorHex) }
    }
    var text: String? {
        get { return (super.getAttributeInstance("text") as! JSONableString?)?.string }
        set(text) { super.setStringAttribute(withName: "text", text) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "type", "color_hex", "text":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
