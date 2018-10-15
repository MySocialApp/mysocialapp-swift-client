import Foundation
import RxSwift

public class FluentPhotoAlbum {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }
    
    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<PhotoAlbum>, offset: Int = 0) {
        guard offset < FluentPhotoAlbum.PAGE_SIZE else {
            self.stream(page+1, to, obs, offset: offset - FluentPhotoAlbum.PAGE_SIZE)
            return
        }
        let size = min(FluentPhotoAlbum.PAGE_SIZE,to - (page * FluentPhotoAlbum.PAGE_SIZE))
        if size > 0 {
            let _ = session.clientService.photoAlbum.list(page, size: size).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < FluentPhotoAlbum.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to, obs)
                    }
                } else if let error = e.error {
                    obs.onError(error)
                    obs.onCompleted()
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }
    
    public func blockingStream(limit: Int = Int.max) throws -> [PhotoAlbum] {
        return try self.list(page: 0, size: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) throws -> Observable<PhotoAlbum> {
        return self.list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [PhotoAlbum] {
        return try self.list(page: page, size: size).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10) -> Observable<PhotoAlbum> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > FluentPhotoAlbum.PAGE_SIZE {
                var offset = page*size
                let page = offset / FluentPhotoAlbum.PAGE_SIZE
                offset -= page * FluentPhotoAlbum.PAGE_SIZE
                self.stream(page, to, obs, offset: offset)
            } else {
                self.stream(page, to, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingGet(_ id: Int64) throws -> PhotoAlbum? {
        return try self.get(id).toBlocking().first()
    }
    
    public func get(_ id: Int64) -> Observable<PhotoAlbum> {
        return self.session.clientService.photoAlbum.get(id)
    }
    
    public func blockingCreate(_ photoAlbum: PhotoAlbum) throws -> PhotoAlbum? {
        return try self.create(photoAlbum).toBlocking().first()
    }
    
    public func create(_ photoAlbum: PhotoAlbum) -> Observable<PhotoAlbum> {
        guard StringUtils.trimToNil(photoAlbum.name) != nil else {
            return Observable.empty()
        }
        return Observable.create {
            obs in
            var res = self.session.clientService.photoAlbum.post(photoAlbum)
            photoAlbum.photos?.filter { $0.photo != nil }.forEach {
                photo in
                res = res.flatMap {
                    photoAlbum in
                    photoAlbum.addPhoto(photo).map {
                        photo in
                        photoAlbum
                    }
                }
            }
            let _ = res.subscribe {
                if let album = $0.element {
                    obs.onNext(album)
                } else if let e = $0.error {
                    obs.onError(e)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
}
