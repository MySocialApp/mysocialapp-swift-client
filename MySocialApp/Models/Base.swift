import Foundation
import RxSwift

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
        set(isLiked) { self.likes?.hasLike = isLiked }
    }
    var commentsTotal: Int {
        get { if let t = comments?.total { return t } else { return 0 } }
        set(total) { comments?.total = total }
    }
    var commentsSamples: [Comment] {
        get { if let s = comments?.samples { return s } else { return [] } }
    }
    var likersTotal: Int {
        get { if let t = likes?.total { return t } else { return 0 } }
        set(total) { likes?.total = total }
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
    
    // BaseWall specific methods
    
    func getBlockingLikes() throws -> [Like] {
        return try getLikes().toBlocking().toArray()
    }
    
    func getLikes() -> Observable<Like> {
        if let session = self.session {
            return Observable.create {
                obs in
                let _ = session.clientService.likeable.get(self).subscribe {
                    e in
                    if let e = e.element {
                        e.iterate {
                            obs.onNext($0)
                        }
                    }
                    obs.onCompleted()
                }
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        } else {
            return Observable.create {
                obs in
                obs.onCompleted()
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func addBlockingLike() throws -> Like? {
        return try addLike().toBlocking().first()
    }
    
    func addLike() -> Observable<Like> {
        if let session = self.session {
            return session.clientService.likeable.post(self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func deleteBlockingLike() throws -> Bool? {
        return try deleteLike().toBlocking().first()
    }
    
    func deleteLike() -> Observable<Bool> {
        if let session = self.session {
            return session.clientService.likeable.delete(self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func getBlockingComments() throws -> [Comment] {
        return try getComments().toBlocking().toArray()
    }
    
    func getComments() -> Observable<Comment> {
        if let session = self.session {
            return Observable.create {
                obs in
                let _ = session.clientService.commentable.get(self).subscribe {
                    e in
                    if let e = e.element {
                        e.iterate {
                            obs.onNext($0)
                        }
                    }
                    obs.onCompleted()
                }
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        } else {
            return Observable.create {
                obs in
                obs.onCompleted()
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func addBlockingComment(_ comment: Comment, withPhoto: UIImage? = nil) throws -> Comment? {
        return try addComment(comment, withPhoto: withPhoto).toBlocking().first()
    }
    
    func addComment(_ comment: Comment, withPhoto: UIImage? = nil) -> Observable<Comment> {
        if let session = self.session {
            return Observable.create {
                obs in
                session.clientService.commentable.post(self, comment: comment, image: withPhoto) {
                    e in
                    if let e = e {
                        obs.onNext(e)
                    } else {
                        obs.onCompleted()
                    }
                }
                return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
        }
    }
    
    func ignore() -> Observable<Void> {
        if let session = self.session, let id = self.id {
            return session.clientService.feed.stopFollow(id)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func abuse() -> Observable<Void> {
        if let session = self.session, let id = self.id {
            return session.clientService.report.post(id)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func delete() -> Observable<Bool> {
        if let session = self.session, let id = self.id {
            return session.clientService.feed.delete(id)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }

    func blockingSendWallPost(_ feedPost: FeedPost) throws -> Feed? {
        return try sendWallPost(feedPost).toBlocking().first()
    }
    
    func sendWallPost(_ feedPost: FeedPost) -> Observable<Feed> {
        if let s = self.session {
            if let p = feedPost.photo {
                return Observable.create {
                    obs in
                    s.clientService.textWallMessage.post(forTarget: self, message: feedPost.textWallMessage, image: p) {
                        e in
                        if let e = e as? Feed {
                            obs.onNext(e)
                        } else {
                            obs.onCompleted()
                        }
                    }
                    return Disposables.create()
                    }.observeOn(MainScheduler.instance)
                    .subscribeOn(MainScheduler.instance)
            } else if let t = feedPost.textWallMessage {
                return Observable.create {
                    obs in
                    let _ = s.clientService.textWallMessage.post(forTarget: self, message: t).subscribe {
                        e in
                        if let e = e.element as? Feed {
                            obs.onNext(e)
                        } else if let e = e.error {
                            obs.onError(e)
                        } else {
                            obs.onCompleted()
                        }
                    }
                    return Disposables.create()
                    }.observeOn(MainScheduler.instance)
                    .subscribeOn(MainScheduler.instance)
            } else {
                return Observable.create {
                    obs in
                    let e = RestError()
                    e.setStringAttribute(withName: "message", "At least message or photo is mandatory to post a feed")
                    obs.onError(e)
                    return Disposables.create()
                    }.observeOn(MainScheduler.instance)
                    .subscribeOn(MainScheduler.instance)
            }
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
}

