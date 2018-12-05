import Foundation
import RxSwift

public class FluentPhoto {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }
    
    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<Photo>, offset: Int = 0) {
        guard offset < FluentPhoto.PAGE_SIZE else {
            self.stream(page+1, to, obs, offset: offset - FluentPhoto.PAGE_SIZE)
            return
        }
        let size = min(FluentPhoto.PAGE_SIZE,to - (page * FluentPhoto.PAGE_SIZE))
        if size > 0 {
            let _ = session.clientService.photo.list(page, size: size).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < FluentPhoto.PAGE_SIZE {
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
    
    public func blockingStream(limit: Int = Int.max) throws -> [Photo] {
        return try self.list(page: 0, size: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) throws -> Observable<Photo> {
        return self.list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [Photo] {
        return try self.list(page: page, size: size).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10) -> Observable<Photo> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > FluentPhoto.PAGE_SIZE {
                var offset = page*size
                let page = offset / FluentPhoto.PAGE_SIZE
                offset -= page * FluentPhoto.PAGE_SIZE
                self.stream(page, to, obs, offset: offset)
            } else {
                self.stream(page, to, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingGet(_ id: Int64) throws -> Photo? {
        return try self.get(id).toBlocking().first()
    }
    
    public func get(_ id: Int64) -> Observable<Photo> {
        return self.session.clientService.photo.get(id)
    }
    
    public func blockingCreate(_ photo: Photo) throws -> Photo? {
        return try self.create(photo).toBlocking().first()
    }
    
    public func create(_ photo: Photo) -> Observable<Photo> {
        guard let rawPhoto = photo.photo else {
            return Observable.empty()
        }
        return Observable.create {
            obs in
            _ = self.session.account.get().subscribe {
                if let user = $0.element {
                    var textWallMessage: TextWallMessage?
                    if photo.message != nil {
                        textWallMessage = TextWallMessage()
                        textWallMessage?.message = photo.message
                        textWallMessage?.tagEntities = photo.tagEntities
                        textWallMessage?.accessControl = photo.accessControl
                    }
                    self.session.clientService.textWallMessage.post(forTarget: user, message: textWallMessage, profile: nil, image: rawPhoto) {
                        if let feed = $0 as? Feed, let photo = feed.object as? Photo {
                            obs.onNext(photo)
                        } else {
                            obs.onCompleted()
                        }
                    }
                } else {
                    if let error = $0.error {
                        obs.onError(error)
                    }
                    obs.onCompleted()
                }
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
}
