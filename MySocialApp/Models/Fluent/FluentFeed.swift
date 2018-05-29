import Foundation
import RxSwift

class FluentFeed {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    public init(_ session:  Session) {
        self.session = session
    }
    
    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<Feed>) {
        if to > 0 {
            let _ = session.clientService.feed.list(page, size: min(FluentFeed.PAGE_SIZE,to - (page * FluentFeed.PAGE_SIZE))).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < FluentFeed.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - FluentFeed.PAGE_SIZE, obs)
                    }
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }
    
    public func blockingStream(limit: Int = Int.max) throws -> [Feed] {
        return try self.list(page: 0, size: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) throws -> Observable<Feed> {
        return self.list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [Feed] {
        return try self.list(page: page, size: size).toBlocking().toArray()
    }

    public func list(page: Int = 0, size: Int = 10) -> Observable<Feed> {
        return Observable.create {
            obs in
            self.stream(page, size, obs)
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
        .subscribeOn(MainScheduler.instance)
    }
    
    public func blockingSendWallPost(_ textWallMessage: TextWallMessage) throws -> Base? {
        return try self.sendWallPost(textWallMessage).toBlocking().last()
    }
    
    public func sendWallPost(_ textWallMessage: TextWallMessage) -> Observable<Base> {
        return Observable.create {
            obs in
            let _ = self.session.account.get().subscribe {
                e in
                if let e = e.element {
                    let _ = self.session.clientService.textWallMessage.post(forTarget: e, message: textWallMessage).subscribe {
                        e in
                        if let e = e.element {
                            obs.onNext(e)
                        } else if let e = e.error {
                            obs.onError(e)
                        }
                        obs.onCompleted()
                    }
                } else {
                    obs.onCompleted()
                }
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    public func blockingSendWallPost(_ textWallMessage: TextWallMessage, withImage image: UIImage) throws -> Base? {
        return try self.sendWallPost(textWallMessage, withImage: image).toBlocking().last()
    }
    
    public func sendWallPost(_ textWallMessage: TextWallMessage, withImage image: UIImage) -> Observable<Base> {
        return Observable.create {
            obs in
            let _ = self.session.account.get().subscribe {
                e in
                if let e = e.element {
                    let _ = self.session.clientService.textWallMessage.post(forTarget: e, message: textWallMessage, image: image) {
                        e in
                        if let e = e {
                            obs.onNext(e)
                        }
                        obs.onCompleted()
                    }
                } else {
                    obs.onCompleted()
                }
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
}
