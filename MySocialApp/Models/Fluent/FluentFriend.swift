import Foundation
import RxSwift
import RxBlocking

public class FluentFriend {
    
    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }

    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }

    public func blockingListIncomingFriendRequests() throws -> [User] {
        return try listIncomingFriendRequests().toBlocking().toArray()
    }
    
    public func listIncomingFriendRequests() -> Observable<User> {
        return Observable.create {
            obs in
            let _ = self.listFriendRequests().subscribe {
                e in
                if let e = e.element {
                    e.incoming?.forEach { obs.onNext($0) }
                } else if let error = e.error {
                    obs.onError(error)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
    
    public func blockingListOutgoingFriendRequests() throws -> [User] {
        return try listOutgoingFriendRequests().toBlocking().toArray()
    }
    
    public func listOutgoingFriendRequests() -> Observable<User> {
        return Observable.create {
            obs in
            let _ = self.listFriendRequests().subscribe {
                e in
                if let e = e.element {
                    e.outgoing?.forEach { obs.onNext($0) }
                } else if let error = e.error {
                    obs.onError(error)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
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
                        } else if let error = e.error {
                            obs.onError(error)
                        }
                        obs.onCompleted()
                    }
                }
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }
}
