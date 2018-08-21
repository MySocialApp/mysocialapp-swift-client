import Foundation
import RxSwift

public class Comment: Base, Taggable {

    public var message: String?{
        get { return (super.getAttributeInstance("message") as! JSONableString?)?.string }
        set(message) { super.setStringAttribute(withName: "message", message) }
    }
    public var tagEntities: TagEntities?{
        get { return super.getAttributeInstance("tag_entities") as? TagEntities }
        set(tagEntities) { super.setAttribute(withName: "tag_entities", tagEntities) }
    }
    public var photo: Photo?{
        get { return super.getAttributeInstance("photo") as? Photo }
        set(photo) { super.setAttribute(withName: "photo", photo) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "message":
            return JSONableString().initAttributes
        case "tag_entities":
            return TagEntities().initAttributes
        case "photo":
            return Photo().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public func blockingReplyBack(_ comment: CommentPost) throws -> Comment? {
        return try self.replyBack(comment).toBlocking().first()
    }
    
    public func replyBack(_ comment: CommentPost) -> Observable<Comment> {
        if let id = self.parent?.id, let session = self.session {
            return session.newsFeed.get(id).flatMap {
                return $0.addComment(comment)
            }
        } else {
            return Observable.empty()
        }
    }
    
    public func blockingSave() throws -> Comment? {
        return try self.save().toBlocking().first()
    }
    
    public func save() -> Observable<Comment> {
        return self.addComment(self)
    }
    
    public override func delete() -> Observable<Bool> {
        if let session = self.session, let _ = self.id {
            return session.clientService.commentable.delete(self.parent ?? self, comment: self)
        } else {
            return Observable.create {
                obs in
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(self.scheduler())
                .subscribeOn(self.scheduler())
        }
    }
}
