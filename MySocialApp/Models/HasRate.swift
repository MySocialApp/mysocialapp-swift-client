import Foundation

class HasRate: Base {
    override var owner: User? {
        get { return super.getAttributeInstance("from") as? User }
        set(owner) { super.setAttribute(withName: "from", owner) }
    }
    var to: Base? {
        get { return super.getAttributeInstance("to") as? Base }
        set(to) { super.setAttribute(withName: "to", to) }
    }
    var opinion: String? {
        get { return (super.getAttributeInstance("opinion") as! JSONableString?)?.string }
        set(opinion) { super.setStringAttribute(withName: "opinion", opinion) }
    }
    var rate: Int? {
        get { return (super.getAttributeInstance("rate") as! JSONableInt?)?.int }
        set(rate) { super.setIntAttribute(withName: "rate", rate) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "from":
            return User().initAttributes
        case "to":
            return Base().initAttributes
        case "opinion":
            return JSONableString().initAttributes
        case "rate":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
