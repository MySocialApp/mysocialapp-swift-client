import Foundation

class LikeBlob: JSONable {
    var total: Int? {
        get { return (super.getAttributeInstance("total") as! JSONableInt?)?.int }
        set(total) { super.setIntAttribute(withName: "total", total) }
    }
    var hasLike: Bool? {
        get { return (super.getAttributeInstance("has_like") as! JSONableBool?)?.bool }
        set(hasLike) { super.setBoolAttribute(withName: "has_like", hasLike) }
    }
    var samples: [Like]? {
        get { return (super.getAttributeInstance("samples") as! JSONableArray<Like>?)?.array }
        set(samples) { super.setArrayAttribute(withName: "samples", samples) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "total":
            return JSONableInt().initAttributes
        case "has_like":
            return JSONableBool().initAttributes
        case "samples":
            return JSONableArray<Like>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
