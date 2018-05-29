import Foundation

class Event: BaseCustomField {

    var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    var desc: String?{
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(description) { super.setStringAttribute(withName: "description", description) }
    }
    var startDate: Date?{
        get { return (super.getAttributeInstance("start_date") as! JSONableDate?)?.date }
        set(startDate) { super.setDateAttribute(withName: "start_date", startDate) }
    }
    var endDate: Date?{
        get { return (super.getAttributeInstance("end_date") as! JSONableDate?)?.date }
        set(endDate) { super.setDateAttribute(withName: "end_date", endDate) }
    }
    var location: Location?{
        get { return super.getAttributeInstance("location") as? Location }
        set(location) { super.setAttribute(withName: "location", location) }
    }
    var staticMapsURL: String?{
        get { return (super.getAttributeInstance("static_maps_url") as! JSONableString?)?.string }
        set(staticMapsURL) { super.setStringAttribute(withName: "static_maps_url", staticMapsURL) }
    }
    var maxSeats: Int64?{
        get { return (super.getAttributeInstance("max_seats") as! JSONableInt64?)?.int64 }
        set(maxSeats) { super.setInt64Attribute(withName: "max_seats", maxSeats) }
    }
    var isCancelled: Bool?{
        get { return (super.getAttributeInstance("is_cancelled") as! JSONableBool?)?.bool }
        set(isCancelled) { super.setBoolAttribute(withName: "is_cancelled", isCancelled) }
    }
    var freeSeats: Int?{
        get { return (super.getAttributeInstance("free_seats") as! JSONableInt?)?.int }
        set(freeSeats) { super.setIntAttribute(withName: "free_seats", freeSeats) }
    }
    var eventMemberAccessControl: MemberAccessControl?{
        get { if let c = (super.getAttributeInstance("event_member_access_control") as! JSONableString?)?.string { return MemberAccessControl(rawValue: c) } else { return nil } }
        set(eventMemberAccessControl) { super.setStringAttribute(withName: "event_member_access_control", eventMemberAccessControl?.rawValue) }
    }
    var members: [Member<EventStatus>]?{
        get { return (super.getAttributeInstance("members") as! JSONableArray<Member<EventStatus>>?)?.array }
        set(members) { super.setArrayAttribute(withName: "members", members) }
    }
    var coverPhoto: Photo?{
        get { return super.getAttributeInstance("cover_photo") as? Photo }
        set(coverPhoto) { super.setAttribute(withName: "cover_photo", coverPhoto) }
    }
    var profileCoverPhoto: Photo?{
        get { return super.getAttributeInstance("profile_cover_photo") as? Photo }
        set(profileCoverPhoto) { super.setAttribute(withName: "profile_cover_photo", profileCoverPhoto) }
    }
    var isMember: Bool?{
        get { return (super.getAttributeInstance("is_member") as! JSONableBool?)?.bool }
        set(isMember) { super.setBoolAttribute(withName: "is_member", isMember) }
    }
    var distanceInMeters: Int?{
        get { return (super.getAttributeInstance("distance_in_meters") as! JSONableInt?)?.int }
        set(distanceInMeters) { super.setIntAttribute(withName: "distance_in_meters", distanceInMeters) }
    }
    var totalMembers: Int64?{
        get { return (super.getAttributeInstance("total_members") as! JSONableInt64?)?.int64 }
        set(totalMembers) { super.setInt64Attribute(withName: "total_members", totalMembers) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "name", "description", "static_maps_url", "event_member_access_control":
            return JSONableString().initAttributes
        case "max_seats", "total_members":
            return JSONableInt64().initAttributes
        case "distance_in_meters", "free_seats":
            return JSONableInt().initAttributes
        case "members":
            return JSONableArray<Member<EventStatus>>().initAttributes
        case "cover_photo", "profile_cover_photo":
            return Photo().initAttributes
        case "location":
            return Location().initAttributes
        case "is_member", "is_cancelled":
            return JSONableBool().initAttributes
        case "start_date", "end_date":
            return JSONableDate().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
        
    }

    override func getBodyImageURL() -> String? {
        return staticMapsURL
    }
}
