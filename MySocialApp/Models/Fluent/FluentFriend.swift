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
    
    public func blockingTotalIncomingFriendRequests() throws -> Int? {
        return try self.totalIncomingFriendRequests().toBlocking().first()
    }
    
    public func totalIncomingFriendRequests() -> Observable<Int> {
        return Observable.create {
            obs in
            let _ = self.session.clientService.accountEvent.get().subscribe {
                e in
                if let e = e.element {
                    obs.onNext(e.getIncomingFriendRequests())
                } else if let error = e.error {
                    obs.onError(error)
                }
                obs.onCompleted()
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
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
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [User] {
        return try list(page: page, size: size).toBlocking().toArray()
    }
    
    public func list(page: Int = 0, size: Int = 10) -> Observable<User> {
        return Observable.create {
            obs in
            let _ = self.session.account.get().subscribe {
                e in
                if let e = e.element {
                    let _ = e.listFriends(page: page, size: size).subscribe {
                        e in
                        if let e = e.element {
                            obs.onNext(e)
                        } else if let error = e.error {
                            obs.onError(error)
                        }
                        obs.onCompleted()
                    }
                } else {
                    if let error = e.error {
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
