import Foundation

class CommentBlob: JSONable {
    var total: Int? {
        get { return (super.getAttributeInstance("total") as! JSONableInt?)?.int }
        set(total) { super.setIntAttribute(withName: "total", total) }
    }
    var samples: [Comment]? {
        get { return (super.getAttributeInstance("samples") as! JSONableArray<Comment>?)?.array }
        set(samples) { super.setArrayAttribute(withName: "samples", samples) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "total":
            return JSONableInt().initAttributes
        case "samples":
            return JSONableArray<Comment>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}

