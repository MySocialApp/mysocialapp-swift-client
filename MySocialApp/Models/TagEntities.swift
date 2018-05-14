import Foundation

class TagEntities: JSONable {
    var userMentionTags: [UserMentionTag]? {
        get { return (super.getAttributeInstance("user_mention_tags") as! JSONableArray<UserMentionTag>?)?.array }
        set(userMentionTags) { super.setArrayAttribute(withName: "user_mention_tags", userMentionTags) }
    }
    var urlTags: [URLTag]? {
        get { return (super.getAttributeInstance("url_tags") as! JSONableArray<URLTag>?)?.array }
        set(urlTags) { super.setArrayAttribute(withName: "url_tags", urlTags) }
    }
    var hashTags: [HashTag]? {
        get { return (super.getAttributeInstance("hash_tags") as! JSONableArray<HashTag>?)?.array }
        set(hashTags) { super.setArrayAttribute(withName: "hash_tags", hashTags) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "user_mention_tags":
            return JSONableArray<UserMentionTag>().initAttributes
        case "url_tags":
            return JSONableArray<URLTag>().initAttributes
        case "hash_tags":
            return JSONableArray<HashTag>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    func allTags() -> [TagEntity] {
        var t: [TagEntity] = []
        let _ = self.userMentionTags?.map { t.append($0) }
        let _ = self.urlTags?.map { t.append($0) }
        let _ = self.hashTags?.map { t.append($0) }
        return t
    }
}
