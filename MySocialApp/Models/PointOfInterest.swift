import Foundation
import CoreLocation
import MapKit

public class PointOfInterest: BaseCustomField {
    public override var idStr: String? {
        get { return (super.getAttributeInstance("id") as! JSONableString?)?.string }
        set(id) { super.setStringAttribute(withName: "id", id) }
    }
    public override var id: Int64? {
        get { if let i = self.idStr { return Int64(i) } else { return nil } }
        set(id) { if let i = id { self.idStr = "\(i)" } else { self.idStr = nil } }
    }
    public var title: String? {
        get { return (super.getAttributeInstance("title") as! JSONableString?)?.string }
        set(title) { super.setStringAttribute(withName: "title", title) }
    }
    public override var displayedName: String? {
        get { if let t = self.title { return t } else { return super.displayedName } }
        set(displayedName) {
            self.title = displayedName
            super.displayedName = displayedName
        }
    }
    public var note: String? {
        get { return (super.getAttributeInstance("note") as! JSONableString?)?.string }
        set(note) { super.setStringAttribute(withName: "note", note) }
    }
    public var photos: [Int64]? {
        get { return (super.getAttributeInstance("photos") as! JSONableArray<JSONableInt64>?)?.array.compactMap { $0.int64 } }
        set(photos) { super.setArrayAttribute(withName: "photos", photos?.map { JSONableInt64($0) }) }
    }
    public var userId: Int64? {
        get { return (super.getAttributeInstance("user_id") as! JSONableInt64?)?.int64 }
        set(userId) { super.setInt64Attribute(withName: "user_id", userId) }
    }
    public var location: Location? {
        get { return super.getAttributeInstance("location") as? Location }
        set(location) { super.setAttribute(withName: "location", location) }
    }
    public var flag: RideShareFlag? {
        get { if let f = (super.getAttributeInstance("flag") as! JSONableString?)?.string { return RideShareFlag(rawValue: f) } else { return nil } }
        set(flag) { if let f = flag { super.setStringAttribute(withName: "flag", f.rawValue) } else { super.setStringAttribute(withName: "flag", nil) } }
    }
    public var subtitle: String? {
        get { return self.note }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "id", "title", "note", "flag":
            return JSONableString().initAttributes
        case "created_date":
            return JSONableDate().initAttributes
        case "photos":
            return JSONableArray<JSONableInt64>().initAttributes
        case "user_id":
            return JSONableInt64().initAttributes
        case "location":
            return Location().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
