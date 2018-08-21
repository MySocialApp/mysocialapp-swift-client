import Foundation
import RxSwift

public class Photo: Base, Taggable {

    internal var photo: UIImage? = nil

    public var message: String?{
        get { return (super.getAttributeInstance("message") as! JSONableString?)?.string }
        set(message) { super.setStringAttribute(withName: "message", message) }
    }
    public var url: String?{
        get { return (super.getAttributeInstance("url") as! JSONableString?)?.string }
        set(url) { super.setStringAttribute(withName: "url", url) }
    }
    public var smallURL: String?{
        get { return (super.getAttributeInstance("small_url") as! JSONableString?)?.string }
        set(smallURL) { super.setStringAttribute(withName: "small_url", smallURL) }
    }
    public var mediumURL: String?{
        get { return (super.getAttributeInstance("medium_url") as! JSONableString?)?.string }
        set(mediumURL) { super.setStringAttribute(withName: "medium_url", mediumURL) }
    }
    public var highURL: String?{
        get { return (super.getAttributeInstance("high_url") as! JSONableString?)?.string }
        set(highURL) { super.setStringAttribute(withName: "high_url", highURL) }
    }
    public var target: Base?{
        get { return super.getAttributeInstance("target") as? Base }
        set(target) { super.setAttribute(withName: "target", target) }
    }
    public var tagEntities: TagEntities?{
        get { return super.getAttributeInstance("tag_entities") as? TagEntities }
        set(tagEntities) { super.setAttribute(withName: "tag_entities", tagEntities) }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "message", "url", "small_url", "medium_url", "high_url":
            return JSONableString().initAttributes
        case "target":
            return Base().initAttributes
        case "tag_entities":
            return TagEntities().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public override func delete() -> Observable<Bool> {
        if let session = self.session, let id = self.id {
            return session.clientService.photo.delete(id)
        } else {
            return Observable.empty()
        }
    }
    
    public func save() -> Observable<Photo> {
        if let session = self.session, let id = self.id {
            return session.clientService.photo.update(id, photo: self)
        } else {
            return Observable.empty()
        }
    }
    
    public class Builder {
        private var mMessage: String? = nil
        private var mImageFile: UIImage? = nil
        private var mVisibility = AccessControl.Friend
        
        public init() {}
        
        public func setName(_ name: String) -> Builder {
            self.mMessage = name
            return self
        }
        
        public func setImage(_ image: UIImage) -> Builder {
            self.mImageFile = image
            return self
        }
        
        public func setVisibility(_ visibility: AccessControl) -> Builder {
            self.mVisibility = visibility
            return self
        }
        
        public func build() throws -> Photo {
            guard mImageFile != nil else {
                let e = MySocialAppException()
                e.setStringAttribute(withName: "message", "Image cannot be null")
                throw e
            }
            
            let photo = Photo()
            photo.photo = mImageFile
            photo.message = mMessage
            photo.accessControl = mVisibility
            return photo
        }
    }
}
