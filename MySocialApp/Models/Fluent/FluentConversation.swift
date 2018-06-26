import Foundation
import RxSwift

public class FluentConversation {
    private static let PAGE_SIZE = 10

    var session: Session
    
    init(_ session:  Session) {
        self.session = session
    }
    
    private func scheduler() -> ImmediateSchedulerType {
        return self.session.clientConfiguration.scheduler
    }

    private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<Conversation>, offset: Int = 0) {
        guard offset < FluentConversation.PAGE_SIZE else {
            self.stream(page+1, to - FluentConversation.PAGE_SIZE, obs, offset: offset - FluentConversation.PAGE_SIZE)
            return
        }
        if to > 0 {
            let _ = session.clientService.conversation.list(page, size: min(FluentConversation.PAGE_SIZE,to - (page * FluentConversation.PAGE_SIZE))).subscribe {
                e in
                if let e = e.element?.array {
                    for i in offset..<e.count {
                        obs.onNext(e[i])
                    }
                    if e.count < FluentConversation.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.stream(page + 1, to - FluentConversation.PAGE_SIZE, obs)
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
    
    public func blockingStream(limit: Int = Int.max) throws -> [Conversation] {
        return try self.list(page: 0, size: limit).toBlocking().toArray()
    }
    
    public func stream(limit: Int = Int.max) throws -> Observable<Conversation> {
        return self.list(page: 0, size: limit)
    }
    
    public func blockingList(page: Int = 0, size: Int = 10) throws -> [Conversation] {
        return try self.list(page: page, size: size).toBlocking().toArray()
    }

    public func list(page: Int = 0, size: Int = 10) -> Observable<Conversation> {
        return Observable.create {
            obs in
            let to = (page+1) * size
            if size > FluentConversation.PAGE_SIZE {
                var offset = page*size
                let page = offset / FluentConversation.PAGE_SIZE
                offset -= page * FluentConversation.PAGE_SIZE
                self.stream(page, to, obs, offset: offset)
            } else {
                self.stream(page, to, obs)
            }
            return Disposables.create()
            }.observeOn(self.scheduler())
            .subscribeOn(self.scheduler())
    }

    public func blockingGet(_ id: Int64) throws -> Conversation? {
        return try self.get(id).toBlocking().first()
    }
    
    public func get(_ id: Int64) -> Observable<Conversation> {
        return session.clientService.conversation.get(id)
    }
    
    public func blockingCreate(_ conversation: Conversation) throws -> Conversation? {
        return try self.create(conversation).toBlocking().first()
    }
    
    public func create(_ conversation: Conversation) -> Observable<Conversation> {
        return session.clientService.conversation.post(conversation)
    }
}
