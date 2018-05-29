import Foundation

class HasRide: Base {
    override var owner: User? {
        get { return super.getAttributeInstance("from") as? User }
        set(owner) { super.setAttribute(withName: "from", owner) }
    }
    var to: Ride? {
        get { return super.getAttributeInstance("to") as? Ride }
        set(to) { super.setAttribute(withName: "to", to) }
    }
    var rideDate: Date? {
        get { return (super.getAttributeInstance("ride_date") as! JSONableDate?)?.date }
        set(rideDate) { super.setDateAttribute(withName: "ride_date", rideDate) }
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
            return Ride().initAttributes
        case "date":
            return JSONableDate().initAttributes
        case "opinion":
            return JSONableString().initAttributes
        case "rate":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
