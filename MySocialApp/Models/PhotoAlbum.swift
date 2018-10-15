import Foundation
import RxSwift

public class PhotoAlbum: Base {

    public var name: String?{
        get { return (super.getAttributeInstance("name") as! JSONableString?)?.string }
        set(name) { super.setStringAttribute(withName: "name", name) }
    }
    public var photos: [Photo]?{
        get { return (super.getAttributeInstance("photos") as! JSONableArray<Photo>?)?.array }
        set(photos) { super.setArrayAttribute(withName: "photos", photos) }
    }
    public var previewPhotos: PreviewPhotos?{
        get { return super.getAttributeInstance("preview_photos") as? PreviewPhotos }
        set(previewPhotos) { super.setAttribute(withName: "preview_photos", previewPhotos) }
    }
    
    public convenience init(_ s: String) {
        self.init()
        self.name = s
        self.displayedName = s
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "name":
            return JSONableString().initAttributes
        case "photos":
            return JSONableArray<Photo>().initAttributes
        case "preview_photos":
            return PreviewPhotos().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }

    public func blockingAddPhoto(_ photo: Photo) throws -> Photo? {
        return try self.addPhoto(photo).toBlocking().first()
    }
    
    public func addPhoto(_ photo: Photo) -> Observable<Photo> {
        return Observable.create {
            obs in
            _ = self.addPhotoWithFeedResult(photo).subscribe {
                if let photo = $0.element?.object as? Photo {
                    obs.onNext(photo)
                } else {
                    obs.onCompleted()
                }
            }
            return Disposables.create()
        }.observeOn(self.scheduler())
        .subscribeOn(self.scheduler())
    }
    
    public func blockingAddPhotoWithFeedResult(_ photo: Photo) throws -> Feed? {
        return try addPhotoWithFeedResult(photo).toBlocking().first()
    }
    
    public func addPhotoWithFeedResult(_ photo: Photo) -> Observable<Feed> {
        guard let rawPhoto = photo.photo, let name = StringUtils.trimToNil(self.name), let session = self.session else {
            return Observable.empty()
        }
        return Observable.create {
            obs in
            _ = session.account.get().subscribe {
                if let user = $0.element {
                    var textWallMessage: TextWallMessage?
                    if photo.message != nil {
                        textWallMessage = TextWallMessage()
                        textWallMessage?.message = photo.message
                        textWallMessage?.tagEntities = photo.tagEntities
                        textWallMessage?.accessControl = photo.accessControl
                    }
                    session.clientService.textWallMessage.post(forTarget: user, message: textWallMessage, album: name, profile: nil, image: rawPhoto) {
                        if let feed = $0 as? Feed {
                            obs.onNext(feed)
                        } else {
                            obs.onCompleted()
                        }
                    }
                } else {
                    obs.onCompleted()
                }
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public override func delete() -> Observable<Bool> {
        if let session = self.session, let id = self.id {
            return session.clientService.photoAlbum.delete(id)
        } else {
            return Observable.empty()
        }
    }
    
    public func save() -> Observable<PhotoAlbum> {
        if let session = self.session, let id = self.id {
            return session.clientService.photoAlbum.update(id, album: self)
        } else {
            return Observable.empty()
        }
    }
    
    public class Builder {
        private var mName: String? = nil
        private var mPhotos: [Photo] = []
        
        public init() {}
        
        public func setName(_ name: String) -> Builder {
            self.mName = name
            return self
        }
        
        public func addPhoto(_ photo: Photo) -> Builder {
            self.mPhotos.append(photo)
            return self
        }
        
        public func addPhotos(_ photos: [Photo]) -> Builder {
            self.mPhotos.append(contentsOf: photos)
            return self
        }
        
        public func setPhotos(_ photos: [Photo]) -> Builder {
            self.mPhotos = photos
            return self
        }
        
        public func build() throws -> PhotoAlbum {
            let photoAlbum = PhotoAlbum()
            photoAlbum.photos = mPhotos
            photoAlbum.name = mName
            return photoAlbum
        }
    }
}
