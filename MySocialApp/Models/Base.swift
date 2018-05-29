import Foundation

class Base: JSONable {
    
    var id: Int64? {
        get { return (super.getAttributeInstance("id") as! JSONableInt64?)?.int64 }
        set(id) { super.setInt64Attribute(withName: "id", id) }
    }
    var idStr: String? {
        get { return (super.getAttributeInstance("id_str") as! JSONableString?)?.string }
        set(idStr) { super.setStringAttribute(withName: "id_str", idStr) }
    }
    var type: String? {
        get { return (super.getAttributeInstance("type") as! JSONableString?)?.string }
        set(type) { super.setStringAttribute(withName: "type", type) }
    }
    var createdDate: Date? {
        get { return (super.getAttributeInstance("created_date") as! JSONableDate?)?.date }
        set(date) { super.setDateAttribute(withName: "created_date", date) }
    }
    var updatedDate: Date? {
        get { return (super.getAttributeInstance("updated_date") as! JSONableDate?)?.date }
        set(updatedDate) { super.setDateAttribute(withName: "updated_date", updatedDate) }
    }
    var displayedName: String? {
        get { return (super.getAttributeInstance("displayed_name") as! JSONableString?)?.string }
        set(displayedName) { super.setStringAttribute(withName: "displayed_name", displayedName) }
    }
    var displayedPhoto: Photo? {
        get { return super.getAttributeInstance("displayed_photo") as? Photo }
        set(displayedPhoto) { super.setAttribute(withName: "displayed_photo", displayedPhoto) }
    }
    var entityType: EntityType? {
        get { if let t = (super.getAttributeInstance("entity_type") as! JSONableString?)?.string { return EntityType(rawValue: t) } else { return nil } }
        set(entityType) { if let t = entityType { super.setStringAttribute(withName: "entity_type", t.rawValue) } else { super.setStringAttribute(withName: "entity_type", nil) } }
    }
    var accessControl: AccessControl? {
        get { if let t = (super.getAttributeInstance("access_control") as! JSONableString?)?.string { return AccessControl(rawValue: t) } else { return nil } }
        set(accessControl) { if let t = accessControl { super.setStringAttribute(withName: "access_control", t.rawValue) } else { super.setStringAttribute(withName: "access_control", nil) } }
    }
    var owner: User? {
        get { return super.getAttributeInstance("owner") as? User }
        set(owner) { super.setAttribute(withName: "owner", owner) }
    }
    var bodyMessage: String? {
        get { return (super.getAttributeInstance("body_message") as! JSONableString?)?.string }
        set(bodyMessage) { super.setStringAttribute(withName: "body_message", bodyMessage) }
    }
    var bodyImageURL: String? {
        get { return (super.getAttributeInstance("body_image_url") as! JSONableString?)?.string }
        set(bodyImageURL) { super.setStringAttribute(withName: "body_image_url", bodyImageURL) }
    }
    var bodyImageText: String? {
        get { return (super.getAttributeInstance("body_image_text") as! JSONableString?)?.string }
        set(bodyImageText) { super.setStringAttribute(withName: "body_image_text", bodyImageText) }
    }
    var likes: LikeBlob?{
        get { return self.getAttributeInstance("likes") as? LikeBlob }
        set(likes) { self.setAttribute(withName: "likes", likes) }
    }
    var comments: CommentBlob?{
        get { return self.getAttributeInstance("comments") as? CommentBlob }
        set(comments) { self.setAttribute(withName: "comments", comments) }
    }
    var isLiked: Bool?{
        get { if let l = self.likes?.hasLike { return l } else { return false } }
        set(isLiked) {
            if let l = self.likes {
                l.hasLike = isLiked
                self.likes = l
            }
        }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "owner":
            return User().initAttributes
        case "type", "id_str", "displayed_name", "entity_type", "access_control", "body_message", "body_image_url", "body_image_text":
            return JSONableString().initAttributes
        case "id":
            return JSONableInt64().initAttributes
        case "created_date", "updated_date":
            return JSONableDate().initAttributes
        case "displayed_photo":
            return Photo().initAttributes
        case "likes":
            return LikeBlob().initAttributes
        case "comments":
            return CommentBlob().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String : JSONPart]?, _ anyDict: Any?) -> JSONable {
        let _ = super.initAttributes(attributeName, &jsonString, jsonRange, jsonAttributes, anyDict)
        if let type = (self.getAttributeInstance("type") as? JSONableString)?.string {
            if let c = Base.getClassFromType(type) {
                let i = c.init()
                i.cloneFrom(self)
                return i
            }
        }
        return self
    }
    
    static func getClassFromType(_ type: String) -> Base.Type? {
        if let t = BaseType(rawValue: type) {
            switch t {
            case .Group:
                return Group.self
            case .Comment, .PhotoTextComment, .StatusTextComment, .NodeToRelationshipTextComment:
                return Comment.self
            case .Display:
                return Display.self
            case .Event:
                return Event.self
            case .Feed:
                return Feed.self
            case .User:
                return User.self
            case .TextWallMessage:
                return TextWallMessage.self
            case .Photo:
                return Photo.self
            case .PhotoAlbum:
                return PhotoAlbum.self
            case .Ride:
                return Ride.self
            case .Location:
                return Location.self
            case .Status:
                return Status.self
            case .URLTag:
                return URLTag.self
            case .HashTag:
                return HashTag.self
            case .UserMentionTag:
                return UserMentionTag.self
            default:
                break
            }
        }
        return nil
    }
    
    static internal func getBaseModelCreationMethodFromType(_ type: String) -> CreationMethod {
        if let c = Base.getClassFromType(type) {
            return c.init().initAttributes
        } else {
            return Base().initAttributes
        }
    }
    
    static internal func instantiateBaseModelFromType(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONable? {
        if let type = JSONable.getAttributeStringValue("entity_type", &jsonString, jsonRange, jsonAttributes, anyDict) {
            return Base.getBaseModelCreationMethodFromType(type)(attributeName, &jsonString, jsonRange, jsonAttributes, anyDict)
        }
        return Base().initAttributes(attributeName, &jsonString, jsonRange, jsonAttributes, anyDict)
    }
    
    func getTypeEnum() -> BaseType? {
        if let t = type {
            return BaseType(rawValue: t)
        }
        
        return nil
    }
    
    func getType() -> String? {
        return self.type
    }
    
    func getId() -> Int64? {
        return self.id
    }
    
    func getIdStr() -> String? {
        return self.idStr
    }
    
    func getCreatedDate() -> Date? {
        return self.createdDate
    }
    
    func getDisplayedName() -> String? {
        return self.displayedName
    }
    
    func getDisplayedPhoto() -> Photo? {
        return self.displayedPhoto
    }
    
    func getBodyImageURL() -> String? {
        return nil
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let m = object as? Base, let thisId = self.id, let thatId = m.id {
            return thisId == thatId
        }
        return super.isEqual(object)
    }
}

