import Foundation
import CoreLocation

public class Location: BaseLocation {
    
    public var location: BaseLocation? {
        get { return super.getAttributeInstance("location") as? BaseLocation }
        set(location) { super.setAttribute(withName: "location", location) }
    }

    public override var latitude: Double? {
        get { if let l = location?.latitude { return l } else { return super.latitude } }
        set(latitude) { if let l = location {
                l.latitude = latitude
                location = l
            }
            super.latitude = latitude
        }
    }
    public override var longitude: Double? {
        get { if let l = location?.longitude { return l } else { return super.longitude } }
        set(longitude) { if let l = location {
                l.longitude = longitude
                location = l
            }
            super.longitude = longitude
        }
    }
    public override var accuracy: Float? {
        get { if let l = location?.accuracy { return l } else { return super.accuracy } }
        set(accuracy) { if let l = location {
                l.accuracy = accuracy
                location = l
            }
            super.accuracy = accuracy
        }
    }
    
    public var country: String?{
        get { return (super.getAttributeInstance("country") as! JSONableString?)?.string }
        set(country) { super.setStringAttribute(withName: "country", country) }
    }
    public var district: String?{
        get { return (super.getAttributeInstance("district") as! JSONableString?)?.string }
        set(district) { super.setStringAttribute(withName: "district", district) }
    }
    public var state: String?{
        get { return (super.getAttributeInstance("state") as! JSONableString?)?.string }
        set(state) { super.setStringAttribute(withName: "state", state) }
    }
    public var postalCode: String?{
        get { return (super.getAttributeInstance("postal_code") as! JSONableString?)?.string }
        set(postalCode) { super.setStringAttribute(withName: "postal_code", postalCode) }
    }
    public var city: String?{
        get { return (super.getAttributeInstance("city") as! JSONableString?)?.string }
        set(city) { super.setStringAttribute(withName: "city", city) }
    }
    public var streetName: String?{
        get { return (super.getAttributeInstance("street_name") as! JSONableString?)?.string }
        set(streetName) { super.setStringAttribute(withName: "street_name", streetName) }
    }
    public var streetNumber: String?{
        get { return (super.getAttributeInstance("street_number") as! JSONableString?)?.string }
        set(streetNumber) { super.setStringAttribute(withName: "street_number", streetNumber) }
    }
    public var completeAddress: String?{
        get { return (super.getAttributeInstance("complete_address") as! JSONableString?)?.string }
        set(completeAddress) { super.setStringAttribute(withName: "complete_address", completeAddress) }
    }
    public var completeCityAddress: String?{
        get { return (super.getAttributeInstance("complete_city_address") as! JSONableString?)?.string }
        set(completeCityAddress) { super.setStringAttribute(withName: "complete_city_address", completeCityAddress) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "location":
            return BaseLocation().initAttributes
        case "country", "district", "state", "postal_code", "city", "street_name", "street_number", "complete_address", "complete_city_address":
            return JSONableString().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
