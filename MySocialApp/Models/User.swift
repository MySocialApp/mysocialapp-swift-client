import Foundation
import RxSwift

class User: BaseCustomField {

    var firstName: String?{
        get { return (super.getAttributeInstance("first_name") as! JSONableString?)?.string }
        set(firstName) { super.setStringAttribute(withName: "first_name", firstName) }
    }
    var lastName: String?{
        get { return (super.getAttributeInstance("last_name") as! JSONableString?)?.string }
        set(lastName) { super.setStringAttribute(withName: "last_name", lastName) }
    }
    var fullName: String?{
        get { return (super.getAttributeInstance("full_name") as! JSONableString?)?.string }
        set(fullName) { super.setStringAttribute(withName: "full_name", fullName) }
    }
    var presentation: String?{
        get { return (super.getAttributeInstance("presentation") as! JSONableString?)?.string }
        set(presentation) { super.setStringAttribute(withName: "presentation", presentation) }
    }
    var dateOfBirth: Date?{
        get { return (super.getAttributeInstance("date_of_birth") as! JSONableDate?)?.date }
        set(dateOfBirth) { super.setDateAttribute(withName: "date_of_birth", dateOfBirth) }
    }
    var gender: Gender?{
        get { if let g = (super.getAttributeInstance("gender") as! JSONableString?)?.string { return Gender(rawValue: g) } else { return nil } }
        set(gender) { super.setStringAttribute(withName: "gender", gender?.rawValue) }
    }
    var username: String?{
        get { return (super.getAttributeInstance("username") as! JSONableString?)?.string }
        set(username) { super.setStringAttribute(withName: "username", username) }
    }
    var password: String?{
        get { return (super.getAttributeInstance("password") as! JSONableString?)?.string }
        set(password) { super.setStringAttribute(withName: "password", password) }
    }
    var profilePhoto: Photo?{
        get { return super.getAttributeInstance("profile_photo") as? Photo }
        set(profilePhoto) { super.setAttribute(withName: "profile_photo", profilePhoto) }
    }
    var profileCoverPhoto: Photo?{
        get { return super.getAttributeInstance("profile_cover_photo") as? Photo }
        set(profileCoverPhoto) { super.setAttribute(withName: "profile_cover_photo", profileCoverPhoto) }
    }
    var email: String?{
        get { return (super.getAttributeInstance("email") as! JSONableString?)?.string }
        set(email) { super.setStringAttribute(withName: "email", email) }
    }
    var currentStatus: Status?{
        get { return super.getAttributeInstance("current_status") as? Status }
        set(currentStatus) { super.setAttribute(withName: "current_status", currentStatus) }
    }
    var commonFriends: [User]?{
        get { return (super.getAttributeInstance("common_friends") as! JSONableArray<User>?)?.array }
        set(commonFriends) { super.setArrayAttribute(withName: "common_friends", commonFriends) }
    }
    var isFriend: Bool?{
        get { return (super.getAttributeInstance("is_friend") as! JSONableBool?)?.bool }
        set(isFriend) { super.setBoolAttribute(withName: "is_friend", isFriend) }
    }
    var isRequestedAsFriend: Bool?{
        get { return (super.getAttributeInstance("is_requested_as_friend") as! JSONableBool?)?.bool }
        set(isRequestedAsFriend) { super.setBoolAttribute(withName: "is_requested_as_friend", isRequestedAsFriend) }
    }
    var livingLocation: Location?{
        get { return super.getAttributeInstance("living_location") as? Location }
        set(livingLocation) { super.setAttribute(withName: "living_location", livingLocation) }
    }
    var distance: Int?{
        get { return (super.getAttributeInstance("distance") as! JSONableInt?)?.int }
        set(distance) { super.setIntAttribute(withName: "distance", distance) }
    }
    var flag: UserFlag?{
        get { return super.getAttributeInstance("flag") as? UserFlag }
        set(flag) { super.setAttribute(withName: "flag", flag) }
    }
    var userStat: UserStat? {
        get { return super.getAttributeInstance("user_stat") as? UserStat }
        set(userStat) { super.setAttribute(withName: "user_stat", userStat) }
    }
    var userSettings: UserSettings? {
        get { return super.getAttributeInstance("user_settings") as? UserSettings }
        set(userSettings) { super.setAttribute(withName: "user_settings", userSettings) }
    }
    var spokenLanguage: InterfaceLanguage? {
        get { if let z = (super.getAttributeInstance("spoken_language") as! JSONableString?)?.string { return InterfaceLanguage(rawValue: z) } else { return nil } }
        set(spokenLanguage) { super.setStringAttribute(withName: "spoken_language", spokenLanguage?.rawValue) }
    }
    var authorities: [String] {
        get { if let a = super.getAttributeInstance("authorities") as? JSONableArray<JSONableString> { return a.array.flatMap { $0.string } } else { return [] } }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "first_name", "last_name", "full_name", "presentation", "gender", "username", "password", "email", "spoken_language":
            return JSONableString().initAttributes
        case "date_of_birth":
            return JSONableDate().initAttributes
        case "profile_photo", "profile_cover_photo":
            return Photo().initAttributes
        case "current_status":
            return Status().initAttributes
        case "common_friends":
            return JSONableArray<User>().initAttributes
        case "is_friend", "is_requested_as_friend", "stat_status_active":
            return JSONableBool().initAttributes
        case "living_location":
            return Location().initAttributes
        case "distance":
            return JSONableInt().initAttributes
        case "flag":
            return UserFlag().initAttributes
        case "user_stat":
            return UserStat().initAttributes
        case "user_settings":
            return UserSettings().initAttributes
        case "authorities":
            return JSONableArray<JSONableString>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    override func getBodyImageURL() -> String? {
        return self.displayedPhoto?.getBodyImageURL()
    }
}
