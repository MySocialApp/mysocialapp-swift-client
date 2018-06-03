import Foundation
import RxSwift

class SearchResultTypes: JSONable {
    
    var users: SearchResultValue<User>? {
        get { return super.getAttributeInstance("USER") as? SearchResultValue<User> }
        set(users) { super.setAttribute(withName: "USER", users) }
    }
    var feeds: SearchResultValue<Feed>? {
        get { return super.getAttributeInstance("FEED") as? SearchResultValue<Feed> }
        set(feeds) { super.setAttribute(withName: "FEED", feeds) }
    }
    var groups: SearchResultValue<Group>? {
        get { return super.getAttributeInstance("GROUP") as? SearchResultValue<Group> }
        set(groups) { super.setAttribute(withName: "GROUP", groups) }
    }
    var events: SearchResultValue<Event>? {
        get { return super.getAttributeInstance("EVENT") as? SearchResultValue<Event> }
        set(events) { super.setAttribute(withName: "EVENT", events) }
    }

    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "USER":
            return SearchResultValue<User>().initAttributes
        case "FEED":
            return SearchResultValue<Feed>().initAttributes
        case "GROUP":
            return SearchResultValue<Group>().initAttributes
        case "EVENT":
            return SearchResultValue<Event>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}

class SearchResultValue<T: JSONable>: JSONable {
    var matchedCount: Int64? {
        get { return (super.getAttributeInstance("matched_count") as! JSONableInt64?)?.int64 }
        set(matchedCount) { super.setInt64Attribute(withName: "matched_count", matchedCount) }
    }
    var data: [T]? {
        get { return (super.getAttributeInstance("data") as! JSONableArray<T>?)?.array }
        set(data) { super.setArrayAttribute(withName: "data", data) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "matched_count":
            return JSONableInt64().initAttributes
        case "data":
            return JSONableArray<T>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
}
