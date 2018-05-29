import Foundation

class ConversationMessages: JSONable {
    var totalUnreads: Int?{
        get { return (super.getAttributeInstance("total_unreads") as! JSONableInt?)?.int }
        set(totalUnreads) { super.setIntAttribute(withName: "total_unreads", totalUnreads) }
    }
    var samples: [ConversationMessage]? {
        get { return (super.getAttributeInstance("samples") as! JSONableArray<ConversationMessage>?)?.array }
        set(samples) { super.setArrayAttribute(withName: "samples", samples) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "total_unreads":
            return JSONableInt().initAttributes
        case "samples":
            return JSONableArray<ConversationMessage>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
