import Foundation

class Group: BaseCustomField {
    
    var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    var desc: String?{
        get { return (super.getAttributeInstance("description") as! JSONableString?)?.string }
        set(description) { super.setStringAttribute(withName: "description", description) }
    }
    var location: Location?{
        get { return super.getAttributeInstance("location") as? Location }
        set(location) { super.setAttribute(withName: "location", location) }
    }
    var isApprovable: Bool?{
        get { return (super.getAttributeInstance("is_approvable") as! JSONableBool?)?.bool }
        set(isCancelled) { super.setBoolAttribute(withName: "is_approvable", isCancelled) }
    }
    var groupMemberAccessControl: MemberAccessControl?{
        get { if let c = (super.getAttributeInstance("group_member_access_control") as! JSONableString?)?.string { return MemberAccessControl(rawValue: c) } else { return nil } }
        set(groupMemberAccessControl) { super.setStringAttribute(withName: "group_member_access_control", groupMemberAccessControl?.rawValue) }
    }
    var members: [Member<GroupStatus>]?{
        get { return (super.getAttributeInstance("members") as! JSONableArray<Member<GroupStatus>>?)?.array }
        set(members) { super.setArrayAttribute(withName: "members", members) }
    }
    var memberCount: Int {
        get { if let t = totalMembers { return t } else if let m = members { return m.filter { $0.status == GroupStatus.Member }.count } else { return 0 } }
    }
    var totalMembers: Int? {
        get { return (super.getAttributeInstance("total_members") as! JSONableInt?)?.int }
        set(totalMembers) { super.setIntAttribute(withName: "total_members", totalMembers) }
    }
    var profilePhoto: Photo?{
        get { return super.getAttributeInstance("profile_photo") as? Photo }
        set(profilePhoto) { super.setAttribute(withName: "profile_photo", profilePhoto) }
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
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "name", "description", "group_member_access_control":
            return JSONableString().initAttributes
        case "distance_in_meters", "total_members":
            return JSONableInt().initAttributes
        case "members":
            return JSONableArray<Member<GroupStatus>>().initAttributes
        case "profile_photo", "profile_cover_photo":
            return Photo().initAttributes
        case "location":
            return Location().initAttributes
        case "is_member", "is_approvable":
            return JSONableBool().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
        
    }
    
    override func getDisplayedName() -> String? {
        return name
    }
}

