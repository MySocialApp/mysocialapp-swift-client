import Foundation
import RxSwift
import RxBlocking

public class FluentFriend {
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }

    public func blockingListIncomingFriendRequests() throws -> [User] {
        return try listIncomingFriendRequests().toBlocking().toArray()
    }
    
    public func listIncomingFriendRequests() -> Observable<User> {
        return Observable.create {
            obs in
            let _ = self.listFriendRequests().subscribe {
                e in
                let _ = e.element?.incoming?.map {
                    obs.onNext($0)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    public func blockingListOutgoingFriendRequests() throws -> [User] {
        return try listOutgoingFriendRequests().toBlocking().toArray()
    }
    
    public func listOutgoingFriendRequests() -> Observable<User> {
        return Observable.create {
            obs in
            let _ = self.listFriendRequests().subscribe {
                e in
                let _ = e.element?.outgoing?.map {
                    obs.onNext($0)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    public func blockingListFriendRequests() throws -> FriendRequests? {
        return try listFriendRequests().toBlocking().first()
    }
    
    public func listFriendRequests() -> Observable<FriendRequests> {
        return session.clientService.friendRequest.list()
    }
    
    public func blockingList() throws -> [User] {
        return try list().toBlocking().toArray()
    }
    
    public func list() -> Observable<User> {
        return Observable.create {
            obs in
            let _ = self.session.account.get().subscribe {
                e in
                if let e = e.element {
                    let _ = e.listFriends().subscribe {
                        e in
                        if let e = e.element {
                            obs.onNext(e)
                        } else {
                            obs.onCompleted()
                        }
                    }
                }
            }
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
}
