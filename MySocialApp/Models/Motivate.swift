import Foundation

public class Motivate: JSONable {
    public var quantity: Int? {
        get { return (self.getAttributeInstance("quantity") as! JSONableInt?)?.int }
        set(quantity) { self.setIntAttribute(withName: "quantity", quantity) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "quantity":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
